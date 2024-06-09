module Magiika
  class Node::List < TypeNodeClass::ClassTyping
    def initialize(@value : ::Array(Psuedo::Node), position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : self
      return self
    end
  end
end
