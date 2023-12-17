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

  abstract class NodeOld
    macro methods
      {{ @type.methods.map &.name.stringify }}
    end

    TYPE_IDS = {} of String => Int32

    #TYPE_IDS = begin
    #  {% begin %}
    #    {% types = @type.subclasses %}
    #    {% hash = {} of Nil => Nil %}
    #    {% types.each_with_index { |type, i| hash[type.name.stringify] = i } %}
    #    {{ hash }}
    #  {% end %}
    #end

    #@@next_type_id : Int32 = 0
    #@@type_ids : Hash(String, Int32) = {} of String => Int32

    ## Class method to get next_type_id
    #def self.next_type_id : Int32
    #  @@next_type_id
    #end

    # Class method to get type_ids
    #def self.type_ids : Hash(String, Int32)
    #  @@type_ids
    #end

    #def self.inc_next_type_id
    #  @@next_type_id += 1
    #end
    
    macro inherited
      # Increment next_type_id and assign a unique type id to the subclass
      #Node.type_ids[{{@type.name.stringify}}] = Node.next_type_id
      #Node.inc_next_type_id

      def self.type_id : Int32
        {{ Magiika::Node::TYPE_IDS.size }}
      end
  
      {% Magiika::Node::TYPE_IDS[@type.name.stringify] \
        = Magiika::Node::TYPE_IDS.size %}

      # Generate a method that returns the superclass as a constant
      def self.inherited_superclass : Node.class
        {{ @type.superclass }}
      end
    end

    getter position : Lang::Position
    #protected getter members : Hash(String, Magiika::Node)

    def initialize(@position : Lang::Position)
      #@members = Hash(String, Magiika::Node).new
      #@members["type"] = NativeFn.new(
      #  "type", 
      #  FnParams.new,
      #  [Constraint.new(Str)],
      #  Proc(Scope::Scope, Node).new { Str.new("node").as(Str) })
    end

    abstract def eval(scope : Scope) : Node

    def eval_bool(scope : Scope) : ::Bool
      return eval(scope).eval_bool(scope)
    end

    def length : ::Int32
      return 1
    end

    # method lookup
    def []?(sig : String) : Node?
      return nil
      #return @members[sig]?
    end

    def to_s
      return "#{self.class.name}@#{@position} ...\n" \
        + methods.join("\n")
    end

    def type_id
      self.class.type_id
    end

    def node_is_a?(_type : Node.class) : ::Bool
      self.type_id == _type.type_id
    end

    # Instance method to check if the node is a kind of a given type
    def node_is_a_inh?(_type : Node.class) : ::Bool
      klass = self.class
      while klass
        return true if klass.type_id == _type.type_id
        klass = klass.inherited_superclass
      end
      false
    end
  end
end
