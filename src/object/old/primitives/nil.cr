module Magiika
  class Object::Nil < SingletonType
    def to_s : ::String
      type_name
    end

    def to_s_internal : ::String
      type_name
    end

    def self.to_s : ::String
      type_name
    end

    def self.to_s_internal : ::String
      type_name
    end

    def eval_bool(scope : Scope) : ::Bool
      return false
    end

    def define : ::Nil
      super

      bool_type = defining_scope.definition(Type::Bool)
      str_type = defining_scope.definition(Type::Str)

      def_native(
        name: "==",
        static: true,
        parameters: [
          Object::Parameter.new(static_scope, "other", nil)
        ],
        returns: bool_type
      ) do |scope|
        other = Object::Slot.unpack(scope.retrieve("other").value)
        bool_type.create_instance(other.is_a?(Object::Nil))
      end

      def_native(
        name: "to_s",
        static: true,
        returns: str_type
      ) do |scope|
        str_type.create_instance("Nil")
      end

      instance.scope.parent = static_scope
    end
  end
end
