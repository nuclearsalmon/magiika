module Magiika::FnTemplates
  # Default implementation of a function call.
  # Defines supporting methods which are to implemented
  # separately in a modular fashion.
  module DefaultCaller

    # ⭐ Abstract prerequisites for caller
    # ---

    # argument scope injection operation
    protected abstract def inject(args : Hash(String, TypeNode)) : ::Nil

    # evaluation operation
    protected abstract def method_eval : TypeNode

    # validation operation
    protected abstract def validate_result(result : TypeNode)


    # ⭐ Call
    # ---

    # call operation
    def call(args : Hash(String, TypeNode)) : TypeNode
      Scope::Fn.use(@name, @defining_scope, position) do |method_scope|
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
