module Magiika
  class Node::StmtsFn < Node::Fn
    def initialize(
        position : Lang::Position,
        name : String,
        params : FnParams,
        @statements : Array(NodeObj),
        returns : FnRet? = nil)
      super(position, name, params, returns)
    end

    def call(args : Hash(String, NodeObj), scope : Scope) : NodeObj
      # TODO inject args into scope

      result = @statements.each { |stmt|
        next stmt.eval(scope)
      }

      # TODO typecheck
      # TODO metawrap

      # handle compiler error
      raise Error::Internal.new("Unexpected nil.") if result.nil?
      return result
    end
  end
end
