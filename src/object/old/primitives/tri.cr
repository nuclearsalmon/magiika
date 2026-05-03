module Magiika
  class Instance::Tri < Instance
    getter value : ::Bool?

    def initialize(
      @value : ::Bool?,
      type : Type::Tri,
      position : Position? = nil
    )
      super(type, position)
    end

    def to_s_internal : ::String
      @value.nil? ? "unknown" : @value.to_s
    end

    def eval_bool(scope : Scope) : ::Bool
      @value == true
    end
  end

  class Type::Tri < GenericType(Instance::Tri)
    def define : ::Nil
      super

      bool_type = defining_scope.definition(Type::Bool)
      str_type = defining_scope.definition(Type::Str)

      def_native(
        name: "yes",
        static: true,
        returns: self
      ) do |scope|
        create_instance(true)
      end

      def_native(
        name: "no",
        static: true,
        returns: self
      ) do |scope|
        create_instance(false)
      end

      def_native(
        name: "unknown",
        static: true,
        returns: self
      ) do |scope|
        create_instance(nil)
      end

      def_native(
        name: "is_true",
        returns: bool_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Tri)
        bool_type.create_instance(self_inst.value == true)
      end

      def_native(
        name: "is_false",
        returns: bool_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Tri)
        bool_type.create_instance(self_inst.value == false)
      end

      def_native(
        name: "is_nil",
        returns: bool_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Tri)
        bool_type.create_instance(self_inst.value.nil?)
      end

      def_native(
        name: "to_bool",
        returns: bool_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Tri)
        val = self_inst.value
        if val.nil?
          raise Error::Lazy.new("Cannot convert unknown Tri to Bool.")
        end
        bool_type.create_instance(val)
      end

      def_native(
        name: "==",
        parameters: [
          Object::Parameter.new(self.scope, "other", self)
        ],
        returns: bool_type
      ) do |scope|
        self_inst = Object::Slot.unpack(scope.retrieve(SELF_NAME).value).as(Instance::Tri)
        other_inst = Object::Slot.unpack(scope.retrieve("other").value).as(Instance::Tri)
        bool_type.create_instance(self_inst.value == other_inst.value)
      end

      def_native(
        name: "to_s",
        returns: str_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::Tri)
        str_type.create_instance(self_inst.to_s_internal)
      end
    end
  end
end
