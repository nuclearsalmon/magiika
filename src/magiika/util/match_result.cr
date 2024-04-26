module Magiika
  class MatchResult
    def initialize(
        @matched : Bool,
        @errors : Array(String)? = nil)
    end

    def errors
      errors = @errors
      if errors.nil?
        errors = Array(String).new
        @errors = errors
      end
      errors
    end

    def add_error(error : String)
      errors << error
    end

    def merge!(other : MatchResult)
      errors.concat(other.errors)
    end

    def matched?
      @matched && errors.empty?
    end

    def errors? : Array(String)?
      @errors
    end

    def has_errors? : ::Bool
      _errors = @errors
      if _errors.nil?
        false
      elsif _errors.empty?
        false
      else
        true
      end
    end

    def defer_raise : Error::InternalMatchFail?
      return if matched?
      errors << "Failed to match" if !has_errors?
      return Error::InternalMatchFail.new(errors)
    end

    def raise : Nil
      ex = defer_raise
      raise ex unless ex.nil?
    end
  end
end
