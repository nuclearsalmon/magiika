module Magiika
  class Instance::List < Instance
    getter value : ::Array(Object)

    def initialize(
      @value : ::Array(Object),
      type : Type::List,
      position : Position? = nil
    )
      super(type, position)
    end

    def to_s_internal : ::String
      "[#{@value.map(&.to_s_internal).join(", ")}]"
    end

    def eval_bool(scope : Scope) : ::Bool
      !@value.empty?
    end
  end

  class Type::List < GenericType(Instance::List)
    def define : ::Nil
      super

      bool_type = defining_scope.definition(Type::Bool)
      int_type = defining_scope.definition(Type::Int)
      str_type = defining_scope.definition(Type::Str)
      nil_type = defining_scope.definition(Object::Nil)

      def_native(
        name: "len",
        returns: int_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        int_type.create_instance(self_value.size.to_i32)
      end

      def_native(
        name: "empty",
        returns: bool_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        bool_type.create_instance(self_value.empty?)
      end

      def_native(
        name: "get",
        parameters: [
          Object::Parameter.new(scope, "index", int_type)
        ],
        returns: nil
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        index = scope.retrieve("index").value.as(Instance::Int).value
        if index < 0 || index >= self_value.size
          raise Error::Lazy.new("Index #{index} out of bounds for List of size #{self_value.size}.")
        end
        Object::Slot.unpack(self_value[index])
      end

      def_native(
        name: "first",
        returns: nil
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        if self_value.empty?
          raise Error::Lazy.new("Cannot get first element of empty List.")
        end
        Object::Slot.unpack(self_value[0])
      end

      def_native(
        name: "last",
        returns: nil
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        if self_value.empty?
          raise Error::Lazy.new("Cannot get last element of empty List.")
        end
        Object::Slot.unpack(self_value[-1])
      end

      def_native(
        name: "push",
        parameters: [
          Object::Parameter.new(scope, "item", nil)
        ],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        item = Object::Slot.unpack(scope.retrieve("item").value)
        create_instance(self_value + [item])
      end

      def_native(
        name: "prepend",
        parameters: [
          Object::Parameter.new(scope, "item", nil)
        ],
        returns: self
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        item = Object::Slot.unpack(scope.retrieve("item").value)
        create_instance([item] + self_value)
      end

      def_native(
        name: "pop",
        returns: nil
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        if self_value.empty?
          raise Error::Lazy.new("Cannot pop from empty List.")
        end
        Object::Slot.unpack(self_value[-1])
      end

      def_native(
        name: "contains",
        parameters: [
          Object::Parameter.new(scope, "item", nil)
        ],
        returns: bool_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        item = Object::Slot.unpack(scope.retrieve("item").value)
        found = self_value.any? { |elem|
          unpacked = Object::Slot.unpack(elem)
          unpacked.to_s_internal == item.to_s_internal
        }
        bool_type.create_instance(found)
      end

      def_native(
        name: "index",
        parameters: [
          Object::Parameter.new(scope, "item", nil)
        ],
        returns: int_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        item = Object::Slot.unpack(scope.retrieve("item").value)
        idx = self_value.index { |elem|
          Object::Slot.unpack(elem).to_s_internal == item.to_s_internal
        }
        if idx.nil?
          raise Error::Lazy.new("Item not found in List.")
        end
        int_type.create_instance(idx.to_i32)
      end

      def_native(
        name: "==",
        parameters: [
          Object::Parameter.new(scope, "other", self)
        ],
        returns: bool_type
      ) do |scope|
        self_value = scope.retrieve(SELF_NAME).value.as(Instance::List).value
        other_value = scope.retrieve("other").value.as(Instance::List).value
        equal = self_value.size == other_value.size &&
          self_value.zip(other_value).all? { |a, b|
            Object::Slot.unpack(a).to_s_internal == Object::Slot.unpack(b).to_s_internal
          }
        bool_type.create_instance(equal)
      end

      def_native(
        name: "to_s",
        returns: str_type
      ) do |scope|
        self_inst = scope.retrieve(SELF_NAME).value.as(Instance::List)
        str_type.create_instance(self_inst.to_s_internal)
      end
    end
  end
end
