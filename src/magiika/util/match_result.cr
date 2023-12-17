module Magiika
  class MatchResult
    property errors : Array(String)
  
    def initialize(
        @matched : Bool, 
        @errors : Array(String) = [] of String)
    end
  
    def add_error(error : String)
      @errors << error
    end
  
    def merge!(other : MatchResult)
      @errors.concat(other.errors)
    end

    def matched?
      @matched && @errors.empty?
    end

    def errors?
      @errors.empty?
    end

    def defer_raise : Error::InternalMatchFail?
      return if matched?
      @errors << "Failed to match" if @errors.empty?
      return Error::InternalMatchFail.new(@errors)
    end

    def raise : Nil
      ex = defer_raise
      raise ex unless ex.nil?
    end
  end
end
