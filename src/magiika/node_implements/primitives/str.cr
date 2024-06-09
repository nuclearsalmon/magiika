module Magiika
  class Node::Str < TypeNodeClass::ClassTyping
    include Psuedo::Resolved

    def initialize(@value : ::String, position : Position? = nil)
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
    Members.def_members_feat

    private def self.__cash(scope : Scope::Fn) : Psuedo::TypeNode
      Members.def_scoped_vars self

      {% begin %}
        puts Node::Str.new(self_node.to_s_internal).to_s_internal
      {% end %}
      return Node::Nil.instance.as(Psuedo::TypeNode)
    end

    Members.def_fn "_$",
      __cash,
      nil,
      Node::Nil
  end
end
