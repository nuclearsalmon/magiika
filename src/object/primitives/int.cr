module Magiika
  class Object::IntInstance < Instance
    include Psuedo::Number

    getter value : InternalIntegerType

    def initialize(
      @value : InternalIntegerType,
      type : Object::Int,
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

  class Object::Int < GenericType(Object::IntInstance)
    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      def_natives()
    end

    private def def_natives : ::Nil
      def_native(
        name: "_+",
        returns: self
      ) do |scope|
        scope.retrieve(SELF_NAME).value.as(Object::IntInstance)
      end

      def_native(
        name: "_-",
        returns: self
      ) do |scope|
        create_instance(-(scope.retrieve(SELF_NAME).value.as(Object::IntInstance).value))
      end

      def_native(
        name: "+",
        parameters: [Object::Parameter.new("other", NUMBER_UNION)],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Object::IntInstance).value.to_i32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
        result = self_value + other_value
        create_instance(result)
      end

      def_native(
        name: "-",
        parameters: [Object::Parameter.new("other", NUMBER_UNION)],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Object::IntInstance).value.to_i32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
        result = self_value - other_value
        create_instance(result)
      end

      def_native(
        name: "*",
        parameters: [Object::Parameter.new("other", NUMBER_UNION)],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Object::IntInstance).value.to_i32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
        result = self_value * other_value
        create_instance(result)
      end

      def_native(
        name: "/",
        parameters: [Object::Parameter.new("other", NUMBER_UNION)],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Object::IntInstance).value.to_i32
        other_value = scope.retrieve("other").value.as(Psuedo::Number).value.to_i32
        result = self_value / other_value
        create_instance(result)
      end
    end
  end
end
