module Magiika
  class Object::Union < SingletonType
    getter types : Set(Object)

    def initialize(
      @types : Set(Object),
      position : Position? = nil
    )
      super(position)
    end

    def initialize(
      *types : Object,
      position : Position? = nil
    )
      super(position)
      @types = Set(Object).new(types)
    end

    def is_of?(other : Object) : ::Bool
      super(other) || @types.any? { |type| type.is_of?(other) }
    end
  end
end
