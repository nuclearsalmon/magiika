module Magiika
  class Node::List < TypeNode
    def initialize(@value : ::Array(Node), position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : self
      return self
    end
  end
end
