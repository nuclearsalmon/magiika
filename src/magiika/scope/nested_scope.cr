require "./scope.cr"


module Magiika
  class Scope::NestedScope < Scope
    @variables : Hash(String, Node::Meta) = {} of String => Node::Meta
    property parent : Scope

    def initialize(name : String, position : Lang::Position, @parent : Scope)
      super(name, position)
    end

    def get?(ident : String) : Node::Meta?
      variable = @variables[ident]?
      return variable if variable
      @parent.get?(ident).as(Node::Meta?)
    end

    private def prepare_value(value : NodeObj) : Node::Meta
      if value.is_a?(Node::Meta)
        if value.const?
          raise Error::Internal.new("Cannot modify a constant value.")
        end

        value
      else
        Node::Meta.new(value)
      end
    end

    def set(ident : String, value : NodeObj) : Nil
      if exist_here?(ident)
        # check if the existing variable is a constant
        existing_value = @variables[ident]?
        raise "Cannot modify a constant value." if existing_value && existing_value.const?

        # update variable in the current scope
        @variables[ident] = prepare_value(value)
      elsif exist_elsewhere?(ident)
        # update variable in the parent scope where it exists
        @parent.set(ident, value)
      else
        # create variable in the current scope
        @variables[ident] = prepare_value(value)
      end
    end

    def exist?(ident : String) : ::Bool
      @variables.has_key?(ident) || @parent.exist?(ident)
    end

    def exist_here?(ident : String) : ::Bool
      @variables.has_key?(ident)
    end

    def exist_elsewhere?(ident : String) : ::Bool
      @parent.exist?(ident)
    end

    def find_global_scope : Scope
      @parent.find_global_scope
    end
  end
end
