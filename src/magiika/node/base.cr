module Magiika
  module Node
    TYPE_IDS = {} of String => Int32

    macro inherited
      def self.type_id : Int32
        {{ Magiika::Node::TYPE_IDS.size }}
      end

      {% Magiika::Node::TYPE_IDS[@type.name.stringify] \
        = Magiika::Node::TYPE_IDS.size %}
    end

    macro methods
      {{ @type.methods.map &.name.stringify }}
    end

    abstract def eval(scope : Scope) : Node
    abstract def eval_bool(scope : Scope) : Bool
    abstract def length : Int32
    abstract def []?(sig : String) : Node?
    abstract def to_s : String
    abstract def type_id : Int32
    abstract def node_is_a?(_type : Node.class) : Bool
  end

  # Abstract base class for Node
  abstract class NodeClassBase
    include Node

    getter position : Lang::Position

    macro inherited
      def self.inherited_superclass : Node.class
        {{ @type.superclass }}
      end
    end

    def initialize(@position : Lang::Position)
    end

    # Class method to invoke the macro
    def self.methods_list
      Node.methods # This calls the macro at the class level
    end

    def eval_bool(scope : Scope) : Bool
      eval(scope).eval_bool(scope)
    end
  
    def length : Int32
      1
    end
  
    def []?(sig : String) : Node?
      nil
    end
  
    def to_s : String
      "#{self.class.name}@#{@position} ...\n" +
      self.class.methods_list.join("\n")
    end
  
    def type_id : Int32
      self.class.type_id
    end
  
    def node_is_a?(_type : Node.class) : Bool
      self.type_id == _type.type_id
    end
  
    def node_is_a_inh?(_type : Node.class) : Bool
      klass = self.class
      while klass
        return true if klass.type_id == _type.type_id
        klass = klass.inherited_superclass
      end
      false
    end
  end

  abstract struct NodeStructBase
    include Node
    Util.def_clone_methods

    getter position : Lang::Position

    def initialize(@position : Lang::Position)
    end

    # Struct method to invoke the macro
    def self.methods_list
      Node.methods # This calls the macro at the struct level
    end

    def to_s
      "#{self.class.name}@#{@position} ...\n" +
        self.class.methods_list.join("\n")
    end

    def eval(scope : Scope) : Node
      self
    end

    def eval_bool(scope : Scope) : Bool
      eval(scope).eval_bool(scope)
    end
  
    def length : Int32
      1
    end
  
    def []?(sig : String) : Node?
      nil
    end
  
    def to_s : String
      "#{self.class.name}@#{@position} ...\n" +
      self.class.methods_list.join("\n")
    end
  
    def type_id : Int32
      self.class.type_id
    end
  
    def node_is_a?(_type : Node.class) : Bool
      self.type_id == _type.type_id
    end
  end
end
