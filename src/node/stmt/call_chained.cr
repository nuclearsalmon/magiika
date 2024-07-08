module Magiika
  class Node::ChainedCall < Node
    def initialize(
        @on_node : Node,
        @ident : String,
        @args : FnArgs,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Node
      source = @on_node.eval(scope)

      if (!(source.responds_to?(:scope)) || \
          (target = source.scope.get?(@ident)).nil?)
        raise Error::Lazy.new("not found")
      end

      target = target.try(&.value)
      call_target(target, @args, scope)
    end
  end
end
