module Magiika::Members
  macro _cash
    private def self.__cash(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self

      {% begin %}
        return Node::Str.new(self_node.to_s_internal).as(NodeObj)
      {% end %}
    end

    Magiika.def_fn "_$",
      __cash,
      nil,
      Node::Str
  end
end
