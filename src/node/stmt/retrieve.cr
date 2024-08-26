module Magiika
  class Node::Retrieve < Node
    getter ident : String

    def initialize(
        @ident : String,
        position : Position? = nil)
      super(position)
    end

    def eval(eval_scope : Scope, caller_scope : Scope? = nil) : TypeNode
      caller_scope = eval_scope if caller_scope.nil?

      meta = eval_scope.get(@ident)

      access_rights = Util.access_of?(eval_scope, caller_scope)
      allow_access = Util.access?(access_rights, meta.access)

      unless allow_access
        raise Error::Lazy.new(
          "Access denied - Need #{meta.access}, got #{access_rights}")
      end

      meta
    end

    def eval_bool(scope : Scope) : ::Bool
      scope.get(@ident).eval_bool(scope)
    end
  end
end
