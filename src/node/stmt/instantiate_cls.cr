module Magiika
  class Node::InstantiateCls < Node
    def initialize(
        @ident : String,
        @args : FnArgs,
        position : Position?)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      cls_src = scope.get(@ident)

      if cls_src.is_a?(Node::ClsInst)
        raise Error::Lazy.new("instantiation only works with a class definition, not a class instance")
      end

      Util.is_a!(cls_src, Node::Cls)
      cls_src = cls_src.as(Node::Cls)

      if cls_src.abstract?
        raise Error::Lazy.new("cannot instantiate abstract class")
      end

      # resolve args in scope beforehand
      @args.each { |arg|
        arg.value = arg.value.eval(scope)
      }

      return Node::ClsInst.new(cls_src, @args, @position)
    end

    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end
  end
end
