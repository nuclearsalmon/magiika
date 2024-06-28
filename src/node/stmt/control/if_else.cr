module Magiika
  class Node::IfElse < Node
    def initialize(
        position : Position?,
        @condition : Node,
        @on_true : Node? = nil,
        @on_false : Node? = nil)
      super(position)
    end

    def eval(scope : Scope) : Node
      target = @condition.eval_bool(scope) ? @on_true : @on_false
      target.nil? ? Node::Nil.instance : target.eval(scope)
    end
  end
end
