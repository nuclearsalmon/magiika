module Magiika
  class Object::RuntimeFunction < Object::Function
    @statements : Array(Ast)

    def initialize(@statements : Array(Ast), **kwargs)
      super(**kwargs)
    end

    protected def method_eval(
      method_scope : Scope
    ) : AnyObject
      result : AnyObject = Object::Nil.instance
      @statements.each { |stmt|
        result = stmt.eval(method_scope)
      }
      self.returns.try { |t| result.is_of!(t) }
      result
    end
  end
end
