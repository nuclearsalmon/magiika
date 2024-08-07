module Magiika
  class Node::Retrieve < Node
    getter ident : String

    def initialize(
        @ident : String,
        position : Position? = nil)
      super(position)
    end

    def eval(scope : Scope) : TypeNode
      meta = scope.get(@ident)

      case meta.visibility
      when Visibility::Public then
        meta.value.eval(scope)
      when Visibility::Protected then
        if (scope.responds_to?(:find_scope) &&
            (value = meta.value).responds_to?(:defining_scope) &&
            scope.find_scope(value.defining_scope))
          meta.value.eval(scope)
        end
        raise Error::Lazy.new("Access denied: Protected")
      when Visibility::Private then
        if (scope.responds_to?(:find_private_scope) &&
            (value = meta.value).responds_to?(:defining_scope) &&
            scope.find_private_scope(value.defining_scope))
          meta.value.eval(scope)
        end
        raise Error::Lazy.new("Access denied: Private")
      else
        raise Error::Lazy.new("Unknown visiblity: #{meta.visibility}")
      end
    end

    def eval_bool(scope : Scope) : ::Bool
      scope.get(@ident).eval_bool(scope)
    end
  end
end
