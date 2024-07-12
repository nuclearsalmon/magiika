module Magiika
  class Node::DefFn < Node
    def initialize(
        position : Position,
        @name : String,
        @params : FnParams,
        @statements : Array(Node),
        @returns : FnRet? = nil)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      fn = Node::StmtsFn.new(
        position,
        scope,
        @name,
        @params,
        @statements,
        @returns
      )
      assign = Node::Assign.new(
        nil,
        @name,
        fn,
        AssignMode::Any)
      assign.eval(scope)
    end
  end
end