module Magiika
  class Node::CashPrint < Node
    def initialize(
        position : Position?,
        @stmt : Node)
      super(position)
    end

    def eval(scope : Scope) : Node
      print "✨ " + @stmt.eval(scope).to_s_internal + "\n"
      Node::Nil.instance
    end
  end
end
