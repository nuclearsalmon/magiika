module Magiika
  # A control verb. Used for return, break, etc
  abstract class Node::Control < Node
    getter value : Node?

    def initialize(
        position : Position?,
        @value : Node?)
      super(position)
    end

    def eval(scope : Scope) : Node
      (value = @value).nil? ? Node::Nil.instance : value.eval(scope)
    end
  end

  class Node::Return < Node::Control; end
  class Node::Break < Node::Control; end
  class Node::Next < Node::Control; end
end
