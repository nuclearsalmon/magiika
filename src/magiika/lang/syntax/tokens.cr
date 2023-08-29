module Magiika::Lang::Syntax
  #extend self
  
  protected def register_tokens
    # comments
    #token(:COMMENT, /\#.*$/)
    #token(:COMMENT, /\/\*([^*]|\r?\n|(\*+([^*\/]|\r?\n)))*\*+\//)
    #token(:DOC_COMMENT, /\/\*\*(\r?\n|(\*+([^*\/]|\r?\n)))*\*\*+\//)

    # keywords
    #token(:CONST, /const/)

    # operators
    token(:DEFINE, /:/)
    token(:ASSIGN, /=/)
    #token(:INLINE_ASSIGN, /:=/)

    # literals
    token(:BOOL, /(true|false)/)
    token(:FLT, /\d+\.\d+/)
    token(:INT, /[\+\-]?\d+/)
    #token(:STR, /"([^"\\]*(?:\\.[^"\\]*)*)"/)
    #token(:STR, /'([^'\\]*(?:\\.[^'\\]*)*)'/)

    # names
    token(:NAME, /([A-Za-z_][A-Za-z0-9_]*)/)

    # whitespace (run this last to allow for whitespace-sensitive tokens)
    token(:TAB, /\t| {2}+/)
    token(:SPACE, / +/)
    token(:LINE_SEGMENT, /\\[\t ]*\r?\n/)
    token(:NEWLINE, /\r?\n/)
    token(:INLINE_NEWLINE, /;/)
  end
end
