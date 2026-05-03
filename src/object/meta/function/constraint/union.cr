module Magiika
  class UnionInstance < Instance
    getter constraints : Set(ConstraintInstance)
    
    def initialize(
      instance_type : Constraint,
      @constraints : Set(constraints),
      position : Position? = nil
    )
      super(type: instance_type, position: position)
    end
    
    def is_of?(other : Object) : ::Bool
      super(other) || @constraints.any? { |obj| obj.is_of?(other) }
    end
  end
  
  class Union < GenericType(UnionInstance)
  end
end
