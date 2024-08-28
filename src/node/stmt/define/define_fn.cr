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
        @access : Access = Access::Public,
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

      meta = Node::Meta.new(
        value: fn,
        resolved_type: nil,  # fixme : fn type
        descriptors: nil,
        access: @access)

      scope.define(@name, meta)
      return fn
    end
  end
end