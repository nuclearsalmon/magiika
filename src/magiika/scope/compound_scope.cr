module Magiika
  class Scope::Compound < Scope
    @scopes : Array(Scope)

    def initialize(@scopes : Array(Scope))
      super(position)
      raise Error::Internal.new("Compound scope should contain at least two scopes.") if @scopes.size < 2
    end

    def get?(ident : String) : Node::Meta?
      @scopes.each { |scope|
        obj = scope.get?(ident)
        return obj unless obj.nil?
      }
      return nil
    end

    def set(ident : String, meta : Node::Meta) : ::Nil
      raise Error::Internal.new("Compound scope cannot be empty.") if @scopes.size < 1
      @scopes[0].set(ident, meta)
    end

    def exist?(ident : String) : ::Bool
      @scopes.each { |scope|
        ret = scope.exist?(ident)
        return true if ret == true
      }
      return false
    end

    def find_global_scope() : Scope::Global
      raise Error::Internal.new("Compound scope cannot be empty.") if @scopes.size < 1
      @scopes[-1].find_global_scope
    end

    # this is...kind of terrible...but potentially convenient...
    Util.iterative_forward_missing_to @scopes
  end
end