module Magiika
  class Object::BoolInstance < Instance
    def initialize(
      @value : ::Bool, 
      type : Object::Bool,
      position : Position? = nil
    )
      super(type, position)
    end

    def to_s_internal : ::String
      return @value.to_s
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value
    end
  end

  class Object::Bool < GenericType(Object::BoolInstance)
  end
end
