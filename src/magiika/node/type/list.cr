module Magiika 
  class Node::List < NodeClassBase
    def initialize(@value : ::Array(Node), position : Lang::Position)
      super(position)
    end

    def to_s
      return @value.to_s
    end

    def eval(scope : Scope) : self
      return self
    end
  end
end
