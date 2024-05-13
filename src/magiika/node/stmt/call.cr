module Magiika
  class Node::Call < NodeClassBase
    def initialize(
        position : Lang::Position?,
        @target : NodeObj,
        @args : FnArgs)
      super(position)
    end

    def eval(scope : Scope) : NodeObj
      target = @target.eval(scope)
      if target.is_a?(Node::Fn)
        target.as(Node::Fn).call_safe_raise(@args, scope)
      else
        raise Error::Lazy.new(
          "Only functions are callable." +
          " Attempted to call #{target}, resulting from #{@target}.")
      end
    end

    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end
  end
end
