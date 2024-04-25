module Magiika
  # Meta is a holder of Constraints
  class Node::Meta < NodeClassBase
    property data : NodeObj
    property constraints : Set(Constraint)?
    property visibility : Visibility
    property static : ::Bool

    def initialize(
        @data : NodeObj,
        @constraints : Set(Constraint)? = nil,
        @visibility : Visibility = Visibility::Public,
        @static : ::Bool = false)
      super(nil)
    end

    def is_const? : ::Bool
      constraints = @constraints
      return false if constraints.nil?
      constraints.any? { |constraint| constraint.is_a?(ConstConstraint) }
    end

    def is_static? : ::Bool
      @static
    end

    def eval(scope : Scope) : NodeObj
      @data.eval(scope)
    end
  end
end
