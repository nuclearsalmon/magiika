module Magiika
  module TypeNode::InstanceDefaults
    macro included
      macro inherited
        {% verbatim do %}
          def self.type_name : ::String
            "#{ {{@type.name.stringify}} }"
          end

          def type_name : ::String
            "#{ {{@type.name.stringify}} }\##{ type_id }"
          end

          def type_id : Typing::TypeID
            self.class.type_id
          end
        {% end %}
      end
    end

    def []?(ident : ::String) : Psuedo::Node?
      nil
    end

    def eval(scope : Scope) : Psuedo::TypeNode
      self
    end

    def superclass : Psuedo::TypeNode?
      self.class.superclass
    end
  end

  module TypeNode::ClassDefaults
    macro extended
      macro inherited
        {% verbatim do %}
          def self.superclass : Psuedo::TypeNode?
            {% if @type.superclass %}
              klass = {{ @type.superclass }}
              return klass if klass.is_a?(Psuedo::TypeNode)
            {% end %}
            nil
          end
        {% end %}
      end
    end
  end

  module TypeNode::ClassTypingDefaults
    macro extended
      macro inherited
        # register self
        @@type_id : Int32 = Magiika::Typing.register_type(
          self.as(Psuedo::TypeNodeIdent))

        def self.type_id : Typing::TypeID
          @@type_id
        end

        {% verbatim do %}
          def self.type_name : ::String
            "#{ {{@type.name.stringify}} }\##{ type_id }"
          end
        {% end %}
      end
    end
  end

  module TypeNode::InstanceTypingDefaults
    macro included
      # instance registration
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
end
