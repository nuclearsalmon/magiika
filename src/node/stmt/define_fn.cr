module Magiika
  class Node::DefFn < Node
    def initialize(
        position : Position,
        defining_scope : Scope,
        name : String,
        params : FnParams,
        @statements : Array(Node),
        returns : FnRet? = nil)
    end
  end
end