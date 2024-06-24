module Magiika
  # ⭐ Base

  abstract class TypeNodeClass < Psuedo::TypeNodeClass
    extend Node::ClassDefaults
    include Node::InstanceDefaults

    extend TypeNode::ClassDefaults
    include TypeNode::InstanceDefaults
  end

  abstract struct TypeNodeStruct < Psuedo::TypeNodeStruct
    extend Node::ClassDefaults
    include Node::InstanceDefaults

    extend TypeNode::ClassDefaults
    include TypeNode::InstanceDefaults
  end


  # ⭐ Instance typing

  abstract class TypeNodeClass::InstanceTyping < Psuedo::TypeNodeClassInstanceTyping
    extend Node::ClassDefaults
    include Node::InstanceDefaults

    extend TypeNode::ClassDefaults
    include TypeNode::InstanceDefaults

    include TypeNode::InstanceTypingDefaults
  end

  abstract struct TypeNodeStruct::InstanceTyping < Psuedo::TypeNodeStructInstanceTyping
    extend Node::ClassDefaults
    include Node::InstanceDefaults

    extend TypeNode::ClassDefaults
    include TypeNode::InstanceDefaults

    include TypeNode::InstanceTypingDefaults
  end


  # ⭐ Class typing

  abstract class TypeNodeClass::ClassTyping < TypeNodeClass
    extend TypeNode::ClassTypingDefaults
  end

  abstract struct TypeNodeStruct::ClassTyping < TypeNodeStruct
    extend TypeNode::ClassTypingDefaults
  end


  # ⭐ Dual typing

  abstract class TypeNodeClass::DualTyping < Psuedo::TypeNodeClassInstanceTyping
    extend Node::ClassDefaults
    include Node::InstanceDefaults

    extend TypeNode::ClassDefaults
    include TypeNode::InstanceDefaults

    extend TypeNode::ClassTypingDefaults
    include TypeNode::InstanceTypingDefaults
  end

  abstract struct TypeNodeStruct::DualTyping < Psuedo::TypeNodeStructInstanceTyping
    extend Node::ClassDefaults
    include Node::InstanceDefaults

    extend TypeNode::ClassDefaults
    include TypeNode::InstanceDefaults

    extend TypeNode::ClassTypingDefaults
    include TypeNode::InstanceTypingDefaults
  end
end
