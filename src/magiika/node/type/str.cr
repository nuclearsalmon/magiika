module Magiika
  class Node::Str < NodeClassBase
    def initialize(@value : ::String, position : Lang::Position? = nil)
      super(position)
    end

    def to_s_internal : String
      return @value.to_s
    end

    def eval(scope : Scope) : Node::Str
      return self
    end

    def eval_bool(scope : Scope) : ::Bool
      return @value != ""
    end


    # ⭐ Members
    # ---

    # define members code
    Magiika.def_members_feat

    private def self.__cash(scope : Scope::MethodScope) : NodeObj
      Magiika.def_scoped_vars self

      {% begin %}
        puts Node::Str.new(self_node.to_s_internal).to_s_internal
      {% end %}
      return Node::Nil.instance.as(NodeObj)
    end

    Magiika.def_fn "_$",
      __cash,
      nil,
      Node::Nil
  end
end
