module Magiika
  class Node::Str < TypeNode::ClassTyping
    include Psuedo::Resolved

    protected getter value : ::String

    def initialize(@value : ::String, position : Position? = nil)
      super(position)
    end

    def to_s_internal : ::String
      "\"#{@value}\""
    end

    def eval(scope : Scope) : Node::Str
      self
    end

    def eval_bool(scope : Scope) : ::Bool
      @value != ""
    end


    # ⭐ Members
    # ---

    # define members code
    Members.def_members_feat

    private def self.__cash(scope : Scope::Fn) : TypeNode
      Members.def_scoped_vars self

      {% begin %}
        puts self_node.as(Node::Str).value
      {% end %}
      return Node::Nil.instance.as(TypeNode)
    end

    Members.def_fn "_$",
      __cash,
      nil,
      Node::Nil
  end
end
