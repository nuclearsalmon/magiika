module Magiika
  class Node::NativeMemberFn < Node::NativeFn
    def initialize(
        @parent : NodeObj,
        name : String,
        params : FnParams,
        proc : Proc(Scope::MethodScope, NodeObj),
        returns : FnRet? = nil)
      super(name, params, proc, returns)
    end

    protected def inject(args : Hash(String, NodeObj), scope : Scope::MethodScope)
      super
      scope.set("self", @parent)
      raise "test"
    end

    def to_s_internal : String
      "native fn #{pretty_sig}"
    end
  end
end
