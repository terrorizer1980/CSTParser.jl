module Parser
global debug = true

using Tokenize
import Base: next, start, done, length, first, last, +, isempty
import Tokenize.Tokens
import Tokenize.Tokens: Token, iskeyword, isliteral, isoperator
import Tokenize.Lexers: Lexer, peekchar, iswhitespace

export ParseState

include("parsestate.jl")
include("spec.jl")
include("utils.jl")
include("positional.jl")
include("components/curly.jl")
include("components/operators.jl")
include("components/functions.jl")
include("components/generators.jl")
include("components/genericblocks.jl")
include("components/ifblock.jl")
include("components/loops.jl")
include("components/macros.jl")
include("components/modules.jl")
include("components/prefixkw.jl")
include("components/refs.jl")
include("components/tryblock.jl")
include("components/types.jl")
include("components/tuples.jl")
include("conversion.jl")
include("display.jl")
include("formatting.jl")


"""
    parse_expression(ps)

Parses an expression until `closer(ps) == true`. Expects to enter the 
`ParseState` the token before the the beginning of the expression and ends 
on the last token. 

Acceptable starting tokens are: 
+ A keyword
+ An opening parentheses or brace.
+ An operator.
+ An instance (e.g. identifier, number, etc.)
+ An `@`.

"""
function parse_expression(ps::ParseState)
    next(ps)
    if Tokens.begin_keywords < ps.t.kind < Tokens.end_keywords 
        ret = @nocloser ps ws parse_kw(ps, Val{ps.t.kind})
    elseif ps.t.kind == Tokens.LPAREN
        ret = parse_paren(ps)
    elseif ps.t.kind == Tokens.LSQUARE
        ret = parse_square(ps)
    elseif ps.t.kind == Tokens.TRIPLE_STRING && ps.current_scope.id == TOPLEVEL
        ret = parse_doc(ps)
    elseif ps.t.kind == Tokens.OR && ps.closer.quotemode
        head = INSTANCE(ps)
        arg = parse_expression(ps)
        ret = EXPR(head, arg, head.span + arg.span)
    elseif isinstance(ps.t) || isoperator(ps.t)
        ret = INSTANCE(ps)
    elseif ps.t.kind==Tokens.AT_SIGN
        ret = @closer ps semicolon parse_macrocall(ps)
    else
        error("Expression started with $(ps)")
    end

    while !closer(ps)
        ret = parse_juxtaposition(ps, ret)
    end

    return ret
end


"""
    parse_juxtaposition(ps, ret)

Handles cases where an expression - `ret` - is not followed by 
`closer(ps) == true`. Possible juxtapositions are: 
+ operators
+ `(`, calls
+ `[`, ref
+ `{`, curly
+ `,`, commas
+ `for`, generators
+ strings
+ an expression preceded by a unary operator

"""
function parse_juxtaposition(ps::ParseState, ret)
    if ps.nt.kind == Tokens.FOR
        ret = parse_generator(ps, ret)
    elseif (ret isa LITERAL{Tokens.INTEGER} || ret isa LITERAL{Tokens.FLOAT}) && (ps.nt.kind == IDENTIFIER || ps.nt.kind == Tokens.LPAREN)
        arg = parse_expression(ps)
        ret = EXPR(CALL, [OPERATOR{11,Tokens.STAR}(0, 0), ret, arg], ret.span + arg.span)
    elseif ps.nt.kind==Tokens.LPAREN
        if isempty(ps.ws)
            ret = @default ps @closer ps paren parse_call(ps, ret)
        else
            error("space before \"(\" not allowed in \"$(Expr(ret)) (\"")
        end
    elseif ps.nt.kind==Tokens.LBRACE
        if isempty(ps.ws)
            ret = parse_curly(ps, ret)
        else
            error("space before \"{\" not allowed in \"$(Expr(ret)) {\"")
        end
    elseif ps.nt.kind==Tokens.LSQUARE
        if isempty(ps.ws)
            ret = parse_ref(ps, ret)
        else
            error("space before \"{\" not allowed in \"$(Expr(ret)) {\"")
        end
    elseif isunaryop(ps.t)
        ret = parse_unary(ps, ret)
    elseif isoperator(ps.nt)
        next(ps)
        format(ps)
        op = INSTANCE(ps)
        ret = parse_operator(ps, ret, op)
    elseif ps.nt.kind == Tokens.SEMICOLON
        ret = parse_semicolon(ps, ret)
    elseif ps.nt.kind == Tokens.COMMA
        ret = parse_comma(ps, ret)
    elseif ret isa IDENTIFIER && ps.nt.kind == Tokens.STRING || ps.nt.kind == Tokens.TRIPLE_STRING
        next(ps)
        arg = INSTANCE(ps)
        ret = EXPR(x_STR, [ret, arg], ret.span + arg.span)
    elseif isinstance(ps.nt)
        if isunaryop(ps.t)
            ret = parse_unary(ps, ret)
        elseif isoperator(ps.t)
            error("$ret is not a unary operator")
        else 
            error("unexpected at $ps")
        end
    else
        for s in stacktrace()
            println(s)
        end
        for f in fieldnames(ps.closer)
            if getfield(ps.closer, f)==true
                println(f, ": true")
            end
        end
        error("infinite loop at $(ps)")
    end
    return ret
