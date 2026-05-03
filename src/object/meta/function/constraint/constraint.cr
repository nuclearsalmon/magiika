module Magiika
  class ConstraintInstance < Instance
    getter expected_object : Object?
    getter? nilable : ::Bool
    
    protected def initialize(
      instance_type : Constraint,
      @expected_object : Object? = nil,
      @nilable : ::Bool = false,
      position : Position? = nil
    )
      super(type: instance_type, position: position)
    end
    
    def magic? : ::Bool
      @expected_object.nil?
    end
    
    def is_of?(obj) : ::Bool
      if self.magic?
        if obj.is_a?(Object::Nil)
          self.nilable?
        else
          true
        end
      elsif obj.is_a?(Object::Nil)
        self.nilable?
      elsif obj.is_a?(Object::TypeConstraint)
        if (obj.nilable? == self.nilable?)
          obj_ct = obj.expected_object

          if obj_ct.nil?
            true
          else
            @expected_object.is_of?(obj_ct)
          end
        end
      end
      false
    end
  end
  
  class Constraint < GenericType(ConstraintInstance)
  end
end
