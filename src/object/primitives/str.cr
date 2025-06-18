module Magiika
  class Object::StrInstance < Instance
    protected getter value : ::String

    def initialize(
      @value : ::String,
      type : Object::Str,
      position : Position? = nil
    )
      super(type, position)
    end

    def to_s_internal : ::String
      "\"#{@value}\""
    end

    def eval_bool(scope : Scope) : ::Bool
      @value != ""
    end
  end

  class Object::Str < GenericType(Object::StrInstance)
  end
end
