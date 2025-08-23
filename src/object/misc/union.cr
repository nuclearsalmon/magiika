module Magiika
  class Object::Union < SingletonType
    getter types : Set(Type)

    def initialize(
      @types : Set(Type),
      position : Position? = nil
    )
      super(position)
    end

    def initialize(
      *types : Type,
      position : Position? = nil
    )
      super(position)
      @types = Set(Type).new(types)
    end

    def is_of?(other : Type) : ::Bool
      super(other) || @types.any? { |type| type.is_of?(other) }
    end
  end
end
