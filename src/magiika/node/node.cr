require "./desc/typing/type_registry.cr"

module Magiika
  alias NodeType = NodeClassBase.class | NodeStructBase.class # | Node::Class
  alias NodeD = NodeClassBase | NodeStructBase
  alias NodeAny = Node | NodeType

  module Node
    # ✨ Macros

    macro base_define
      @position : Lang::Position?

      def initialize(@position : Lang::Position? = nil)
      end

      def position? : Lang::Position?
        @position
      end
    end

    # ✨ Base functionality

    def eval(scope : Scope) : NodeD
      self
    end

    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end

    # get a member node, a function, variable, etc
    def []?(sig : String) : Node?
      nil
    end

    def position : Lang::Position
      pos = position?
      return Lang::Position.default if pos.nil?
      pos
    end

    def position! : Lang::Position
      pos = position?
      raise Error::Internal.new("No position specified.") if pos.nil?
      pos
    end

    # ✨ String representation

    def to_s : String
      "#{ type_name } @ #{ @position.to_s } ...\n#{ pretty_inspect }"
    end

    def to_s_internal : String
      "#{ type_name } @ #{ @position.to_s }"
    end

    # ✨ Typing

    abstract def type_id : Int32

    abstract def type_name : String
  end

  # Abstract base class for Node
  abstract class NodeClassBase
    include Node
    Node.base_define

    macro inherited
      @@type_id = Magiika::Typing.register_type(self)

      def self.type_id : Int32
        # call at class level
        @@type_id
      end

      def type_id : Int32
        self.class.type_id
      end

      def self.type_name : String
        "#{ {{@type.name.stringify}} }\##{ type_id }"
      end

      def type_name : String
        self.class.type_name
      end

      def self.superclass
        {{ @type.superclass }}
      end
    end

    private macro delayed_def
      def node_is_a_inh?(_type : Node.class) : ::Bool
        klass = self.class
        while klass
          return true if klass.type_id == _type.type_id
          klass = klass.superclass
        end
        false
      end
    end
    delayed_def
  end

  abstract struct NodeStructBase
    include Node
    Node.base_define
    Util.def_clone_methods

    macro inherited
      @@type_id = Magiika::Typing.register_type(self)

      def self.type_id : Int32
        # call at class level
        @@type_id
      end

      def type_id : Int32
        self.class.type_id
      end

      def self.type_name : String
        "#{ {{@type.name.stringify}} }\##{ type_id }"
      end

      def type_name : String
        self.class.type_name
      end

      pp to_s
    end
  end
end
