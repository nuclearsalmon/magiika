module Magiika::Scope
  class Global < Scope
    @variables = Hash(String, Node::Node).new

    def initialize(
      @name : String,
      @position : Lang::Position)
    end

    def get?(ident : Lang::MatchedToken) : Node::Node?
      if @variables.has_key?(ident.value)
        return @variables[ident.value]
      else
        return nil
      end
    end

    def get(ident : Lang::MatchedToken) : Node::Node
      obj = get?(ident)
      return obj unless obj.nil?
      raise Error::UndefinedVariable.new(ident, self, ident.pos)
    end

    def set(ident : Lang::MatchedToken, value : Node::Node) : Nil
      #current = get(ident)
      #if !current.nil? && current.const
      #  raise Error::Internal.new("Cannot assign to const.")
      #end
      @variables[ident.value] = value
    end

    def exist?(ident : Lang::MatchedToken) : ::Bool
      return !get?(ident).nil?
    end

    def find_global_scope : Global
      return self
    end
  end
end
