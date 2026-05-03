module Magiika
  # Object: the base for all runtime, not AST, nodes.
  # Everything is an Object...or an AST node. Sometimes both (primitives).
  class Object
    include Positionable
    include IsOf

    private macro object_recursive
      def self.type_name : ::String
        {% verbatim do %}
          {{ @type.name.stringify.split("::")[-1] }}
        {% end %}
      end

      def type_name : ::String
        self.class.type_name
      end

      macro inherited
        object_recursive
      end
    end
    object_recursive

    getter defining_scope : Scope

    @@global_object_scope = uninitialized Scope
    protected def global_object_scope : Scope
      @@global_object_scope
    end

    protected getter static_scope : Scope         # scope of type

    def scope : Scope
      Scope.new(type_name)  # FIXME: Properly implement this
    end

    def initialize(@defining_scope : Scope, @position : Position? = nil)
      # define object scope
      @@global_object_scope = Scope.new("#{type_name}")
      @static_scope = Scope.new("#{type_name}", @position, @@global_object_scope)
    end

    def complete_definition
      define_mutex = @define_mutex
      raise "Attempted to define twice" if define_mutex.nil?

      define_mutex.synchronize { define }
      @define_mutex = nil
    end

    private def define
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
        defining_scope: @defining_scope,
        final: !Magiika::ALLOW_MONKEY_PATCHING,
        access: access,
        constrained_type: defining_scope.definition(Function))

      # define in scope
      target_scope = static ? @static_scope : @instance_base_scope
      target_scope.define(name, slot)
    end

    def eval_bool(scope : Scope) : ::Bool
      true
    end

    # NOTE: extend is_of module with magiika-specific error handling
    def is_of!(other : Magiika::Object, message : ::String? = nil) : ::Bool
      self_type : Type = self.is_a?(Instance) ? self.type : self.as(Type)

      return true if self_type.is_of?(other)
      raise Error::Type.new(self_type, other, message)
    end

    def self.type_name : ::String
      raise NotImplementedError.new("type_name is not implemented for #{{{ @type }}}")
    end

    def type_name : ::String
      raise NotImplementedError.new("type_name is not implemented for #{{{ @type }}}")
    end

    def to_s : ::String
      "#{type_name} @ #{position} ...\n#{pretty_inspect}"
    end

    def to_s_internal : ::String
      "#{type_name} @ #{position}"
    end
  end
end
