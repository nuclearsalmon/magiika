module Magiika
  class Node::Call < Node
    def initialize(
        @target : Node,
        @args : FnArgs,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope, arg_scope : Scope ? = nil) : TypeNode
      target = @target.eval(scope)

      arg_scope = scope if arg_scope.nil?

      if target.is_a?(Node::Fn)
        target.as(Node::Fn).call_safe_raise(@args, arg_scope)
      else
        raise Error::Lazy.new(
          "Only functions are callable." +
          " Attempted to call #{target}, resulting from #{target}.")
      end
    end
  end
end
