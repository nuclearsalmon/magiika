module Magiika
  class Node::Retrieve < Node
    include CallerEvalFeat

    getter ident : String

    def initialize(
        @ident : String,
        position : Position? = nil)
      super(position)
    end

    def eval(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : TypeNode
      caller_scope = eval_scope if caller_scope.nil?

      meta = eval_scope.retrieve(@ident)

      access_rights = Util.access_of?(eval_scope, caller_scope)
      allow_access = Util.access?(access_rights, meta.access)

      unless allow_access
        raise Error::Lazy.new(
          "Access denied - Need #{meta.access}, got #{access_rights}")
      end

      meta
    end

    def caller_eval(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : TypeNode
      eval(eval_scope, caller_scope)
    end

    def eval_bool(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : ::Bool
      eval(eval_scope, caller_scope).eval_bool(eval_scope)
    end

    def caller_eval_bool(
      eval_scope : Scope,
      caller_scope : Scope? = nil) : ::Bool
    eval_bool(eval_scope, caller_scope)
  end
  end
end
