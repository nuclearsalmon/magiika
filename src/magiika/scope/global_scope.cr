require "./scope.cr"


module Magiika
  class Scope::Global < Scope
    @variables = Hash(String, Node::Meta).new

    def initialize(
        position : Position)
      super("global", position)
    end

    def get?(ident : String) : Node::Meta?
      @variables[ident]?
    end

    def set(ident : String, meta : Node::Meta) : ::Nil
      # check if the existing variable is a constant
      if @variables[ident]?.try(&.const?)
        raise Error::Lazy.new("Cannot modify a constant value.")
      end

      # create variable in the current scope
      @variables[ident] = meta
    end

    def exist?(ident : String) : ::Bool
      @variables.has_key?(ident)
    end

    def find_global_scope : Global
      return self
    end
  end
end
