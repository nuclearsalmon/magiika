module Magiika::Node
  abstract class Node
    macro methods
      {{ @type.methods.map &.name.stringify }}
    end

    property position : Lang::Position

    def initialize(@position : Lang::Position)
    end

    abstract def eval(scope : Magiika::Scope::Scope) : Node?

    def to_s
      return "#{self.class.name}@#{@position} ...\n" \
        + methods.join("\n")
    end
  end

  class VarMeta < Node
    property position : Lang::Position

    property name : String

    property nullable : ::Bool = false
    property const : ::Bool = false
    property _type : Node.class | Nil
    property value : Node?

    def initialize(
      @position : Lang::Position,
      @name : String,
      @_type : Type?,
      @value : Node::Node?,
      @nullable : ::Bool)
    end

    def magic?
      _type = @_type
      return _type.nil?
    end

    def eval(scope : Magiika::Scope::Scope) : Node?
      return @value
    end
  end

  class ClsVarMeta < VarMeta
    property accessor : Symbol
    property static : ::Bool = false

    def initialize(
      @position : Lang::Position,
      @name : String,
      @_type : Type?,
      @value : Node::Node?,
      @accessor : Symbol,
      @static : ::Bool)
    end
  end
end
