module Magiika
  class Node::ChainedRetrieve < Node
    def initialize(
        @on_node : Node,
        @ident : String,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Node
      source = @on_node.eval(scope)

      unless source.is_a?(TypeNode)
        raise Error::Lazy.new("expected typenode")
      end

      target = source[@ident]?

      if target.nil?
        raise Error::Lazy.new("not found")
      end

      target
    end
  end
end
