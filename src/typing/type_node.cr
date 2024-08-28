module Magiika
  # **Feature:** `#eval_type(Scope) : TypeMeta`
  module EvalType
    abstract def eval_type(scope : Scope) : TypeMeta
  end

  # *EvalType* by returning the *TypeMeta* from
  # the result of evaling.
  #
  # **Note:** `#eval(scope)` must return a *TypeNode*.
  module AutoEvalType
    include EvalType

    abstract def eval(scope : Scope) : TypeNode
    def eval_type(scope : Scope) : TypeMeta
      eval(scope).type_meta
    end
  end

  # *EvalType* by returning the *TypeMeta** of self.
  #
  # **Note:** Can be included or extended.
  # **Note:** Recursive inherit.
  private module SelfEvalType
    private macro recursive_inherited
      macro included
        include EvalType
        {% verbatim do %}
          def eval_type(scope : Scope) : TypeMeta
            self.type_meta
          end
        {% end %}
      end

      macro extended
        {% verbatim do %}
          extend EvalType
          def self.eval_type(scope : Scope) : TypeMeta
            self.type_meta
          end
        {% end %}
      end

      macro inherited
        recursive_inherited
      end
    end

    recursive_inherited
  end

  # **Feature:**
  # - `#type_meta? : TypeMeta?`
  # - `#type_meta : TypeMeta`
  module HasTypeMeta
    abstract def type_meta? : TypeMeta?
    abstract def type_meta : TypeMeta
  end

  # A *Node* that is a type.
  # Each class is given a *TypeMeta*.
  abstract class TypeNode < Node
    include SelfEvalType
    extend SelfEvalType
    extend HasTypeMeta

    private TYPE_BASE = true
    class_getter? type_base : ::Bool = TYPE_BASE

    abstract def type_meta : TypeMeta?
    abstract def type_meta : TypeMeta

    protected def type_name : ::String
      {{ @type.name.stringify.split("::")[-1] }}
    end

    private macro recursive_inherited
      macro inherited
        {% verbatim do %}
          @@type_meta : TypeMeta = \
              Magiika::Typing.register_type(
                reference: self,
                type_name: type_name,
                type_superclass: {{ @type.superclass }})

          def self.type_meta? : TypeMeta?
            @@type_meta
          end

          def self.type_meta : TypeMeta
            @@type_meta
          end

          def type_meta? : TypeMeta?
            @@type_meta
          end

          def type_meta : TypeMeta
            @@type_meta
          end

          def self.type_base? : ::Bool
            {{ @type.has_constant?("TYPE_BASE") &&
               @type.constant("TYPE_BASE") == true }}
          end
        {% end %}

        recursive_inherited
      end
    end

    recursive_inherited
  end

  # *TypeNode* where each instance can have its own
  # *TypeMeta* in addition to the class-level *TypeMeta*
  # that comes with *TypeNode*.
  abstract class InstTypeNode < TypeNode
    include HasTypeMeta

    private TYPE_BASE = true

    @type_meta : TypeMeta? = nil

    getter? type_meta : TypeMeta?
    def type_meta : TypeMeta
      @type_meta || raise Error::Internal.new(
        "Type meta is nil for #{self.class.name}")
    end

    def reference_type(
        position : Position? = nil,
        scope : Scope? = nil) : TypeMeta
      type_meta = @type_meta
      if type_meta.nil?
        type_meta = Typing.register_type(
          type_name: type_name,
          reference: self,
          type_superclass: {{ @type.superclass }}
        )
        @type_meta = type_meta
      end

      type_meta.reference_type(position, scope)
      type_meta
    end

    def unreference_type : ::Bool
      type_meta = @type_meta
      if type_meta.nil?
        raise Error::Internal.new(
          "#{self.type_name} was never assigned an instance type meta.")
      end

      if type_meta.unreference_type()
        @type_meta = nil
        true
      else
        false
      end
    end

    #def unregister_type : ::Nil
    #  type_meta = @type_meta
    #  if type_meta.nil?
    #    raise Error::Internal.new(
    #      "#{self.type_name} was never assigned an instance type meta.")
    #  end
    #
    #  Typing.unregister_type(type_meta.id)
    #  @type_meta = nil
    #end
  end
end
