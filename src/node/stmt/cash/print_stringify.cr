module Magiika
  class Node::CashPrintStringify < Node
    def initialize(
        position : Position?,
        @stmt : Node)
      super(position)
    end

    def eval(scope : Scope) : Node
      resolved_str = @stmt.eval(scope).to_s_internal
      print "✨ " + resolved_str + "\n"
      Node::Str.new(resolved_str)
    end
  end
end
