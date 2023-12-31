require "./scope.cr"


module Magiika
  class Scope::Global < Scope
    @variables = Hash(String, Node::Meta).new

    def initialize(
        name : String,
        position : Lang::Position)
      super(name, position)
    end

    def get?(ident : String) : Node::Meta?
      @variables[ident]?
    end

    private def prepare_value(value : Node) : Node::Meta
      if value.is_a?(Node::Meta)
        if value.is_const?
          raise Error::Internal.new("Cannot modify a constant value.")
        end

        value
      else
        Node::Meta.new(value, [] of Node::Constraint)
      end
    end

    def set(ident : String, value : Node) : Nil
      if exist_here?(ident)
        # check if the existing variable is a constant
        existing_value = @variables[ident]?
        raise "Cannot modify a constant value." if existing_value && existing_value.is_const?
        
        # update variable in the current scope
        @variables[ident] = prepare_value(value)
      else
        # create variable in the current scope
        @variables[ident] = prepare_value(value)
      end
    end

    def exist?(ident : String) : ::Bool
      @variables.has_key?(ident)
    end

    def exist_here?(ident : String) : Bool
      @variables.has_key?(ident)
    end

    def find_global_scope : Global
      return self
    end
  end
end
