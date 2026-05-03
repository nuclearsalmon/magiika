module Magiika::Syntax
  define_syntax do
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
    token :FN_T, /fn(?![A-Za-z0-9_])/
    token :CLS_T, /cls(?![A-Za-z0-9_])/

    token :IF, /if(?![A-Za-z0-9_])/
    token :ELSIF, /elsif(?![A-Za-z0-9_])/
    token :ELSE, /else(?![A-Za-z0-9_])/
    token :WHILE, /while(?![A-Za-z0-9_])/
    token :FOR, /for(?![A-Za-z0-9_])/
    token :IN, /in(?![A-Za-z0-9_])/
    token :BREAK, /break(?![A-Za-z0-9_])/
    token :NEXT, /next(?![A-Za-z0-9_])/

    token :BOOL, /(?>true|false)(?![A-Za-z0-9_])/

    token :ACCESS, /(?>prot|priv)(?![A-Za-z0-9_])/
    token :EXTENDS, /extends(?![A-Za-z0-9_])/
    token :ABSTRACT, /abstract(?![A-Za-z0-9_])/


    # multi-character operators and tokens
    # ------------------------------------------------------
    #token :ASSIGN_INLINE, /:=/
    token :ASSIGN_SUB, /\-=/
    token :ASSIGN_ADD, /\+=/
    token :ASSIGN_MULT, /\*=/
    token :ASSIGN_DIV, /\\=/
    token :ASSIGN_POW, /\*\*=/
    token :ASSIGN_PIPE, /\|=/

    token :OR, /\|\||or(?![A-Za-z0-9_])/
    token :AND, /&&|and(?![A-Za-z0-9_])/
    token :XNOR, /xnor(?![A-Za-z0-9_])/
    token :BXNOR, /!\^|XNOR(?![A-Za-z0-9_])/
    token :XOR, /xor(?![A-Za-z0-9_])/
    token :BNOR, /!\||NOR(?![A-Za-z0-9_])/
    token :NOR, /nor(?![A-Za-z0-9_])/
    token :BNAND, /!&|NAND(?![A-Za-z0-9_])/
    token :NAND, /nand(?![A-Za-z0-9_])/

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
    token :RANGE_EXCL, /\.\.\./
    token :RANGE_INCL, /\.\./
    token :DOT, /\./
    token :COLON, /:/

    token :ASSIGN, /=/

    # FIXME: swap bitwise ops to be literal "XOR",
    #   and use single chars for other ops.
    token :BOR, /OR/
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
    token :L_SQBRC, /\[/
    token :R_SQBRC, /\]/
    token :L_BRC, /\{/
    token :R_BRC, /\}/

    #token :CHAIN, /\./
    token :SEP, /,/
    token :PIPE, /\|/


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
