module Magiika::FnTemplates
  module DefaultCaller
    protected abstract def inject(args : Hash(String, NodeObj), scope : Scope::MethodScope)

    protected abstract def method_eval(method_scope : Scope::MethodScope) : NodeObj

    protected abstract def validate_result(result : NodeObj)

    def call(args : Hash(String, NodeObj), scope : Scope) : NodeObj
      # create scope for this operation
      method_scope = Scope::MethodScope.new(@name, position, scope)

      # inject args into scope
      inject(args, method_scope)

      # perform operation
      result = method_eval(method_scope)
      validate_result(result)
      return result
    end
  end
end
