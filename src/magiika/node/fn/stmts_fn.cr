module Magiika
  class Node::StmtsFn < Node::Fn
    include FnTemplates::DefaultCaller
    include FnTemplates::DefaultInjector
    include FnTemplates::DefaultValidator

    def initialize(
        position : Lang::Position,
        name : String,
        params : FnParams,
        @statements : Array(NodeObj),
        returns : FnRet? = nil)
      super(position, name, params, returns)
    end

    protected def method_eval(method_scope : Scope::MethodScope) : NodeObj
      result = Node::Nil.instance
      @statements.each { |stmt|
        result = stmt.eval(method_scope)
      }
      result
    end
  end
end
