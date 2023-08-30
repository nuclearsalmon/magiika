module Magiika::Lang::Syntax
  #extend self

  protected def register_tokens
    # comments
    # ------------------------------------------------------
    #token(:COMMENT, /\#.*$/)
    #token(:COMMENT, /\/\*([^*]|\r?\n|(\*+([^*\/]|\r?\n)))*\*+\//)
    #token(:DOC_COMMENT, /\/\*\*(\r?\n|(\*+([^*\/]|\r?\n)))*\*\*+\//)


    # keywords
    # ------------------------------------------------------
    #token(:CONST, /const/)


    # literals
    # ------------------------------------------------------
    token(:BOOL, /(true|false)/)
    token(:FLT, /-?\d+\.\d+/)
    token(:INT, /-?\d+/)
    #token(:STR, /"([^"\\]*(?:\\.[^"\\]*)*)"/)
    #token(:STR, /'([^'\\]*(?:\\.[^'\\]*)*)'/)


    # multi-character operators and tokens
    # ------------------------------------------------------
    token(:ASSIGN_INLINE, /:=/)
    token(:ASSIGN_SUB, /\-=/)
    token(:ASSIGN_ADD, /\+=/)
    token(:ASSIGN_MULT, /\*=/)
    token(:ASSIGN_DIV, /\\=/)
    token(:ASSIGN_POW, /\*\*=/)
    token(:ASSIGN_PIPE, /\|=/)

    token(:OR, /\|\||or/)
    token(:AND, /&&|and/)
    token(:BXNOR, /!\^|xnor/)
    token(:BXOR, /xor/)
    token(:BNOR, /!\|/)
    token(:BNAND, /!&/)
    token(:NOR, /nor/)
    token(:NAND, /nand/)
    token(:NOT_L, /not/)

    token(:EQ, /==/)
    token(:NEQ, /!=/)
    token(:LEQ, /<=/)
    token(:GEQ, />=/)
    token(:INC, /\+\+/)
    token(:DEC, /\-\-/)
    token(:IDIV, /\/\//)
    token(:POW, /\*\*/)
    token(:LSH, /<</)
    token(:RSH, />>/)
    token(:IMPL, /\->/)


    # single-character operators and tokens
    # ------------------------------------------------------
    token(:DEFINE, /:/)
    token(:ASSIGN, /=/)

    # FIXME: swap bitwise ops to be literal "XOR",
    #   and use single chars for other ops.
    token(:BOR, /\|/)
    token(:BAND, /&/)
    token(:BXOR, /\^/)

    token(:ADD, /\+/)
    token(:SUB, /\-/)
    token(:MULT, /\*/)
    token(:DIV, /\//)
    token(:MOD, /%/)

    token(:NOT_S, /!/)
    token(:LT, /</)
    token(:GT, />/)

    token(:L_PAR, /\(/)
    token(:R_PAR, /\)/)
    token(:L_SQPAR, /\[/)
    token(:R_SQPAR, /\]/)
    token(:L_BRC, /\{/)
    token(:R_BRC, /\}/)

    token(:MEMBER, /\./)



    # identifiers
    # ------------------------------------------------------
    token(:NAME, /([A-Za-z_][A-Za-z0-9_]*)/)


    # whitespace
    # (ran last, to allow for whitespace-sensitive tokens)
    # ------------------------------------------------------
    token(:TAB, /\t| {2}+/)
    token(:SPACE, / +/)
    token(:LINE_SEGMENT, /\\[\t ]*\r?\n/)
    token(:NEWLINE, /\r?\n/)
    token(:INLINE_NEWLINE, /;/)
  end
end
