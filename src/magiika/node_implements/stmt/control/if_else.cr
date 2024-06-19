module Magiika
  class Node::IfElse < NodeClass
    def initialize(
        position : Position?,
        @condition : Psuedo::Node,
        @on_true : Psuedo::Node? = nil,
        @on_false : Psuedo::Node? = nil)
      super(position)
    end

    def eval(scope : Scope) : Psuedo::Node
      target = @condition.eval_bool(scope) ? @on_true : @on_false
      target.nil? ? Node::Nil.instance : target.eval(scope)
    end
  end
end
