# AI Comment:
# Magiika::Object represents values that share a common type ID across
# all instances of their implementation. For example, all Integers
# share the same type ID, all ::Strings share the same type ID, etc.
# These are the fundamental building blocks for most values in the language.

module Magiika
  #alias AnyObject = Magiika::Object | Magiika::Object.class
  alias AnyObject = Magiika::Object

  abstract class Object
    include Positionable
    include IsOf

    private macro recursive_inherited_object
      macro inherited
        {% verbatim do %}
          def self.type_name : ::String
            {{ @type.name.stringify.split("::")[-1] }}
          end

          def self.superclass : Magiika::AnyObject?
            {{ @type.superclass }}
          end

          recursive_inherited_object
        {% end %}
      end
    end
    recursive_inherited_object

    getter scope : Scope

    def initialize(
      global_scope : Scope? = nil,
      @position : Position? = nil
    )
      @scope = create_scope(global_scope, position)
    end

    def self.superclass : Magiika::AnyObject?
      nil
    end

    def superclass : Magiika::AnyObject?
      self.class.superclass
    end

    protected abstract def create_scope(
      global_scope : Scope?, 
      position : Position?
    ) : Scope

    abstract def type_id : Typing::TypeID

    protected def def_native(
      name : ::String,
      static : ::Bool = false,
      parameters : Array(Object::Parameter) = Array(Object::Parameter).new, 
      returns : AnyObject? = nil,
      access : Access = Access::Public,
      &body : Proc(Scope, Magiika::Object)
    ) : ::Nil
      # inject self/this into parameters
      unless static
        parameters.unshift(Object::Parameter.new("self", self))
      end
      parameters.unshift(Object::Parameter.new("this", self))
      
      # create method
      method = Object::NativeFunction.new(
        proc: body, 
        name: name,
        parameters: parameters,
        returns: returns)

      # create slot
      slot = Slot.new(
        value: method,
        final: !Magiika::ALLOW_MONKEY_PATCHING,
        type: Object::NativeFunction,
        access: access)

      # define in scope
      target_scope = static ? @scope : @inst_base_scope
      target_scope.define(name, slot)
    end

    def_native(
      name: "type",
      static: true,
      returns: self
    ) do |scope|
      self
    end

    def self.eval_bool(scope : Scope) : ::Bool
      false
    end

    def eval_bool(scope : Scope) : ::Bool
      self.class.eval_bool(scope)
    end
      
    def self.is_of!(other : Magiika::AnyObject, message : ::String? = nil) : ::Bool
      return true if self.is_of?(other)
      raise Error::Type.new(self, other, message)
    end

    def is_of!(other : Magiika::AnyObject, message : ::String? = nil) : ::Bool
      return true if self.is_of?(other)
      raise Error::Type.new(self, other, message)
    end

    def self.superclass : Magiika::AnyObject?
      nil
    end

    def superclass : Magiika::AnyObject?
      self.class.superclass
    end

    def self.type_name : ::String
      {{ @type.name.stringify.split("::")[-1] }}
    end

    def type_name : ::String
      self.class.type_name
    end

    def self.to_s : ::String
      "#{type_name} ...\n#{pretty_inspect}"
    end

    def to_s : ::String
      "#{type_name} @ #{position.to_s} ...\n#{pretty_inspect}"
    end

    def self.to_s_internal : ::String
      type_name
    end

    def to_s_internal : ::String
      "#{type_name} @ #{position.to_s}"
    end
  end

  abstract class Type < Object
    private PLACEHOLDER_SCOPE = Scope.new("placeholder")
    getter type_id : Typing::TypeID
    protected getter inst_base_scope : Scope = PLACEHOLDER_SCOPE

    def initialize(
      global_scope : Scope? = nil,
      position : Position? = nil
    )
      @type_id = Typing.aquire_id
      super(global_scope: global_scope, position: position)
    end

    protected def create_scope(
      global_scope : Scope,
      position : Position?
    ) : Scope
      # Create type-level scopes
      name = "#{self.class.type_name} - static"
      parent = self.class.superclass.try(&.scope)
      main_scope = Scope.new(name: name, parent: parent || global_scope)
  
      # Create instance base scope - overwrite the placeholder
      name = "#{self.class.type_name} - instance base"
      parent = self.class.superclass.try(&.inst_base_scope)
      @inst_base_scope = Scope.new(name: name, parent: parent || global_scope)
  
      main_scope
    end

    # Factory method for creating instances
    protected abstract def create_instance(position : Position? = nil, **args) : Instance
  end

  abstract class Instance < Object
    getter cls : Type
    delegate type_id, to: @cls

    def initialize(
      @cls : Type,
      global_scope : Scope,
      position : Position? = nil
    )
      super(global_scope: global_scope, position: position)
    end

    protected def create_scope(
      global_scope : Scope,
      position : Position?
    ) : Scope
      name = "#{self.class.type_name} - instance"
      Scope.new(name: name, parent: @cls.inst_base_scope)
    end
  end
end
