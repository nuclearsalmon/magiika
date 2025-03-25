module Magiika
  class Ast::Assign < AstBase
    def initialize(
        position : Position?,
        @name : ::String,
        @value : Ast,
        @oper : ::String = "=")
      super(position)
    end

    def eval(scope : Scope) : AnyObject
      value = @value.eval(scope)
      
      case @oper
      when "="  # NOP
      else
        raise Error::Internal.new("Unknown assignment operator: \'#{@oper}\'")
      end

      scope.replace(@name, value)
      return value
    end
  end
end
