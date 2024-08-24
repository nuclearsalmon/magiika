module Magiika
  class Node::NativeFn < Node::Fn
    def initialize(
        defining_scope : Scope,
        name : String,
        params : FnParams,
        @proc : Proc(Scope::Fn, TypeNode),
        returns : FnRet? = nil)
      super(defining_scope, true, name, params, returns)
    end

    protected def method_eval(
        method_scope : Scope) : TypeNode
      result = @proc.call(method_scope)
    end

    def to_s_internal : String
      "native fn #{pretty_sig}"
    end
  end
end
