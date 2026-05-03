module Magiika
  class Instance::Int < Instance
    include Psuedo::Number

    getter value : InternalIntegerType

    def initialize(
      @value : InternalIntegerType,
      type : Type::Int,
      position : Position? = nil
    )
      super(type, position)
    end
    
    def to_s_internal : ::String
      return @value.to_s
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value != 0
    end
  end

  class Type::Int < GenericType(Instance::Int)
    def define : ::Nil
      super

      def_native(
        name: "_+",
        returns: self
      ) do |scope|
        scope.retrieve(SELF_NAME).value.as(Instance::Int)
      end

      def_native(
        name: "_-",
        returns: self
      ) do |scope|
        create_instance(-(scope.retrieve(SELF_NAME).value.as(Instance::Int).value))
      end

      def_native(
        name: "+",
        parameters: [
          Object::Parameter.new(
            scope,
            "other", 
            defining_scope.union(
              scope.position,
              *NUMBER_TYPES
            )
          )
        ],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Int).value.to_i32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
        result = self_value + other_value
        create_instance(result)
      end

      def_native(
        name: "-",
        parameters: [
          Object::Parameter.new(
            scope,
            "other", 
            defining_scope.union(
              scope.position,
              *NUMBER_TYPES
            )
          )
        ],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Int).value.to_i32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
        result = self_value - other_value
        create_instance(result)
      end

      def_native(
        name: "*",
        parameters: [
          Object::Parameter.new(
            scope,
            "other", 
            defining_scope.union(
              scope.position,
              *NUMBER_TYPES
            )
          )
        ],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Int).value.to_i32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
        result = self_value * other_value
        create_instance(result.to_i32)
      end

      def_native(
        name: "/",
        parameters: [
          Object::Parameter.new(
            scope,
            "other", 
            defining_scope.union(
              scope.position,
              *NUMBER_TYPES
            )
          )
        ],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Int).value.to_i32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
        result = self_value / other_value
        create_instance(result.to_i32)
      end

      bool_type = defining_scope.definition(Type::Bool)
      str_type = defining_scope.definition(Type::Str)
      flt_type = defining_scope.definition(Type::Flt)

      def_native(
        name: "==",
        parameters: [
          Object::Parameter.new(
            scope,
            "other",
            defining_scope.union(
              scope.position,
              *NUMBER_TYPES
            )
          )
        ],
        returns: bool_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Int).value
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value
        bool_type.create_instance(self_value == other_value)
      end

      def_native(
        name: "to_s",
        returns: str_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Int).value
        str_type.create_instance(self_value.to_s)
      end

      def_native(
        name: "to_flt",
        returns: flt_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::Int).value
        flt_type.create_instance(self_value.to_f32)
      end
    end
  end
end
