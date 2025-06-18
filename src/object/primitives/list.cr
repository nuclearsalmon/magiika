module Magiika
  class Object::ListInstance < Instance
    def initialize(
      @value : ::Array(Object),
      type : Object::List,
      position : Position? = nil
    )
      super(type, position)
    end
  end

  class Object::List < GenericType(Object::ListInstance)
  end
end
