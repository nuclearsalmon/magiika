module Magiika
  class Object::String < PrimitiveObject
    protected getter value : ::String

    def initialize(@value : ::String, position : Position? = nil)
      super(position)
    end

    def to_s_internal : ::String
      "\"#{@value}\""
    end

    def eval_bool(scope : Scope) : ::Bool
      @value != ""
    end
  end
end
