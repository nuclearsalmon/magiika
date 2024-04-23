module Magiika
  class Node::List < NodeClassBase
    def initialize(@value : ::Array(Node), position : Lang::Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : self
      return self
    end
  end
end
