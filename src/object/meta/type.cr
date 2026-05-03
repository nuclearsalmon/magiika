module Magiika
  abstract class Type < ObjectT
    getter superclass : Type? = nil
    protected getter static_scope : Scope
    protected getter source_instance_scope : Scope
    @defition_finalized : Bool = false

    private macro type_recursive
      # NOTE: needed for Type.class lookup in Scope
      def self.object_name : ::String
        {% verbatim do %}
          {{ @type.name.stringify.split("::")[-1] }}
        {% end %}
      end

      def object_name : ::String
        self.class.object_name
      end

      macro inherited; type_recursive; end
    end; type_recursive

    def initialize(
      @superclass : Type? = nil,
      position : Position? = nil
    )
      super(position)

      # create scopes
      @source_instance_scope = create_source_instance_scope()
      @static_scope = create_static_scope()
    end

    # Scoping
    # --------------------------------------------------------->

    private def create_source_instance_scope : Scope
      super_scope = @superclass.try &.source_instance_scope
      Scope.new(object_name(), position, super_scope)
    end

    private def create_static_scope : Scope
      super_scope = @superclass.try &.static_scope
      Scope.new(object_name(), position, super_scope)
    end

    def new_instance_scope : Scope
      @instance_base_scope.clone
    end

    # Delayed definition
    # --------------------------------------------------------->
    def finalize_definition : ::Nil
      if @defition_finalized
        raise Error::Internal.new("Attempted to define twice")
      else
        define_mutex.synchronize { define }
        @defition_finalized = true
      end
    end

    protected def define : ::Nil
    end

    protected def def_native_method(
      name : ::String,
      static : ::Bool = false,
      parameters : Array(Object::Parameter) = Array(Object::Parameter).new,
      returns : Object? = nil,
      access : Access = Access::Public,
      &body : Proc(Scope, Magiika::Object)
    ) : ::Nil
      # check that injectables are not predefined
      raise "Predefined injectable parameters" \
        unless parameters.index { |x| {"this", "self"}.includes?(x.name) }

      # inject self/this into parameters
      if static
        parameters.unshift(Object::Parameter.new(@defining_scope, "this", self))
      end
      parameters.unshift(Object::Parameter.new(@defining_scope, "self", self))

      # create method
      method = Object::NativeFunction.new(
        defining_scope: @defining_scope,
        proc: body,
        name: name,
        parameters: parameters,
        returns: returns)

      # create slot
      slot = Slot.new(
        value: method,
        defining_scope: @defining_scope,
        final: !Magiika::ALLOW_MONKEY_PATCHING,
        access: access,
        constrained_type: defining_scope.definition(Function))

      # define in scope
      (static ? @static_scope : @source_instance_scope) \
        .define(name, slot)
    end
  end
end
