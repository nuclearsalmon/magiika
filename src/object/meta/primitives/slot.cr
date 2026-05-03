module Magiika
  # A slot to store a Objects in and track its constraints.
  class SlotInstance < Instance
    getter value : Object
    getter? final : ::Bool
    getter access : Access
    getter type_constraint : ConstraintInstance

    delegate nilable?, to: @type_constraint
    delegate magic?, to: @type_constraint
    delegate expected_object, to: @type_constraint

    def initialize(
      type_instance : Slot,
      value : Object,
      @final : ::Bool = false,
      @access : Access = Access::Public,
      @type_constraint : ConstraintInstance? = nil
      position : Position? = nil
    )
      super(type_instance: type_instance, position: position)

      if value.is_a?({{ @type }})
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

    def eval_bool(scope : Scope) : Magiika::Bool
      @value.eval_bool(scope)
    end

    def inspect
      String.build { |str|
        str << @value.to_s

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

  class Slot < GenericType(SlotInstance)
  end
end
