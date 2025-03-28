module Magiika::CallerEvalFeat
  abstract def caller_eval(
    eval_scope : Scope,
    caller_scope : Scope? = nil) : AnyObject

  abstract def caller_eval_bool(
    eval_scope : Scope,
    caller_scope : Scope? = nil) : ::Bool
end
