module Magiika
  class Node::AbstFn < Node::Fn
    def initialize(
        position : Lang::Position,
        name : String,
        params : FnParams,
        returns : FnRet? = nil)
      super(position, name, params, returns)
    end

    def raise_uncallable_error
      raise Error::Internal.new("Abst fn is not callable.")
    end

    def call(args : Hash(String, NodeObj), scope : Scope) : NodeObj
      raise_uncallable_error
    end

    def call_safe(
        args : FnArgs,
        scope : Scope,
        deep_analysis : ::Bool = false) : MatchResult | NodeObj
      raise_uncallable_error
    end

    def call_safe_raise(args : FnArgs,
        scope : Scope,
        deep_analysis : ::Bool = false) : NodeObj
      raise_uncallable_error
    end

    def to_s_internal : String
      "abst fn #{pretty_sig}"
    end
  end
end
