module Magiika
  module TypeNode::InstanceIface
    include Node::InstanceIface


    # ⭐ Internal macros for delegation

    private macro delegate_to_typing(call)
      def {{call}}(_type : Psuedo::TypeNodeIdent)
        Typing.{{call}}(self, _type)
      end
    end

    private macro delegate_to_typing_extensive(call)
      delegate_to_typing({{call}}?)
      delegate_to_typing({{call}}!)
    end


    # ⭐ Delegated behaviour

    delegate_to_typing_extensive exact_type
    delegate_to_typing_extensive type
    delegate_to_typing_extensive inherits_type


    # ⭐ Member access

    # Data member access
    abstract def []?(ident : ::String) : Psuedo::Node?


    # ⭐ Evaluation

    abstract def eval(scope : Scope) : Psuedo::TypeNode


    # ⭐ Abstract requirements

    abstract def type_id : Typing::TypeID
    abstract def superclass : Psuedo::TypeNode?
  end

  module TypeNode::ClassIface
    include Node::ClassIface

    # ⭐ Abstract requirements

    abstract def type_id : Typing::TypeID
    abstract def superclass : Psuedo::TypeNode?
  end

  module TypeNode::InstanceTypingIface
    abstract def register_self : Typing::TypeID
    abstract def unregister_self : ::Nil
  end
end
