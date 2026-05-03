module Magiika
  class GenericType(IT) < Type
    def self.from(
      instance : IT.class,
      superclass : Type? = nil
    ) : GenericType(IT)
      raise "not an instance" unless instance.is_a?(Instance)
      GenericType(IT).new(superclass: superclass)
    end

    def create_instance(
      *args,
      position : Position? = nil,
      **kwargs
    ) : Instance
      IT.new(*args, **kwargs, type: self, position: position)
    end
  end
end
