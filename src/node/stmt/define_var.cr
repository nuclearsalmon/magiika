module Magiika
  class Node::DefineVar < Node
    def initialize(
        position : Position?,
        @ident : String,
        @value : Node,
        @_type : Node? = nil,
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

      meta = NodeMeta.new(
        value: value,
        _type: @type,
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
