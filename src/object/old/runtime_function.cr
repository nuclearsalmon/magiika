module Magiika
  class Object::RuntimeFunction < Object::FunctionInstance
    @statements : Array(Ast)

    def initialize(
      @statements : Array(Ast), 
      *args, **kwargs
    )
      super(*args, **kwargs)
    end

    protected def method_eval(
      method_scope : Scope
    ) : Object
      result : Object = method_scope.definition(Object::Nil).create_instance
      @statements.each { |stmt|
        result = stmt.eval(method_scope)
      }
      self.returns.try { |t| result.is_of!(t) }
      result
    end
  end
end
