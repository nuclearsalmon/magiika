module Magiika::Scope
  class Base < Magiika::Scope::Scope
    @variables = Hash(String, Node::Node).new
  
    def initialize(
      @name : String,
      @parent : Scope?,
      @position : Lang::Position)
    end
  
    def get?(ident : Lang::MatchedToken) : Node::Node?
      obj = @variables[ident.content]
      if not obj.nil?
        return obj
      else
        parent = @parent
        if not parent.nil?
          return parent.get?(ident)
        end
      end
      return nil
    end
  
    def get(ident : Lang::MatchedToken) : Node::Node
      obj = get?(ident)
      return obj unless obj.nil?
      raise Error::UndefinedVariable.new(ident, self, ident.position)
    end
  
    def set(ident : Lang::MatchedToken, value : Node::Node) : Nil
      current = get(ident)
      parent = @parent
      if current.nil? || parent.nil?
        if current.const
          raise Error::Internal.new("Cannot assign to const.")
        end
        @variables[ident.content] = value
      else
        parent = @parent
        if @variables.has_key?(ident.content) || parent.nil?
          @variables[ident.content] = value
        else
          @parent.set(ident, value)
        end
      end
    end
  
    def exist?(ident : Lang::MatchedToken) : Bool
      return !get?(ident).nil?
    end
  
    def find_global_scope : Scope::Global
      parent = @parent
      while (!parent.nil? && !parent.parent.nil?)
        parent = parent.parent
      end
  
      # TODO: check if parent is global scope
      unless parent.is_a?(Scope::Global)
        raise Error::Internal.new(\
          "The bottom scope was not the global scope.")
      end
  
      return parent
    end
  end
end
