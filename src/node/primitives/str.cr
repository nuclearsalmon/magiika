module Magiika
  class Node::Str < TypeNode::ClassTyping
    include Psuedo::Resolved

    protected getter value : ::String

    def initialize(@value : ::String, position : Position? = nil)
      super(position)
    end

    def to_s_internal : ::String
      "\"#{@value}\""
    end

    def eval(scope : Scope) : Node::Str
      self
    end

    def eval_bool(scope : Scope) : ::Bool
      @value != ""
    end
  end
end
