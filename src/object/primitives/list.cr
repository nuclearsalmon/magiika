module Magiika
  class Object::List < PrimitiveObject
    def initialize(@value : ::Array(AnyObject), position : Position? = nil)
      super(position)
    end
  end
end
