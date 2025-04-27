# AI Comment:
# Magiika::Object represents values that share a common type ID across
# all instances of their implementation. For example, all Integers
# share the same type ID, all ::Strings share the same type ID, etc.
# These are the fundamental building blocks for most values in the language.

module Magiika
  alias AnyObject = Magiika::Object | Magiika::Object.class

  abstract class Object
    include Positionable
    include IsOf

    private macro recursive_inherited_object
      macro inherited
        {% verbatim do %}
          def self.type_name : ::String
            {{ @type.name.stringify.split("::")[-1] }}
          end

          def self.superclass : Magiika::AnyObject
            {{ @type.superclass }}
          end

          recursive_inherited_object
        {% end %}
      end

      class_getter scope : Scope = begin
        name = "#{{{ @type }}.type_name} - static"
        parent = self.superclass.try(&.scope)
        Scope.new(name: name, parent: parent)
      end

      protected class_getter inst_base_scope : Scope = begin
        name = "#{{{ @type }}.type_name} - instance base"
        parent = self.superclass.try(&.inst_base_scope)
        Scope.new(name: name, parent: parent)
      end

      getter scope : Scope = begin
        name = "#{{{ @type }}.type_name} - instance"
        parent = @@inst_base_scope
        Scope.new(name: name, parent: parent)
      end
    end
    recursive_inherited_object

    protected def self.def_native(
      name : ::String,
      static : ::Bool = false,
      parameters : Array(Object::Parameter) = Array(Object::Parameter).new, 
      returns : AnyObject? = nil,
      access : Access = Access::Public,
      &body : Proc(Scope, Magiika::Object | Magiika::Object.class)
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
      scope = static ? @@scope : @@inst_base_scope
      scope.define(name, slot)
    end

    def_native(
      name: "type",
      static: true,
      returns: self
    ) do |scope|
      self
    end

    def initialize(@position : Position? = nil)
      @scope.name = self.type_name  # set name to instance's type name
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
end
