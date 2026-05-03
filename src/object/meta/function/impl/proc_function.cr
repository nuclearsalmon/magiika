module Magiika
  class ProcFunctionInstance < Instance
    @proc : Proc(Scope, Object)

    def initialize(@proc : Proc(Scope, Object), *args, **kwargs)
      super(*args, **kwargs)
    end

    protected def method_eval(method_scope : Scope) : Object
      @proc.call(method_scope)
    end
  end
end