end



"""
    parse_list(ps)

Parses a list of comma seperated expressions finishing when the parent state
of `ps.closer` is met. Expects to start at the first item and ends on the last
item so surrounding punctuation must be handled externally.
"""
function parse_list(ps::ParseState, puncs)
    args = Expression[]

    while !closer(ps)
        a = @nocloser ps newline @closer ps comma parse_expression(ps)
        push!(args, a)
        if ps.nt.kind==Tokens.COMMA
            push!(puncs, INSTANCE(next(ps)))
            format(ps)
        end
    end

    if ps.t.kind == Tokens.COMMA
        format(ps)
    end
    return args
end

function parse_comma(ps::ParseState, ret)
    format(ps)
    next(ps)
    op = INSTANCE(ps)
    start = ps.t.startbyte
    if isassignment(ps.nt)
        if ret isa EXPR && ret.head!=TUPLE
            ret =  EXPR(TUPLE, Expression[ret], ps.t.endbyte - start + 1, INSTANCE[op])
        end
    elseif closer(ps)
        ret = EXPR(TUPLE, Expression[ret], ret.span + op.span, INSTANCE[op])
    else
        nextarg = @closer ps tuple parse_expression(ps)
        if ret isa EXPR && ret.head==TUPLE
            push!(ret.args, nextarg)
            push!(ret.punctuation, op)
            ret.span += ps.nt.startbyte - start
        else
            ret =  EXPR(TUPLE, Expression[ret, nextarg], ret.span+ps.nt.startbyte - start, INSTANCE[op])
        end
    end
    return ret
end


"""
    parse_paren(ps, ret)

Constructs a `block` having hit a `;` while parsing an expression.
"""
function parse_semicolon(ps::ParseState, ret)
    next(ps)
    op = INSTANCE(ps)
    if closer(ps)
        ret = EXPR(BLOCK, [ret], ret.span, [op])
    else
        nextarg = @closer ps semicolon parse_expression(ps)
        if ret isa EXPR && ret.head == BLOCK && last(ret.punctuation) isa PUNCTUATION{Tokens.SEMICOLON}
            push!(ret.args, nextarg)
            push!(ret.punctuation, op)
            ret.span += nextarg.span + op.span
        else
            ret = EXPR(BLOCK, [ret, nextarg], ret.span, [op])
        end
    end
    return ret
end

"""
    parse_paren(ps, ret)

Parses the juxtaposition of `ret` with an opening parentheses. Parses a comma 
seperated list.
"""
function parse_paren(ps::ParseState)
    start = ps.t.startbyte
    openparen = INSTANCE(ps)
    format(ps)
    if ps.nt.kind == Tokens.RPAREN
        ret = EXPR(TUPLE, [])
    else
        ret = @clear ps @closer ps paren parse_expression(ps)
    end
    next(ps)
    closeparen = INSTANCE(ps)
    if ret isa EXPR && (ret.head == TUPLE || (ret.head == BLOCK && last(ret.punctuation isa PUNCTUATION{Tokens.SEMICOLON})))
        unshift!(ret.punctuation, openparen)
        push!(ret.punctuation, closeparen)
        format(ps)
        ret.span += openparen.span + closeparen.span
    elseif ret isa EXPR && ret.head isa OPERATOR{20,Tokens.DDDOT}
        ret = EXPR(TUPLE, [ret], ps.nt.startbyte - start, [openparen, closeparen])
    else
        ret = EXPR(BLOCK, [ret], ps.nt.startbyte - start, [openparen, closeparen])
    end
    return ret
