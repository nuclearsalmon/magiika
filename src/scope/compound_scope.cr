module Magiika
  class Scope::Compound < Scope
    @scopes : Array(Scope)

    def initialize(@scopes : Array(Scope))
      super(position)
      raise Error::Internal.new("Compound scope must contain at least two scopes.") if @scopes.size < 2
    end

    def cleanup : ::Nil; end


    # ✨ Setting values
    # ---

    def define(name : String, meta : Node::Meta) : ::Nil
      if exist?(name)
        raise Error::Internal.new("Variable already exists: \'#{@name}\'")
      else
        @scopes[0].define(name, meta)
      end
    end

    def replace(name : String, meta : Node::Meta) : ::Nil
      scope = find_var_scope(name)
      if scope.nil?
        raise Error::Internal.new("Variable does not exist: \'#{@name}\'")
      else
        scope.replace(name, meta)
      end
    end

    def assign(name : String, meta : Node::Meta) : ::Nil
      scope = find_var_scope(name)
      if scope.nil?
        @scopes[0].assign(name, meta)
      else
        scope.assign(name, meta)
      end
    end


    # ✨ Retrieving values
    # ---

    def retrieve?(name : String) : Node::Meta?
      @scopes.each { |scope|
        meta = scope.retrieve?(name)
        return meta unless meta.nil?
      }
    end


    # ✨ Iterate or locate
    # ---

    def exist?(name : String) : ::Bool
      @scopes.each { |scope|
        return true if scope.exist?(name)
      }
      return false
    end

    def exist_here?(name : String) : ::Bool
      exist?(name)
    end

    private def find_var_scope(name : String) : Scope?
      @scopes.each { |scope|
        return scope if scope.exist?(name)
      }
    end

    def seek(&block : Scope -> R) : R? forall R
      @scopes.each { |scope|
        result = scope.seek(&block)
        break result unless result.nil?
      }
    end

    def find_base_scope : Scope::Standalone
      raise Error::Internal.new("Compound scope cannot be empty.") if @scopes.size < 1
      @scopes[-1].find_base_scope
    end
  end
end