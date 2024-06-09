require "./scope.cr"


module Magiika
  class Scope::Nested < Scope
    protected getter parent : Scope
    protected getter variables : Hash(String, Node::Meta)

    def initialize(
        name : String,
        @parent : Scope,
        position : Position? = nil,
        @variables : Hash(String, Node::Meta) =
          Hash(String, Node::Meta).new)
      super(name, position)
    end

    def get?(ident : String) : Node::Meta?
      variable = @variables[ident]?
      return variable if variable
      @parent.get?(ident).as(Node::Meta?)
    end

    def set(ident : String, meta : Node::Meta) : ::Nil
      if exist_here?(ident)
        # check if the existing variable is a constant
        existing_value = @variables[ident]?

        if existing_value && existing_value.const?
          raise Error::Lazy.new("Cannot modify a constant value.")
        end

        # update variable in the current scope
        @variables[ident] = meta
      elsif exist_elsewhere?(ident)
        # update variable in the parent scope where it exists
        @parent.set(ident, meta)
      else
        # create variable in the current scope
        @variables[ident] = meta
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

    def find_global_scope : Scope::Global
      @parent.find_global_scope
    end
  end
end
