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

    def inject(args : Hash(String, TypeNode)) ::Nil
      args.each{ |name, value|
        set(name, value)
      }
    end

    def set(ident : String, meta : Node::Meta) : ::Nil
      super(ident, meta)
      value = meta.value
      if value.is_a?(InstTypeNode)
        value.register_type
      end
    end

    def cleanup : ::Nil
      @variables.each { |key, value|
        if value.is_a?(Node::Cls)
          if value.is_a?(InstTypeNode)
            value.unregister_type
          end
        end
      }
    end

    def self.use(
        name : String,
        parent : Scope,
        position : Position? = nil)
      scope = new(name, parent, position)
      begin
        yield scope
      ensure
        scope.cleanup
      end
    end

    def seek(&block : Scope -> R) : R? forall R
      result = @parent.seek(&block)
      return result unless result.nil?
      block.call(self)
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

    def find_base_scope : Scope::Standalone
      @parent.find_base_scope
    end

    private def find_scope(scope : Scope, i : Int32) : ::Bool
      if (parent = @parent) == scope
        true
      elsif parent.responds_to?(:find_scope)
        if i >= 64
          raise Error::Internal.new(
            "Potentially infinite scope chain detected" +
            " when traversing \"#{@parent}\".")
        end

        i += 1
        parent.find_scope(scope, i)
      else
        false
      end
    end

    def find_scope(scope : Scope) : ::Bool
      find_scope(scope, 0)
    end
  end
end
