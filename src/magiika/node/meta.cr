module Magiika
  # Metadata for a stored Node
  class Node::Meta < NodeClassBase
    property data : NodeObj
    property constraints : Set(Constraint)?
    property visibility : Visibility

    def initialize(
        @data : NodeObj,
        @_type : NodeType? = nil,
        #@constraints : Set(Constraint)? = nil,
        @visibility : Visibility = Visibility::Public,
        @static : ::Bool = false)
      verify_type!
      super(nil)
    end

    def type? : NodeType?
      @_type
    end

    def type=(_type : NodeType)
      @_type = _type
    end

    def verify_type(node : NodeObj) : ::Bool
      _type = @_type
      return Typing.type?(node, _type) unless _type.nil?
      true
    end

    def verify_type!(node : NodeObj)
      raise Error::InternalType.new unless verify_type(node)
    end

    private def verify_type!
      verify_type!(@data)
    end

    def magic? : ::Bool
      @_type.nil?
    end

    def const? : ::Bool
      false
      #constraints = @constraints
      #return false if constraints.nil?
      #constraints.any? { |constraint| constraint.is_a?(ConstConstraint) }
    end

    def static? : ::Bool
      @static
    end

    def eval(scope : Scope) : NodeObj
      @data.eval(scope)
    end
  end
end
