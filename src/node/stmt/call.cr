module Magiika
  class Node::Call < Node
    def initialize(
        @target : Node,
        @args : FnArgs,
        position : Position? = nil)
      super(position)
    end

    protected def self.call_target(
        target : Node,
        args : FnArgs,
        scope : Scope) : Node
      if target.is_a?(Node::Fn)
        target.as(Node::Fn).call_safe_raise(args, scope)
      else
        raise Error::Lazy.new(
          "Only functions are callable." +
          " Attempted to call #{target}, resulting from #{target}.")
      end
    end

    def eval(scope : Scope) : TypeNode
      target = @target.eval(scope)
      self.class.call_target(target, @args, scope)
    end
  end
end
