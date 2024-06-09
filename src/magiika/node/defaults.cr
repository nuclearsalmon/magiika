module Magiika
  module Node::InstanceDefaults
    # ⭐ Macro

    macro included
      # ⭐ Constructor and variables

      @position : Position?

      def initialize(@position : Position? = nil)
      end


      # ⭐ Positionality

      def position? : Position?
        @position
      end
    end


    # ⭐ Positionality

    def position : Position
      position = position?
      return Position.default if position.nil?
      position
    end

    def position! : Position
      position = position?
      if position.nil?
        raise Error::Internal.new("No position specified.")
      end
      position
    end


    # ⭐ Evaluating

    def eval(scope : Scope) : Psuedo::Node
      self
    end

    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end


    # ⭐ String representation

    def type_name : ::String
      self.class.type_name
    end

    def to_s : ::String
      "#{ type_name } @ #{ position.to_s } ...\n#{ pretty_inspect }"
    end

    def to_s_internal : ::String
      "#{ type_name } @ #{ position.to_s }"
    end
  end

  module Node::ClassDefaults
    # ⭐ Macro

    macro extended
      # ⭐ String representation

      macro inherited
        {% verbatim do %}
          def self.type_name : ::String
            "#{ {{@type.name.stringify}} }"
          end
        {% end %}
      end

      def self.to_s : ::String
        "#{ type_name } ...\n#{ pretty_inspect }"
      end

      def self.to_s_internal : ::String
        type_name
      end
    end
  end
end
