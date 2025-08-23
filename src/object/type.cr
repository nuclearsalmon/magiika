module Magiika
  # Type: a type that can be instantiated into an Instance.
  # Everything is an Object.
  abstract class Type < Object
    private macro type_recursive
      macro inherited
        def superclass_t : Magiika::Type?
          {% verbatim do %}
            {{ @type.superclass }}
          {% end %}
        end
        
        type_recursive
      end
    end
    type_recursive

    @define_mutex : Mutex? = Mutex.new
    protected getter static_scope : Scope         # scope of type
    protected getter instance_base_scope : Scope  # base for scope of instance
    getter superclass : Type? = nil

    def scope : Scope
      @static_scope
    end

    def initialize(
      defining_scope : Scope, 
      superclass : Type? = nil,
      position : Position? = nil
    )
      super(defining_scope, position)
      @static_scope = Scope.new("#{type_name}")
      if superclass.nil?
        @instance_base_scope = Scope.new(
          "#{type_name}__base")
      else
        @superclass = superclass
        superscope = superclass.instance_base_scope
        @instance_base_scope = Scope.new(
          "#{type_name}__base", 
          superscope)
      end
    end

    abstract def create_instance(
      *args,
      position : Position? = nil,
      **kwargs
    ) : Instance

    def complete_definition
      define_mutex = @define_mutex
      raise "Attempted to define twice" if define_mutex.nil?

      definine_mutex.synchronize { define }
      @define_mutex = nil
    end

    def define
      def_native(
        name: "type",
        static: true,
        returns: self
      ) do |scope|
        self
      end
    end

    protected def def_native(
      name : ::String,
      static : ::Bool = false,
      parameters : Array(Object::Parameter) = Array(Object::Parameter).new,
      returns : Object? = nil,
      access : Access = Access::Public,
      &body : Proc(Scope, Magiika::Object)
    ) : ::Nil
      # inject self/this into parameters
      unless static
        parameters.unshift(Object::Parameter.new(@defining_scope, "self", self))
      end
      parameters.unshift(Object::Parameter.new(@defining_scope, "this", self))

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
        final: !Magiika::ALLOW_MONKEY_PATCHING,
        access: access,
        constrained_type: defining_scope.retrieve_type(Function))

      # define in scope
      target_scope = static ? @static_scope : @instance_base_scope
      target_scope.define(name, slot)
    end
  end
end
