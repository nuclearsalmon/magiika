module Magiika
  class DeferredType(T) < Type
    @type : T

    def initialize(@type : T, *args, **kwargs)
      super(*args, **kwargs)
    end

    def is_of?(other) : ::Bool
      res = super(other)
      if res; true; else
        @type.is_of?(other)
      end
    end

    def create_instance(
      *args,
      position : Position? = nil,
      **kwargs
    ) : Instance
      T.create_instance(*args, **kwargs, position: position)
    end
  end
end