end

function parse_square(ps::ParseState)
    start = ps.t.startbyte
    puncs = INSTANCE[INSTANCE(ps)]
    format(ps)
    if ps.nt.kind == Tokens.RSQUARE
        next(ps)
        push!(puncs, INSTANCE(ps))
        format(ps)
        return EXPR(VECT, [], ps.nt.startbyte - start, puncs)
    else
        ret = @default ps @closer ps square parse_expression(ps)
        if ret isa EXPR && ret.head==TUPLE
            next(ps)
            push!(puncs, INSTANCE(ps))
            format(ps)
            return EXPR(VECT, ret.args, ps.nt.startbyte - start, puncs)
        elseif ret isa EXPR && ret.head==GENERATOR
            next(ps)
            push!(puncs, INSTANCE(ps))
            format(ps)
            return EXPR(COMPREHENSION, [ret], ps.nt.startbyte - start, puncs)
        else
            next(ps)
            push!(puncs, INSTANCE(ps))
            format(ps)
            return EXPR(VECT, [ret], ps.nt.startbyte - start, puncs)
        end 
    end
end


"""
    parse_quote(ps)

Handles the case where a colon is used as a unary operator on an
expression. The output is a quoted expression.
"""
function parse_quote(ps::ParseState)
    start = ps.t.startbyte
    puncs = INSTANCE[INSTANCE(ps)]
    if ps.nt.kind == Tokens.IDENTIFIER
        arg = INSTANCE(next(ps))
        return QUOTENODE(arg, arg.span, puncs)
    elseif iskw(ps.nt)
        next(ps)
        arg = IDENTIFIER(ps.nt.startbyte - ps.t.startbyte, ps.t.startbyte, Symbol(ps.val))
        return QUOTENODE(arg, arg.span, puncs)
    elseif isliteral(ps.nt)
        return INSTANCE(next(ps))
    elseif ps.nt.kind == Tokens.LPAREN
        next(ps)
        push!(puncs, INSTANCE(ps))
        if ps.nt.kind == Tokens.RPAREN
            next(ps)
            return EXPR(QUOTE, [EXPR(TUPLE,[], 2, [pop!(puncs), INSTANCE(ps)])], 3, puncs)
        end
        arg = @closer ps paren parse_expression(ps)
        next(ps)
        push!(puncs, INSTANCE(ps))
        return EXPR(QUOTE, [arg],  ps.nt.startbyte - start, puncs)
    end
end

"""
    parse_doc(ps)

Handles the case where an expression starts with a single or triple quoted
string.
"""
function parse_doc(ps::ParseState)
    start = ps.t.startbyte
    doc = INSTANCE(ps)
    if ps.nt.kind == Tokens.ENDMARKER
        return doc
    end
    arg = parse_expression(ps)
    return EXPR(MACROCALL, [GlobalRefDOC, doc, arg], ps.nt.startbyte - start)
end



function parse(str::String, cont = false)
    ps = Parser.ParseState(str)
    ret = parse_expression(ps)
    # Handle semicolon as linebreak
    # while ps.nt.kind == Tokens.SEMICOLON
    #     if ret isa EXPR && ret.head == TOPLEVEL
    #         next(ps)
    #         op = INSTANCE(ps)
    #         arg = parse_expression(ps)
    #         push!(ret.punctuation, op)
    #         push!(ret.args, arg)
    #         ret.span += op.span + arg.span
    #     else
    #         next(ps)
    #         op = INSTANCE(ps)
    #         arg = parse_expression(ps)
    #         ret = EXPR(TOPLEVEL, [ret, arg], ret.span + arg.span + op.span, [op])
    #     end
    # end

    return ret
end


ischainable(t::Token) = t.kind == Tokens.PLUS || t.kind == Tokens.STAR || t.kind == Tokens.APPROX
LtoR(prec::Int) = 1 ≤ prec ≤ 5 || prec == 13

end