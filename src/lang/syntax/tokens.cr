module Magiika::Syntax
  protected def register_tokens
    # comments
    # ------------------------------------------------------
    #token :COMMENT, /#([^\r\n].*)/
    token :COMMENT, /\/\/([^\r\n].*)/
    #token :MULTILINE_COMMENT, /\/\*([^*]|\r?\n|(\*+([^*\/]|\r?\n)))*\*+\//
    #token :DOC_COMMENT, /\/\*\*(\r?\n|(\*+([^*\/]|\r?\n)))*\*\*+\//


    # strings
    # ------------------------------------------------------
    # enable ONE string mode from below
    token :STR, /"([^"\\]*(?:\\.[^"\\]*)*)"/
    #token :STR, /'([^'\\]*(?:\\.[^'\\]*)*)'/
    #token :STR, /(?:"([^"\\]*(?:\\.[^"\\]*)*)")|(?:'([^'\\]*(?:\\.[^'\\]*)*)')/


    # keywords and types
    # ------------------------------------------------------
    #token :BOOL_T, /bool/
    #token :INT_T, /int/
    #token :FLT_T, /flt/
    #token :STR_T, /str/
    #token :NIL_T, /nil/
    #token :LIST_T, /list/
    token :FN_T, /fn/
    token :CLS_T, /cls/

    token :IF, /if/
    token :ELSIF, /elsif/
    token :ELSE, /else/

    token :BOOL, /(?>true|false)/

    token :ACCESS, /(?>prot|priv)/


    # multi-character operators and tokens
    # ------------------------------------------------------
    #token :ASSIGN_INLINE, /:=/
    token :ASSIGN_SUB, /\-=/
    token :ASSIGN_ADD, /\+=/
    token :ASSIGN_MULT, /\*=/
    token :ASSIGN_DIV, /\\=/
    token :ASSIGN_POW, /\*\*=/
    token :ASSIGN_PIPE, /\|=/

    token :OR, /\|\||or/
    token :AND, /&&|and/
    token :XNOR, /xnor/
    token :BXNOR, /!\^|XNOR/
    token :XOR, /xor/
    token :BNOR, /!\||NOR/
    token :NOR, /nor/
    token :BNAND, /!&|NAND/
    token :NAND, /nand/

    token :EQ, /==/
    #token :NEQ, /!=/
    #token :LEQ, /<=/
    #token :GEQ, />=/
    token :INC, /\+\+/
    token :DEC, /\-\-/
    token :IDIV, /\/\!/
    #token :POW, /\*\*/
    #token :LSH, /<</
    #token :RSH, />>/
    token :IMPL, /\->/
    #token :DIA, /<>/

    # single-character operators and tokens
    # ------------------------------------------------------
    token :DOT, /\./
    token :COLON, /:/

    token :ASSIGN, /=/

    # FIXME: swap bitwise ops to be literal "XOR",
    #   and use single chars for other ops.
    token :BOR, /\||OR/
    token :BAND, /&|AND/
    token :BXOR, /\^|XOR/

    token :ADD, /\+/
    token :SUB, /\-/
    token :MULT, /\*/
    token :DIV, /\//
    token :MOD, /%/
    token :CASH, /\$/

    #token :NOT, /!|not/
    #token :BNOT, /NOT/
    #token :LT, /</
    #token :GT, />/

    token :L_PAR, /\(/
    token :R_PAR, /\)/
    #token :L_SQBRC, /\[/
    #token :R_SQBRC, /\]/
    token :L_BRC, /\{/
    token :R_BRC, /\}/

    #token :CHAIN, /\./
    token :SEP, /,/


    # numbers
    # ------------------------------------------------------

    token :FLT, /\d+\.\d+/
    token :INT, /\d+/


    # identifiers
    # ------------------------------------------------------
    token :NAME, /([A-Za-z_][A-Za-z0-9_]*)/


    # whitespace
    # (ran last, to allow for whitespace-sensitive tokens
    # ------------------------------------------------------
    token :SPACE, /[\t ]+/
    token :LINE_CONT, /\\ ?\r?\n[\t ]*/
    token :NEWLINE, /(?: *\r?\n *)+/
    token :INLINE_NEWLINE, / *;/
  end
end
