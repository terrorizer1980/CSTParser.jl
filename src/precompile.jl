function _precompile()
    precompile(ParseState, (String,))
    precompile(ParseState, (String, Int))
    precompile(next, (ParseState,))
    precompile(parse_doc, (ParseState,))
    precompile(Expr, (EXPR,))
    precompile(parse_string_or_cmd, (ParseState, Bool))

    # precompile(setbinding!, (EXPR,))
    # precompile(setbinding!, (EXPR, EXPR))
    # precompile(Binding, (EXPR,))
    # precompile(Binding, (String, EXPR, Nothing, Vector{Any}, Nothing))
    # precompile(Scope, (Nothing, Dict{String,Binding}, Nothing, Bool))
    # precompile(Scope, (Scope, Dict{String,Binding}, Nothing, Bool))
    # precompile(Scope, (Nothing, Dict{String,Binding}, Dict{String,Any}, Bool))
    # precompile(Scope, (Scope, Dict{String,Binding}, Dict{String,Any}, Bool))
    # precompile(Scope, ())
    precompile(EXPR, (Head, Nothing, Int, Int, Nothing, Tokens.Kind, Bool, Nothing, Nothing, Nothing,Nothing))
    precompile(EXPR, (Head, Vector{EXPR}, Int, Int,Nothing, Tokens.Kind,Bool, Nothing, Nothing, Nothing, Nothing))
    precompile(EXPR, (Head, Vector{EXPR}, Int, Int, String, Tokens.Kind,Bool, Nothing, Nothing, Nothing, Nothing))
    precompile(EXPR, (Head, Vector{EXPR}, Int, Int))
    precompile(EXPR, (Head, Vector{EXPR}))

    precompile(mIDENTIFIER, (ParseState,))
    precompile(mPUNCTUATION, (ParseState,))
    precompile(mPUNCTUATION, (Tokens.Kind, Int, Int))
    precompile(mKEYWORD, (ParseState,))
    precompile(mKEYWORD, (Tokens.Kind, Int, Int))
    precompile(mOPERATOR, (ParseState,))
    precompile(mOPERATOR, (Tokens.Kind, Int, Int, Bool))
    precompile(mLITERAL, (ParseState,))
    precompile(mLITERAL, (Int, Int, String, Tokens.Kind))
    precompile(INSTANCE, (ParseState,))

    precompile(tostr, (IOBuffer,))
    precompile(str_value, (EXPR,))

    precompile(CSTParser.parse_expression, (ParseState,))
    precompile(CSTParser.parse_paren, (ParseState,))
    precompile(CSTParser._continue_doc_parse, (ParseState, EXPR))
    precompile(CSTParser.parse_compound, (ParseState, EXPR))
    precompile(CSTParser.parse_operator, (ParseState, EXPR, EXPR))
    precompile(parse_unary, (ParseState, EXPR))
    precompile(parse_unary_colon, (ParseState, EXPR))
    precompile(parse_operator_anon_func, (ParseState, EXPR, EXPR))
    precompile(parse_operator_colon, (ParseState, EXPR, EXPR))
    precompile(parse_operator_cond, (ParseState, EXPR, EXPR))
    precompile(parse_operator_dot, (ParseState, EXPR, EXPR))
    precompile(parse_operator_eq, (ParseState, EXPR, EXPR))
    precompile(parse_operator_power, (ParseState, EXPR, EXPR))
    precompile(parse_operator_where, (ParseState, EXPR, EXPR))

    precompile(CSTParser.parse_block, (ParseState, Vector{EXPR}))
    precompile(CSTParser.parse_block, (ParseState, Vector{EXPR}, Tuple{Tokens.Kind}))
    precompile(CSTParser.parse_block, (ParseState, Vector{EXPR}, Tuple{Tokens.Kind,Bool}))
    precompile(CSTParser.parse_iterator, (ParseState,))
    precompile(CSTParser.parse_iterators, (ParseState, Bool))
    precompile(CSTParser.parse_call, (ParseState, EXPR, Bool))
    precompile(CSTParser.parse_comma_sep, (ParseState, Vector{EXPR}, Bool, Bool, Bool))
    precompile(CSTParser.parse_parameters, (ParseState, Vector{EXPR}, Vector{EXPR}))
    precompile(CSTParser.parse_macrocall, (ParseState,))
    precompile(CSTParser.parse_generator, (ParseState, EXPR))
    precompile(CSTParser.parse_dot_mod, (ParseState, Bool))

    precompile(CSTParser.parse_tuple, (ParseState, EXPR))
    precompile(CSTParser.parse_array, (ParseState, Bool))
    precompile(CSTParser.parse_ref, (ParseState, EXPR))
    precompile(CSTParser.parse_curly, (ParseState, EXPR))
    precompile(CSTParser.parse_braces, (ParseState,))

    precompile(CSTParser.parse_kw, (ParseState,))
    precompile(CSTParser.parse_const, (ParseState,))
    precompile(CSTParser.parse_global, (ParseState,))
    precompile(CSTParser.parse_local, (ParseState,))
    precompile(CSTParser.parse_return, (ParseState,))
    precompile(CSTParser.parse_abstract, (ParseState,))
    precompile(CSTParser.parse_primitive, (ParseState,))
    precompile(CSTParser.parse_imports, (ParseState,))
    precompile(CSTParser.parse_export, (ParseState,))
    precompile(CSTParser.parse_begin, (ParseState,))
    precompile(CSTParser.parse_quote, (ParseState,))
    precompile(CSTParser.parse_function, (ParseState,))
    precompile(CSTParser.parse_macro, (ParseState,))
    precompile(CSTParser.parse_for, (ParseState,))
    precompile(CSTParser.parse_while, (ParseState,))
    precompile(CSTParser.parse_if, (ParseState, Bool))
    precompile(CSTParser.parse_let, (ParseState,))
    precompile(CSTParser.parse_try, (ParseState,))
    precompile(CSTParser.parse_do, (ParseState, EXPR))
    precompile(CSTParser.parse_module, (ParseState,))
    precompile(CSTParser.parse_mutable, (ParseState,))
    precompile(CSTParser.parse_struct, (ParseState, Bool))

    precompile(CSTParser.closer, (ParseState,))
    precompile(CSTParser.create_tmp, (Closer,))
    precompile(CSTParser.update_from_tmp!, (Closer, Closer_TMP))
    precompile(CSTParser.update_to_default!, (Closer,))

    precompile(Tokenize.Lexers.Lexer, (IOBuffer,Type{Tokens.RawToken}))
    precompile(Tokenize.Lexers.next_token, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(get, (Dict{Char,Tokenize.Tokens.Kind},Char,Tokenize.Tokens.Kind))
    precompile(getindex, (Dict{Tokenize.Tokens.Kind, Symbol},Tokenize.Tokens.Kind))

    precompile(Tokenize.Lexers.next_token, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_amper, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_backslash, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_bar, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_circumflex, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_cmd, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_colon, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_comment, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_digit, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken}, Tokens.Kind))
    precompile(Tokenize.Lexers.lex_division, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_dollar, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_dot, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_equal, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_exclaim, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_forwardslash, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_greater, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_identifier, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},Char))
    precompile(Tokenize.Lexers.lex_less, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_minus, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_percent, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_plus, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_prime, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_quote, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_star, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_whitespace, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
    precompile(Tokenize.Lexers.lex_xor, (Tokenize.Lexers.Lexer{IOBuffer,Tokens.RawToken},))
end