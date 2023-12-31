require "./context.cr"


module Magiika::Lang
  private alias RuleReturn = \
    Hash(Symbol, Node | MatchedToken | Array(Node) | Array(MatchedToken))

  private alias RuleBlock = \
    RuleContext \
    -> RuleReturn

  private record Rule,
    pattern : Array(Symbol),
    block : RuleBlock?
end