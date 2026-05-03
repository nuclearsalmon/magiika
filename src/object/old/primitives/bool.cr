module Magiika
  class Instance::Bool < Instance
    getter value : ::Bool

    def initialize(
      @value : ::Bool, 
      type : Type::Bool,
      position : Position? = nil
    )
      super(type, position)
    end

    def to_s_internal : ::String
      return @value.to_s
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value
    end
  end

  class Type::Bool < GenericType(Instance::Bool)
    def define : ::Nil
      super

      str_type = defining_scope.definition(Type::Str)

      def_native(
        name: "==",
        parameters: [
          Object::Parameter.new(scope, "other", self)
        ],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Bool).value
        other_value = scope.retrieve("other").value.as(Instance::Bool).value
        create_instance(self_value == other_value)
      end

      def_native(
        name: "to_s",
        returns: str_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Bool).value
        str_type.create_instance(self_value.to_s)
      end
    end
  end
end
