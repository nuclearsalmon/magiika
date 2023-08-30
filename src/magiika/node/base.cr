module Magiika::Node
  abstract class Node
    macro methods
      {{ @type.methods.map &.name.stringify }}
    end

    private alias OperationMethod = \
      Array(Magiika::Node::Node), \
      Magiika::Scope::Scope \
      -> Magiika::Node::Node
    private alias OperationMethodByName = \
      Hash(String, OperationMethod)
    private alias OperationMethodsByNargs = \
      Hash(Int32, OperationMethod)


    getter position : Lang::Position

    def initialize(@position : Lang::Position)
    end

    abstract def eval(scope : Magiika::Scope::Scope) : Magiika::Node::Node

    def [](nargs) : OperationMethodsByNargs
      # { 2: {
      #      "==": -> { |r| eq (r) }
      #   }
      # }
      OperationMethodsByNargs.new
    end

    def to_s
      return "#{self.class.name}@#{@position} ...\n" \
        + methods.join("\n")
    end
  end

  class VarMeta < Magiika::Node::Node
    property position : Lang::Position

    property name : String

    property nullable : ::Bool = false
    property const : ::Bool = false
    property _type : Node.class | Nil
    property value : Node

    def initialize(
      position : Lang::Position,
      @name : String,
      @_type : Type?,
      @value : Magiika::Node::Node,
      @nullable : ::Bool)
      super(position)
    end

    def magic?
      _type = @_type
      return _type.nil?
    end

    def eval(scope : Magiika::Scope::Scope) : Magiika::Node::Node
      return @value
    end
  end

  class ClsVarMeta < VarMeta
    property accessor : Symbol
    property static : ::Bool = false

    def initialize(
      position : Lang::Position,
      name : String,
      _type : Type?,
      value : Magiika::Node::Node,
      nullable : ::Bool,
      @accessor : Symbol,
      @static : ::Bool)
      super(position, name, _type, value, nullable)
    end
  end
end
