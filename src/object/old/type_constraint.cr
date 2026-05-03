# For describing constraints in typing for a given field or expected type.
module Magiika
  class Object::TypeConstraint < SingletonType
    getter constrained_type : Type?
    getter? nilable : ::Bool

    protected def initialize(
      defining_scope : Scope,
      position : Position? = nil,
      @constrained_type : Type? = nil,
      @nilable : ::Bool = false,
      allow_slot : ::Bool = false
    )
      super(defining_scope: defining_scope, position: position)

      if (!allow_slot &&
          (constrained_type.is_a?(Object::Slot))
      )
        raise Error::Internal.new("#{Object::Slot} is not allowed.")
      end
    end

    def magic? : ::Bool
      @constrained_type.nil?
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
          obj_ct = obj.constrained_type

          if obj_ct.nil?
            true
          else
            @constrained_type.is_of?(obj_ct)
          end
        end
      end
      false
    end

    def create_instance(
      position : Position,
      *args, **kwargs
    ) : Instance
      self.class.new(position, *args, **kwargs).as(Instance)
    end
  end
end
