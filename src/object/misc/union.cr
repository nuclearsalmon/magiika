module Magiika
  class Object::Union < SingletonType
    getter types : Set(Type)

    def initialize(
      @types : Set(Type),
      defining_scope : Scope, 
      superclass : Type? = nil,
      position : Position? = nil
    )
      super(defining_scope, superclass, position)
    end

    def initialize(
      *types : Type,
      defining_scope : Scope,
      superclass : Type? = nil,
      position : Position? = nil
    )
      super(defining_scope, superclass, position)
      @types = Set(Type).new(types)
    end

    def is_of?(other : Type) : ::Bool
      super(other) || @types.any? { |type| type.is_of?(other) }
    end
  end
end
