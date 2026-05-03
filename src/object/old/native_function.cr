module Magiika
  class Object::NativeFunction < Object::FunctionInstance
    @proc : Proc(Scope, Object)

    def initialize(
      @proc : Proc(Scope, Object),
      *args, **kwargs
    )
      super(*args, **kwargs)
    end

    protected def method_eval(
        method_scope : Scope) : Object
      result = @proc.call(method_scope)
    end

    def to_s_internal : ::String
      "native fn #{pretty_sig}"
    end
  end
end
