module Magiika
  # ⭐ TypeNode

  abstract class Psuedo::TypeNodeClass < Psuedo::NodeClass
    include TypeNode::InstanceIface
    extend TypeNode::ClassIface
  end

  abstract struct Psuedo::TypeNodeStruct < Psuedo::NodeStruct
    include TypeNode::InstanceIface
    extend TypeNode::ClassIface
  end

  alias Psuedo::TypeNode =
    Psuedo::TypeNodeClass #| Psuedo::TypeNodeStruct

  abstract class Psuedo::TypeNodeClassInstanceTyping < Psuedo::TypeNodeClass
    include Magiika::TypeNode::InstanceTypingIface
  end

  abstract struct Psuedo::TypeNodeStructInstanceTyping < Psuedo::TypeNodeStruct
    include Magiika::TypeNode::InstanceTypingIface
  end

  alias Psuedo::TypeNodeInstanceTyping =
    Psuedo::TypeNodeClassInstanceTyping #| Psuedo::TypeNodeStructInstanceTyping

  # ⭐ TypeNode as identifier

  alias Psuedo::TypeNodeIdent =
    Psuedo::TypeNodeClass.class |
    #Psuedo::TypeNodeStruct.class |
    Psuedo::TypeNodeClassInstanceTyping #| Psuedo::TypeNodeStructInstanceTyping

  # NOTE: Functions sort of like an "Any" type.
  # Should probably not be used.
  alias Psuedo::NodeIdent =
    Psuedo::TypeNodeIdent |
    Psuedo::Node
end
