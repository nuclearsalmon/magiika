module Magiika
  class AstFunctionInstance < Instance
    @statements : Array(Ast)
    
    def initialize(@statements : Array(Ast), *args, **kwargs)
      super(*args, **kwargs)
    end
    
    protected def method_eval(method_scope : Scope) : Object
      result : Object = method_scope.definition(Magiika::Nil).create_instance
      @statements.each { |stmt| result = stmt.eval(method_scope) }
      @returns.try { |t| result.is_of!(t) }
      return result
    end
  end
end
