module Magiika
  class GenericType(I) < Type
    def create_instance(
      *args,
      position : Position? = nil,
      **kwargs
    ) : I
      I.new(*args, **kwargs, type: self, position: position)
    end
  end
end
