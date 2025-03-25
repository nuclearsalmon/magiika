module Magiika
  class Ast::Call < AstBase
    include Magiika::CallerEvalFeat

    def initialize(
        @target : Ast,
        @args : Array(Ast::Argument),
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope, arg_scope : Scope? = nil) : AnyObject
      target = @target.eval(scope)
      target = Object::Slot.unpack(target)

      arg_scope = scope if arg_scope.nil?

      args = @args.map { |arg| Object::Argument.from(arg, arg_scope) }

      if target.is_a?(Object::Function)
        return target.as(Object::Function).call_safe_raise(args, arg_scope)
      elsif target.is_a?(Object::Class)
        inst = target.as(Object::Class).create_instance(position)
        inst.run_constructor(args, arg_scope)
        return inst
      end

      raise Error::Lazy.new(
        "Only functions are callable." +
        " Attempted to call #{target}, resulting from #{target}.")
    end

    def caller_eval(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : AnyObject
      eval(eval_scope, caller_scope)
    end

    def caller_eval_bool(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : ::Bool
      eval_bool(eval_scope, caller_scope)
    end
  end
end
