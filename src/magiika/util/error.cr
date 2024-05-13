require "./algo.cr"


module Magiika::Error
  # ✨ Internal, typically non-recoverable errors.
  # --------------------------------------------------------

  # not implemented
  class NotImplemented < Exception
    def initialize(message : String? = nil, cause : Exception? = nil)
      super("Not implemented#{message.nil? ? "." : ": " + message }", cause)
    end

    def to_s
      return inspect_with_backtrace
    end
  end

  # an error for when im too lazy to be giving the code a proper error type
  class Lazy < Exception
    def initialize(message : String, cause : Exception? = nil)
      super(message, cause)
    end

    def to_s
      return inspect_with_backtrace
    end
  end

  # a general, probably non-recoverable error
  class Internal < Exception
    def initialize(message : String, cause : Exception? = nil)
      super(message, cause)
    end

    def to_s
      return inspect_with_backtrace
    end
  end

  # when a type error occurs internally
  class InternalType < Internal
    def initialize
      super("Incorrect type.")
    end
  end

  # when a match fail occurs internally (and is probably not recoverable)
  class InternalMatchFail < Internal
    def initialize(errors : Array(String))
      error_string = Util.terminated_concat(errors)
      super(error_string)
    end
  end

  # an unrecoverable parsing error
  class SevereParserError < Internal
    def initialize(
        parser : Lang::Parser,
        cause : Exception,
        message : String? = nil)
      new_message = (
        "An error occured during parsing." +
        (message.nil? ? "" : " #{message}") +
        "\n---\nParser cache: \n#{parser.cache.pretty_inspect}\n---\n")
      super(new_message, cause)
    end
  end


  # ✨ User-facing, expected and potentially recoverable errors.
  # --------------------------------------------------------

  # user-facing, expected and potentially recoverable error
  class Safe < Exception
    getter title, position
    def initialize(
        @title : String,
        @message : String,
        @position : Lang::Position? = nil)
      super(message)
    end

    def to_s : String
      position = @position

      message = @message.as(String)
      #message = "#{@title}"
      message += " @ #{position}" unless position.nil?
      #message += "\n\n   #{@message}"

      return message
    end

    def to_s(io : IO) : Nil
      io << to_s
    end

    def inspect_with_backtrace : String
      to_s
    end

    def inspect_with_backtrace(io : IO) : Nil
      to_s(io)
    end
  end

  # expected one type, got another
  class Type < Safe
    def initialize(
        found_type : NodeType,
        expected_type : NodeType,
        message : String? = nil,
        position : Lang::Position? = nil)
      full_message = "Type error"
      full_message += ": '#{message}'" unless message.nil?
      full_message += "."
      full_message += "\nFound: '#{found_type}.type_name'"
      full_message += "\nExpected: '#{expected_type}.type_name'"

      super(
        "TYPE ERROR",
        full_message,
        position)
    end
  end

  # minor parsing error
  class SafeParsingError < Safe
    def initialize(
        message : String,
        position : Lang::Position? = nil)
      super(
        "PARSER ERROR",
        message,
        position)
    end
  end

  # unexpected character when parsing
  class UnexpectedCharacter < Safe
    def initialize(
        character : Char,
        position : Lang::Position? = nil)
      super(
        "UNEXPECTED CHARACTER",
        "Unexpected character: '#{character}'",
        position)
    end
  end

  # FIXME: unused
  # unexpected symbol when parsing
  class UnexpectedSymbol < Safe
    def initialize(
        symbol : Symbol,
        position : Lang::Position? = nil)
      super(
        "UNEXPECTED SYMBOL",
        "Unexpected symbol: '#{symbol}'",
        position)
    end
  end

  # FIXME: unused
  # expected end when parsing
  class ExpectedEnd < Safe
    def initialize(
        symbol : Symbol,
        position : Lang::Position? = nil)
      super(
        "EXPECTED END",
        "Expected end. Unexpected symbol: '#{symbol}'",
        position)
    end
  end

  # FIXME: unused
  # expected end when parsing
  class UnexpectedEnd < Safe
    def initialize(
        symbol : Symbol,
        position : Lang::Position? = nil)
      super(
        "UNEXPECTED END",
        "Unexpected end. Expected a symbol after: '#{symbol}'",
        position)
    end
  end

  # attempted to access an undefined variable
  class UndefinedVariable < Safe
    def initialize(
        ident : String,
        scope : Scope,
        position : Lang::Position? = nil)
      super(
        "UNDEFINED VARIABLE",
        "Undefined variable: '#{ident}'",
        position)
    end
  end

  class UndefinedMethod < Safe
    def initialize(
        ident : String,
        position : Lang::Position? = nil)
      super(
        "UNDEFINED METHOD",
        "Undefined method: '#{ident}'",
        position)
    end
  end
end
