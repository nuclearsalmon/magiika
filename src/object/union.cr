module Magiika
  class Object::Union < MetaObject
    getter types : Set(AnyObject)

    def initialize(
        @types : Set(AnyObject),
        position : Position? = nil)
      super(position)
    end
  
    def initialize(
        *types : AnyObject,
        position : Position? = nil)
      @types = Set(AnyObject).new(types)
      super(position)
    end

    def is_of?(other : AnyObject) : ::Bool
      # Take a shortcut by checking if the ID is identical first,
      # this requires less processing than checking each individual type.
      super(other) || @types.any? { |type| type.is_of?(other) }
    end
  end
end
