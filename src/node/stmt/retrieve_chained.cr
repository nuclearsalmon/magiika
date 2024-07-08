module Magiika
  class Node::ChainedRetrieve < Node::Retrieve
    def initialize(
        @on_node : Node,
        ident : String,
        position : Position? = nil)
      super(ident, position)
    end

    def eval(scope : Scope) : Node
      source = @on_node.eval(scope)

      unless source.responds_to?(:scope)
        raise Error::Lazy.new("not callable")
      end

      super.eval(source.scope)
    end
  end
end
