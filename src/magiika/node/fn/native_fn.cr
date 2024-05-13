module Magiika
  class Node::NativeFn < Node::Fn
    include FnTemplates::DefaultCaller
    include FnTemplates::DefaultInjector
    include FnTemplates::DefaultValidator

    def initialize(
        name : String,
        params : FnParams,
        @proc : Proc(Scope::MethodScope, NodeObj),
        returns : FnRet? = nil)
      super(name, params, returns)
    end

    protected def method_eval(method_scope : Scope::MethodScope) : NodeObj
      result = @proc.call(method_scope)
    end

    def to_s_internal : String
      "native fn #{pretty_sig}"
    end
  end
end
