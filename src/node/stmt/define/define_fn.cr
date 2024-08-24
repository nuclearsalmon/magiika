module Magiika
  class Node::DefFn < Node
    getter name : String
    getter returns : FnRet?
    def static? : ::Bool; @static; end

    def initialize(
        @static : ::Bool,
        @name : String,
        @params : FnParams,
        @statements : Array(Node),
        @returns : FnRet? = nil,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      fn = Node::StmtsFn.new(
        scope,
        @static,
        @name,
        @params,
        @statements,
        @returns,
        @position
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