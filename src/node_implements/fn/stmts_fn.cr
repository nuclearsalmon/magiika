module Magiika
  class Node::StmtsFn < Node::Fn
    include FnTemplates::DefaultCaller
    include FnTemplates::DefaultInjector
    include FnTemplates::DefaultValidator

    def initialize(
        position : Position,
        name : String,
        params : FnParams,
        @statements : Array(Psuedo::Node),
        returns : FnRet? = nil)
      super(position, name, params, returns)
    end

    protected def method_eval(method_scope : Scope::Fn) : Psuedo::TypeNode
      result : Psuedo::Node? = nil
      @statements.each { |stmt|
        result = stmt.eval(method_scope)
      }
      if result.nil? || !result.is_a?(Psuedo::TypeNode)
        Node::Nil.instance
      else
        result
      end
    end
  end
end
