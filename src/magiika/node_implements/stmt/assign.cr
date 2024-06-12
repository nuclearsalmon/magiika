module Magiika
  enum AssignMode
    Declare  # declare a new value (no pre-existing value)
    Replace  # replace an existing value
    Any      # any of the modes, doesn't care
  end

  class Node::Assign < NodeClass
    def initialize(
        position : Position?,
        @ident : String,
        @value : Psuedo::Node,
        @mode : AssignMode = AssignMode::Any,
        @oper : String = "=")
      super(position)
    end

    def eval(scope : Scope) : Psuedo::TypeNode
      value = @value.eval(scope)

      unless value.is_a?(Psuedo::TypeNode)
        raise Error::Internal.new("Expected a Psuedo::TypeNode, got: #{value}")
      end

      if @mode == AssignMode::Declare && scope.exist?(@ident)
        raise Error::Internal.new("Variable already exists: \'#{@ident}\'")
      end
      if @mode == AssignMode::Replace && !scope.exist?(@ident)
        raise Error::Internal.new("Variable does not exist: \'#{@ident}\'")
      end

      case @oper
      when "="
        scope.set(@ident, value)
      else
        raise Error::Internal.new("Unknown assignment operator: \'#{@oper}\'")
      end

      return value
    end

    def eval_bool(scope : Scope) : ::Bool
      return False
    end
  end
end
