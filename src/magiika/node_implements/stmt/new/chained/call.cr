module Magiika
  class Node::ChainedCall < NodeClass
    def initialize(
        @on_node : Psuedo::Node,
        @ident : String,
        @args : FnArgs,
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

      unless target.is_a?(Node::Fn)
        raise Error::Lazy.new("not callable")
      end

      target.call_safe_raise(@args, scope)
    end
  end
end
