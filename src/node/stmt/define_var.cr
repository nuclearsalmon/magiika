module Magiika
  class Node::DefineVar < Node
    @ident : String
    @value : Node
    @unresolved_type : EvalType?
    @visibility : Visibility

    def initialize(
        position : Position?,
        @ident : ::String,
        @value : Node,
        @unresolved_type : EvalType? = nil,
        @visibility : Visibility = Visibility::Public)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      value = @value.eval(scope)

      unless value.is_a?(TypeNode)
        raise Error::Internal.new("Expected a TypeNode, got: #{value}")
      end

      if scope.exist?(@ident)
        raise Error::Internal.new("Variable already exists: \'#{@ident}\'")
      end

      unresolved_type = @unresolved_type
      resolved_type = (unresolved_type.nil? ? nil : 
        unresolved_type.eval_type(scope))

      meta = Node::Meta.new(
        value: value,
        resolved_type: resolved_type,
        descriptors: nil,
        visibility: @visibility)

      scope.set(@ident, meta)

      return value
    end

    def eval_bool(scope : Scope) : ::Bool
      return false
    end
  end
end
