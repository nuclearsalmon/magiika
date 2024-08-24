module Magiika
  class Node::DefineVar < Node
    @name : String
    @value : Node
    @unresolved_type : EvalType?
    @access : Access

    def initialize(
        position : Position?,
        @static : ::Bool,
        @name : ::String,
        @value : Node,
        @unresolved_type : EvalType? = nil,
        @access : Access = Access::Public)
      super(position)
    end

    def static? : ::Bool
      @static
    end

    def eval(scope : Scope) : TypeNode
      value = @value.eval(scope)

      unless value.is_a?(TypeNode)
        raise Error::Internal.new("Expected a TypeNode, got: #{value}")
      end

      if scope.exist?(@name)
        raise Error::Internal.new("Variable already exists: \'#{@name}\'")
      end

      unresolved_type = @unresolved_type
      resolved_type = (unresolved_type.nil? ? nil :
        unresolved_type.eval_type(scope))

      meta = Node::Meta.new(
        value: value,
        resolved_type: resolved_type,
        descriptors: nil,
        access: @access)

      scope.set(@name, meta)

      return value
    end

    def eval_bool(scope : Scope) : ::Bool
      return false
    end
  end
end
