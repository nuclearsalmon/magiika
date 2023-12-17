module Magiika
  class Node::Meta < NodeClassBase
    property node : Node
    property constraints : Array(Constraint)
    property visibility : Visibility
    property static : ::Bool

    def initialize(
        @node : Node, 
        @constraints : Array(Constraint) = [] of Constraint,
        @visibility : Visibility = Visibility::Public, 
        @static : ::Bool = false)
      super(Lang::Position.new)
    end

    def is_const? : ::Bool
      @constraints.any? { |constraint| constraint.is_a?(ConstConstraint) }
    end

    def is_static? : ::Bool
      @static
    end

    def eval(scope : Scope) : Node
      @node.eval(scope)
    end
  end
end
