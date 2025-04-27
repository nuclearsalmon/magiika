module Magiika
  class Object::NativeFunction < Object::Function
    # NOTE: This is a bit of a hack to allow the compiler
    #       to infer the correct type for the proc.
    @proc : Proc(Scope, AnyObject) | Proc(Scope, Object) | Proc(Scope, Object.class)

    def initialize(@proc : Proc(Scope, AnyObject), *args, **kwargs)
      super(*args, **kwargs, defining_scope: nil)
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
