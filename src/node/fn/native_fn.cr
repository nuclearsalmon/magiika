module Magiika
  class Node::NativeFn < Node::Fn
    include FnTemplates::DefaultCaller
    include FnTemplates::DefaultInjector
    include FnTemplates::DefaultValidator

    def initialize(
        defining_scope : Scope,
        name : String,
        params : FnParams,
        @proc : Proc(Scope::Fn, TypeNode),
        returns : FnRet? = nil)
      super(defining_scope, name, params, returns)
    end

    protected def method_eval : TypeNode
      result = @proc.call(@defining_scope)
    end

    def to_s_internal : String
      "native fn #{pretty_sig}"
    end
  end
end
