module Magiika
  class Node::Call < Node
    include CallerEvalFeat

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
        return target.as(Node::Fn).call_safe_raise(@args, arg_scope)
      elsif target.is_a?(Node::Cls)
        return ClsInst.new(target.as(Node::Cls), @args, position)
      end

      raise Error::Lazy.new(
        "Only functions are callable." +
        " Attempted to call #{target}, resulting from #{target}.")
    end

    def caller_eval(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : TypeNode
      eval(eval_scope, caller_scope)
    end

    def caller_eval_bool(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : ::Bool
      eval_bool(eval_scope, caller_scope)
    end
  end
end
