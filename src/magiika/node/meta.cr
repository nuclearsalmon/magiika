module Magiika
  # Meta is a holder of Constraints
  class Node::Meta < NodeClassBase
    property data : Node
    property constraints : Set(Constraint)?
    property visibility : Visibility
    property static : ::Bool

    def initialize(
        @data : Node,
        @constraints : Set(Constraint)? = nil,
        @visibility : Visibility = Visibility::Public,
        @static : ::Bool = false)
      super(Lang::Position.new)
    end

    def is_const? : ::Bool
      constraints = @constraints
      return false if constraints.nil?
      constraints.any? { |constraint| constraint.is_a?(ConstConstraint) }
    end

    def is_static? : ::Bool
      @static
    end

    def eval(scope : Scope) : Node
      @data.eval(scope)
    end
  end
end
