module Magiika
  # A slot to store an Object in and track its constraints.
  class Instance::Slot < Instance
    getter value : Object
    getter? final : ::Bool
    getter access : Access
    getter type_constraint : Object::TypeConstraint

    delegate nilable?, to: @type_constraint
    delegate magic?, to: @type_constraint
    delegate constrained_type, to: @type_constraint

    def initialize(
      value : Object,
      defining_scope : Scope,
      @final : ::Bool = false,
      @access : Access = Access::Public,
      constrained_type : Type? = nil,
      nilable : ::Bool = false,
      position : Position? = nil
    )
      super(defining_scope: defining_scope, position: position)
      @type_constraint = TypeConstraint.new(
        constrained_type: constrained_type,
        nilable: nilable,
        defining_scope: defining_scope,
        position: position,
        allow_slot: false)

      if value.is_a?(Object::Slot) || value.is_a?(Object::Slot.class)
        raise Error::Internal.new("A #{{{ @type }}} may not directly contain a #{{{ @type }}}.")
      end
      @value = value
    end

    def value=(value : Object) : Object
      value.is_of!(@type_constraint) unless @type_constraint.magic?
      @value = value
    end

    def self.unpack(node : Object) : Object
      node.is_a?(Object::Slot) ? node.value : node
    end

    def eval(scope : Scope) : Object
      @value
    end

    def to_s_internal
      String.build { |str|
        str << @value.to_s_internal

        opt_props = Deque(String).new(initial_capacity: 4)  # NOTE: Sync to nr. of possible props below
        opt_props << @access.to_s.downcase unless @access.public?
        opt_props << "final" if @final
        opt_props << "nilable" if @type_constraint.nilable?
        type_s = type_constraint.constrained_type.try { |x| "#{x.to_s_internal}" }
        opt_props << type_s unless type_s.nil?

        unless opt_props.empty?
          str << " ["
          str << opt_props.join(" ")
          str << "]"
        end
      }
    end
  end

  class Type::Slot < GenericType(Instance::Slot)
    def define : ::Nil
      super

      str_type = defining_scope.definition(Type::Str)

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
