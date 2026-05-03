module Magiika
  class Instance::Str < Instance
    getter value : ::String

    def initialize(
      @value : ::String,
      type : Type::Str,
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

  class Type::Str < GenericType(Instance::Str)
    def define : ::Nil
      super

      bool_type = defining_scope.definition(Type::Bool)
      int_type = defining_scope.definition(Type::Int)

      def_native(
        name: "+",
        parameters: [
          Object::Parameter.new(scope, "other", self)
        ],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Str).value
        other_value = scope.retrieve("other").value.as(Instance::Str).value
        create_instance(self_value + other_value)
      end

      def_native(
        name: "==",
        parameters: [
          Object::Parameter.new(scope, "other", self)
        ],
        returns: bool_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Str).value
        other_value = scope.retrieve("other").value.as(Instance::Str).value
        bool_type.create_instance(self_value == other_value)
      end

      def_native(
        name: "len",
        returns: int_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Str).value
        int_type.create_instance(self_value.size.to_i32)
      end

      def_native(
        name: "empty",
        returns: bool_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Str).value
        bool_type.create_instance(self_value.empty?)
      end

      def_native(
        name: "to_s",
        returns: self
      ) do |scope|
        scope.retrieve(SELF_NAME).value.as(Instance::Str)
      end
    end
  end
end
