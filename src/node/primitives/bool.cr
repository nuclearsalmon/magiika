module Magiika
  class Node::Bool < TypeNode::ClassTyping
    include Psuedo::Resolved

    def initialize(@value : ::Bool, position : Position)
      super(position)
    end

    def to_s_internal : String
      return @value.to_s
    end

    def eval(scope : Scope) : self
      return self
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value
    end
  end
end
