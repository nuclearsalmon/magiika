module Magiika::Error
  # ✨ Internal, typically non-recoverable errors.
  # --------------------------------------------------------

  # not implemented
  class NotImplemented < Exception
    def initialize(message : ::String? = nil, cause : Exception? = nil)
      super("Not implemented#{message.nil? ? "." : ": " + message }", cause)
    end

    def to_s
      return inspect_with_backtrace
    end
  end

  class NotImplementedMacro < NotImplemented
    def initialize(message : ::String? = nil, cause : Exception? = nil)
      super("Should have been implemented via macro#{message.nil? ? "." : ": " + message }", cause)
    end
  end

  # an error for when im too lazy to be giving the code a proper error type
  class Lazy < Exception
    def initialize(message : ::String, cause : Exception? = nil)
      super(message, cause)
    end

    def to_s
      return inspect_with_backtrace
    end
  end

  # a general, probably non-recoverable error
  class Internal < Exception
    def initialize(message : ::String, cause : Exception? = nil)
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
    def initialize(errors : Array(::String))
      error_string = Util.terminated_concat(errors)
      super(error_string)
    end
  end


  # ✨ User-facing, expected and potentially recoverable errors.
  # --------------------------------------------------------

  # user-facing, expected and potentially recoverable error
  abstract class Safe < Exception
    getter title, position

    def initialize(
        @title : ::String,
        @message : ::String,
        @position : Position? = nil)
      super(message)
    end

    def to_s : ::String
      position = @position

      message = @message.as(::String)
      #message = "#{@title}"
      message += " @ #{position.to_s}" unless position.nil?
      #message += "\n\n   #{@message}"

      return message
    end
  end

  # does not follow naming convention
  class NamingConvention < Safe
    def initialize(
        @message : ::String,
        @position : Position? = nil)
      super(
        "NAMING CONVENTION",
        message,
        position)
    end
  end

  # missing character in syntax
  class ExpectedCharacter < Safe
    def initialize(
        @message : ::String,
        @position : Position? = nil)
      super(
        "EXPECTED CHARACTER",
        message,
        position)
    end
  end

  # expected one type, got another
  class Type < Safe
    def initialize(
        found_type : AnyObject,
        expected_type : AnyObject,
        message : ::String? = nil,
        position : Position? = nil)
      full_message = "Type error"
      full_message += ": '#{message}'" unless message.nil?
      full_message += "."
      full_message += "\nFound: '#{found_type.type_name}'"
      full_message += "\nExpected: '#{expected_type.type_name}'"

      super(
        "TYPE ERROR",
        full_message,
        position)
    end
  end

  # attempted to access an undefined variable
  class UndefinedVariable < Safe
    def initialize(
        name : ::String,
        scope : Scope,
        position : Position? = nil)
      super(
        "UNDEFINED VARIABLE",
        "Undefined variable: '#{name}'",
        position)
    end
  end

  class UndefinedMethod < Safe
    def initialize(
        name : ::String,
        target : AnyObject? = nil,
        position : Position? = nil)
      super(
        "UNDEFINED METHOD",
        "Undefined method: \"#{name}\"" +
        (target.nil? ? "" : " on #{target.type_name}"),
        position)
    end
  end
end
