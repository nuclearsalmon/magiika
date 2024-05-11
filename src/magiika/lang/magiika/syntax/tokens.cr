module Magiika::Lang::Syntax
  #extend self

  protected def register_tokens
    # comments
    # ------------------------------------------------------
    #token(:COMMENT, /\#.*$/)
    #token(:COMMENT, /\/\*([^*]|\r?\n|(\*+([^*\/]|\r?\n)))*\*+\//)
    #token(:DOC_COMMENT, /\/\*\*(\r?\n|(\*+([^*\/]|\r?\n)))*\*\*+\//)

    # keywords and types
    # ------------------------------------------------------
    token(:BOOL_TYP, /bool/)
    token(:INT_TYP, /int/)
    token(:FLT_TYP, /flt/)
    token(:STR_TYP, /str/)
    token(:NIL_TYP, /nil/)
    token(:BOOL_TYP, /bool/)
    token(:LIST_TYP, /list/)
    token(:FN_TYP, /fn/)
    token(:CLS_TYP, /cls/)

    token(:ABSTRACT, /abst/)


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
    token(:XNOR, /xnor/)
    token(:BXNOR, /!\^|XNOR/)
    token(:XOR, /xor/)
    token(:BNOR, /!\||NOR/)
    token(:NOR, /nor/)
    token(:BNAND, /!&|NAND/)
    token(:NAND, /nand/)

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
    token(:DIA, /<>/)

    token(:PAR, /\(\)/)
    token(:SQBRC, /\[\]/)
    token(:BRC, /\{\}/)


    # single-character operators and tokens
    # ------------------------------------------------------
    token(:DEFINE, /:/)
    token(:ASSIGN, /=/)

    # FIXME: swap bitwise ops to be literal "XOR",
    #   and use single chars for other ops.
    token(:BOR, /\||OR/)
    token(:BAND, /&|AND/)
    token(:BXOR, /\^|XOR/)

    token(:ADD, /\+/)
    token(:SUB, /\-/)
    token(:MULT, /\*/)
    token(:DIV, /\//)
    token(:MOD, /%/)

    token(:NOT, /!|not/)
    token(:BNOT, /NOT/)
    token(:LT, /</)
    token(:GT, />/)

    token(:L_PAR, /\(/)
    token(:R_PAR, /\)/)
    token(:L_SQBRC, /\[/)
    token(:R_SQBRC, /\]/)
    token(:L_BRC, /\{/)
    token(:R_BRC, /\}/)

    token(:MEMBER, /\./)
    token(:SEP, /,/)


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


    # literals
    # ------------------------------------------------------
    #token(:STR, /"([^"\\]*(?:\\.[^"\\]*)*)"/)
    #token(:STR, /'([^'\\]*(?:\\.[^'\\]*)*)'/)
    token(:BOOL, /(true|false)/)
    token(:FLT, /-?\d+\.\d+/)
    token(:INT, /-?\d+/)
  end
end
