module Magiika
  class PrimitiveObjectInstance < Type
  end

  class PrimitiveObject < GenericType(PrimitiveObjectInstance)
    def object_name; "Obj"; end
  end
end
