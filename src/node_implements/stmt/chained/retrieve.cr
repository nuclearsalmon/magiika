module Magiika
  class Node::ChainedRetrieve < NodeClass
    def initialize(
        @on_node : Psuedo::Node,
        @ident : String,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : Psuedo::Node
      source = @on_node.eval(scope)

      unless source.is_a?(Psuedo::TypeNode)
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
