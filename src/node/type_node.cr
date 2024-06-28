abstract class Magiika::TypeNode < Magiika::Node
  # redefine. needs to be repeated here or it won't work.
  # modified to include the type_id
  macro inherited
    {% verbatim do %}
      # needs to be repeated here or it won't work
      def self.type_name : ::String
        "#{ {{ @type.name.stringify.split("::")[-1] }} }\#\##{ type_id }"
      end

      # modified to include the type_id
      def type_name : ::String
        "#{ {{ @type.name.stringify.split("::")[-1] }} }\##{ type_id }"
      end
    {% end %}
  end

  # ⭐ macros for delegation

  private macro delegate_to_typing(call)
    def {{call}}(_type : TypeNodeIdent)
      Typing.{{call}}(self, _type)
    end
  end

  private macro delegate_to_typing_extensive(call)
    delegate_to_typing({{call}}?)
    delegate_to_typing({{call}}!)
  end

  # ⭐ Delegated behaviour

  delegate_to_typing_extensive exact_type
  delegate_to_typing_extensive type
  delegate_to_typing_extensive inherits_type

  # Data member access
  def []?(ident : ::String) : Node?
    nil
  end

  def eval(scope : Scope) : TypeNode
    self
  end

  abstract def type_id : Typing::TypeID

  def superclass : TypeNode?
    self.class.superclass
  end

  def self.superclass : TypeNode?
    raise NotImplementedError.new("Should have been implemented via macro.")
  end

  macro extended
    macro inherited
      {% verbatim do %}
        def self.superclass : TypeNode?
          {% if @type.superclass %}
            klass = {{ @type.superclass }}
            return klass if klass.is_a?(TypeNode)
          {% end %}
          nil
        end
      {% end %}
    end
  end
end

module Magiika::TypeNode::ClassTypingFeat
  macro included
    macro inherited
      # register self
      @@type_id : Int32 = Magiika::Typing.register_type(
        self.as(TypeNodeIdent))

      def self.type_id : Typing::TypeID
        @@type_id
      end

      def type_id : Typing::TypeID
        self.class.type_id
      end

      {% verbatim do %}
        def self.type_name : ::String
          "#{ {{@type.name.stringify}} }\##{ type_id }"
        end
      {% end %}
    end
  end
end

module Magiika::TypeNode::InstanceTypingFeat
  macro included
    @type_id : Typing::TypeID? = nil

    def type_id : Typing::TypeID
      type_id = @type_id
      if type_id.nil?
        raise Error::Internal.new("#{self.type_name} was never assigned an instance type id.")
      end
      type_id
    end

    def register_self : Typing::TypeID
      unless @type_id.nil?
        raise Error::Internal.new("#{self.type_name} already registered.")
      end

      type_id = Typing.register_type(self)
      @type_id = type_id
      type_id
    end

    def unregister_self : ::Nil
      type_id = @type_id
      if type_id.nil?
        raise Error::Internal.new("#{self.type_name} was never assigned an instance type id.")
      end
      Typing.unregister_type(type_id)
    end
  end
end

module Magiika
  abstract class TypeNode::ClassTyping < TypeNode
    include ClassTypingFeat
  end

  abstract class TypeNode::InstanceTyping < TypeNode
    abstract def register_self : Typing::TypeID
    abstract def unregister_self : ::Nil

    include InstanceTypingFeat
  end

  abstract class TypeNode::DualTyping < TypeNode
    extend ClassTypingFeat

    abstract def register_self : Typing::TypeID
    abstract def unregister_self : ::Nil

    include InstanceTypingFeat
  end
end

module Magiika
  # ⭐ TypeNode as identifier

  alias TypeNodeIdent =
    TypeNode |
    TypeNode::ClassTyping.class

  # NOTE: Functions sort of like an "Any" type.
  # Should probably not be used.
  alias NodeIdent =
    TypeNodeIdent |
    Node
end
