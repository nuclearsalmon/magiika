module Magiika
  class Object::FltInstance < Instance
    include Psuedo::Number

    getter value : InternalFloatType

    def initialize(
      @value : InternalFloatType,
      type : Object::Flt,
      position : Position? = nil
    )
      super(type, position)
    end

    def to_s_internal : ::String
      return @value.to_s
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value != 0.0
    end
  end

  class Object::Flt < GenericType(Object::FltInstance)
    def define : ::Nil
      super
      
      def_native(
        name: "_+",
        returns: self
      ) do |scope|
        scope.retrieve(SELF_NAME).value.as(Object::FltInstance)
      end

      def_native(
        name: "_-",
        returns: self
      ) do |scope|
        create_instance(-(scope.retrieve(SELF_NAME).value.as(Object::FltInstance).value))
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
        self_value = scope.retrieve(SELF_NAME).value.as(Object::FltInstance).value.to_f32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
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
        self_value = scope.retrieve(SELF_NAME).value.as(Object::FltInstance).value.to_f32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
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
        self_value = scope.retrieve(SELF_NAME).value.as(Object::FltInstance).value.to_f32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
        result = self_value * other_value
        create_instance(result)
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
        self_value = scope.retrieve(SELF_NAME).value.as(Object::FltInstance).value.to_f32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_f32
        result = self_value / other_value
        create_instance(result)
      end
    end
  end
end
