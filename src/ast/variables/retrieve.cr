module Magiika
  class Ast::Retrieve < AstBase
    include CallerEvalFeat

    def initialize(
        @name : ::String,
        position : Position? = nil)
      super(position)
    end

    def eval(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : AnyObject
      caller_scope = eval_scope if caller_scope.nil?

      info = eval_scope.retrieve(@name)

      access_rights = AccessControl.access_of?(eval_scope, caller_scope)
      allow_access = AccessControl.access?(access_rights, info.access)

      unless allow_access
        raise Error::Lazy.new(
          "Access denied - Need #{info.access}, got #{access_rights}")
      end

      info
    end

    def caller_eval(
        eval_scope : Scope,
        caller_scope : Scope? = nil) : AnyObject
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
