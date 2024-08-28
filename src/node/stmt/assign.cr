module Magiika
  class Node::Assign < Node
    def initialize(
        position : Position?,
        @name : String,
        @value : Node,
        @oper : String = "=")
      super(position)
    end

    private def handle_oper(value : TypeNode) : ::Nil
      case @oper
      when "="  # NOP
      else
        raise Error::Internal.new("Unknown assignment operator: \'#{@oper}\'")
      end
    end

    def eval(scope : Scope) : TypeNode
      value = @value.eval(scope)
      unless value.is_a?(TypeNode)
        raise Error::Internal.new("Expected a TypeNode, got: #{value}")
      end

      handle_oper(value)
      scope.replace(@name, value)
      return value
    end

    def eval_bool(scope : Scope) : ::Bool
      return false
    end
  end
end
