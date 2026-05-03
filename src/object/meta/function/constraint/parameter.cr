module Magiika
  class ParameterInstance < Instance
    getter name : ::String
    getter expected_value : Object?
    getter default_value : Object?
    
    def initialize(
      type_instance : Parameter,
      @name : ::String,
      @expected_value : Object? = nil,
      @default_value : Object? = nil,
      position : Position? = nil
    )
      super(type: type_instance, position: position)
    end
  end
  
  class Parameter < GenericType(FunctionInstance)
  end
end
