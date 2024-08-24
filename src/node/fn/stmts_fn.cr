module Magiika
  class Node::StmtsFn < Node::Fn
    def initialize(
        defining_scope : Scope,
        static : ::Bool,
        name : String,
        params : FnParams,
        @statements : Array(Node),
        returns : FnRet? = nil,
        position : Position? = nil)
      super(defining_scope, static, name, params, returns, position)
    end

    protected def method_eval(
        method_scope : Scope) : TypeNode
      result : Node? = nil
      @statements.each { |stmt|
        result = stmt.eval(method_scope)
      }
      if result.nil? || !result.is_a?(TypeNode)
        Node::Nil.instance
      else
        result
      end
    end
  end
end
