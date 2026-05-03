module Magiika
  class Ast::Call < AstBase
    include Magiika::CallerEvalFeat

    def initialize(
        @target : Ast,
        @args : Array(Ast::Argument),
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope, arg_scope : Scope? = nil) : Object
      target = @target.eval(scope)
      target = Object::Slot.unpack(target)

      arg_scope = scope if arg_scope.nil?

      args = @args.map { |arg| Object::Argument.from(arg, arg_scope) }

      if target.is_a?(Object::FunctionInstance)
        return target.as(Object::FunctionInstance).call_safe_raise(args, arg_scope)
      elsif target.is_a?(Object::Class)
        inst = target.as(Object::Class).create_instance(position: position)
        inst.run_constructor(args, arg_scope)
        return inst
      end

      raise Error::Lazy.new(
        "Only functions are callable." +
        " Attempted to call #{target}, resulting from #{target}.")
    end

    def caller_eval(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : Object
      eval(eval_scope, caller_scope)
    end

    def caller_eval_with_receiver(
        eval_scope : Scope,
        caller_scope : Scope?,
        receiver : Object) : Object
      target = @target.eval(eval_scope)
      target = Object::Slot.unpack(target)

      caller_scope = eval_scope if caller_scope.nil?

      args = Array(Object::Argument).new
      Util.obj_to_args!(receiver, args, caller_scope)
      @args.each { |arg| args << Object::Argument.from(arg, caller_scope) }

      if target.is_a?(Object::FunctionInstance)
        return target.as(Object::FunctionInstance).call_safe_raise(args, caller_scope)
      elsif target.is_a?(Object::Class)
        inst = target.as(Object::Class).create_instance(position: position)
        inst.run_constructor(args, caller_scope)
        return inst
      end

      raise Error::Lazy.new(
        "Only functions are callable." +
        " Attempted to call #{target}, resulting from #{target}.")
    end

    def caller_eval_bool(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : ::Bool
      eval_bool(eval_scope, caller_scope)
    end
  end
end
