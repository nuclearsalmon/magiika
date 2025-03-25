module Magiika
  class Object::NativeFunction < Object::Function
    @proc : Proc(Scope, AnyObject) | Proc(Scope, Object) | Proc(Scope, Object.class)

    def initialize(@proc : Proc(Scope, AnyObject), *args, **kwargs)
      super(*args, **kwargs)
    end

    protected def method_eval(
        method_scope : Scope) : AnyObject
      result = @proc.call(method_scope)
    end

    def to_s_internal : ::String
      "native fn #{pretty_sig}"
    end
  end
end
