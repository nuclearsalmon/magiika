module Magiika::Error
  class Internal < Exception
    def initialize(message : String)
      super(message)
    end

    def to_s
      return inspect_with_backtrace
    end
  end

  class Safe < Exception
    def initialize(
        title : String,
        message : String,
        position : Lang::Position)

      @title = title
      @message = message + "\n"
      @position = position

      super(message)
    end
  end

  class UnexpectedCharacter < Safe
    def initialize(character : Char, position : Lang::Position)
      super(
        "UNEXPECTED CHARACTER",
        "Unexpected character: '#{character}'",
        position)
    end
  end

  class UnexpectedSymbol < Safe
    def initialize(symbol : Symbol, position : Lang::Position)
      super(
        "UNEXPECTED SYMBOL",
        "Unexpected symbol: '#{symbol}'",
        position)
    end
  end

  class ExpectedEnd < Safe
    def initialize(symbol : Symbol, position : Lang::Position)
      super(
        "EXPECTED END",
        "Expected end. Unexpected symbol: '#{symbol}'",
        position)
    end
  end

  class UnexpectedEnd < Safe
    def initialize(symbol : Symbol, position : Lang::Position)
      super(
        "UNEXPECTED END",
        "Unexpected end. Expected a symbol after: '#{symbol}'",
        position)
    end
  end

  class UndefinedVariable < Safe
    def initialize(
        ident : Lang::MatchedToken,
        scope : Magiika::Scope::Scope,
        position : Lang::Position)
      super(
        "UNDEFINED VARIABLE",
        "Undefined variable: '#{ident.value}'",
        position
      )
    end
  end
end
