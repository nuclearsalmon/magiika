require "./nested_scope"


module Magiika
  class Scope::Fn < Scope::Nested
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

    protected def cleanup : ::Nil
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
  end
end
