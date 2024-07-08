module Magiika
  class Node::StmtsFn < Node::Fn
    include FnTemplates::DefaultCaller
    include FnTemplates::DefaultInjector
    include FnTemplates::DefaultValidator

    def initialize(
        position : Position,
        defining_scope : Scope,
        name : String,
        params : FnParams,
        @statements : Array(Node),
        returns : FnRet? = nil)
      super(position, defining_scope, name, params, returns)
    end

    protected def method_eval : TypeNode
      result : Node? = nil
      @statements.each { |stmt|
        result = stmt.eval(@defining_scope)
      }
      if result.nil? || !result.is_a?(TypeNode)
        Node::Nil.instance
      else
        result
      end
    end
  end
end
