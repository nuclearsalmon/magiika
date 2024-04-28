require "../typing/typing.cr"


module Magiika
  # Node as a type representation
  alias NodeType = NodeClassBase.class | NodeStructBase.class # | Node::Class
  # Node as an instance
  alias NodeObj = NodeClassBase | NodeStructBase
  # Node as either a type representation or an instance
  alias NodeAny = NodeObj | NodeType

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

    def eval(scope : Scope) : NodeObj
      self
    end

    def eval_bool(scope : Scope) : ::Bool
      eval(scope).eval_bool(scope)
    end

    # get a member node, a function, variable, etc
    def []?(sig : String) : NodeObj?
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

    def type? : NodeType?
      self.class
    end

    def self.exact_type?(_type : NodeType) : ::Bool
      Typing.exact_type?(self, _type)
    end

    def exact_type?(_type : NodeType) : ::Bool
      Typing.exact_type?(self, _type)
    end

    def self.type?(_type : NodeType) : ::Bool
      Typing.type?(self, _type)
    end

    def type?(_type : NodeType) : ::Bool
      Typing.type?(self, _type)
    end
  end

  # Abstract base class for Node
  abstract class NodeClassBase
    include Node
    Node.base_define

    def self.inherits_type?(_type : NodeType) : ::Bool
      Typing.inherits_type?(self, _type)
    end

    def inherits_type?(_type : NodeType) : ::Bool
      Typing.inherits_type?(self, _type)
    end

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

      def superclass
        self.class.superclass
      end
    end
  end

  abstract struct NodeStructBase
    include Node
    Node.base_define
    Util.def_clone_methods

    def self.type_id : Int32
      raise Error::Internal.new("Undefined")
    end

    def self.type_name : String
      raise Error::Internal.new("Undefined")
    end

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
    end
  end
end
