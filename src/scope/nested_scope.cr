require "./scope"


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

    def set(ident : String, meta : Node::Meta, here : ::Bool = false) : ::Nil
      if exist_here?(ident)
        # check if the existing variable is a constant
        existing_value = @variables[ident]?

        if existing_value && existing_value.const?
          raise Error::Lazy.new("Cannot modify a constant value.")
        end

        # update variable in the current scope
        @variables[ident] = meta
      elsif !here && exist_elsewhere?(ident)
        # update variable in the parent scope where it exists
        @parent.set(ident, meta)
      else
        # create variable in the current scope
        @variables[ident] = meta
      end
    end

    def set_here(ident : String, meta : Node::Meta) : ::Nil
      set(ident, meta, here: true)
    end

    def set_here(ident : String, value : TypeNode) : ::Nil
      set(ident, Node::Meta.new(value), here: true)
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

    def find_scope(scope : Scope, i : Int32 = 0) : ::Bool
      if (parent = @parent) == scope
        true
      elsif parent.responds_to?(:find_scope)
        if i >= 64
          raise Error::Internal.new(
            "Potentially infinite scope chain detected" +
            " when traversing \"#{@parent}\".")
        end

        parent.find_scope(scope)
      else
        false
      end
    end

    def find_private_scope(scope : Scope) : ::Bool
      prev_scope = @parent
      i = 0
      loop do
        break unless prev_scope.is_a?(Scope::Cls)
        return true if prev_scope == scope

        prev_scope = prev_scope.parent
        i += 1

        if i >= 64
          raise Error::Internal.new(
            "Potentially infinite scope chain detected" +
            " when traversing \"#{@parent}\".")
        end
      end
      false
    end
  end
end
