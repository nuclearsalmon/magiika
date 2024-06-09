module Magiika::FnTemplates
  # Default implementation of a function call.
  # Defines supporting methods which are to implemented
  # separately in a modular fashion.
  module DefaultCaller

    # ⭐ Abstract prerequisites for caller
    # ---

    # argument scope injection operation
    protected abstract def inject(
      args : Hash(String, Psuedo::TypeNode),
      scope : Scope::Fn) : ::Nil

    # evaluation operation
    protected abstract def method_eval(
      method_scope : Scope::Fn) : Psuedo::TypeNode

    # validation operation
    protected abstract def validate_result(result : Psuedo::TypeNode)


    # ⭐ Call
    # ---

    # call operation
    def call(
        args : Hash(String, Psuedo::TypeNode),
        scope : Scope) : Psuedo::TypeNode
      Scope::Fn.use(@name, scope, position) do |method_scope|
        # inject args into scope
        inject(args, method_scope)

        # perform operation
        result = method_eval(method_scope)
        validate_result(result)
        return result
      end
    end
  end
end
