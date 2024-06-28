module Magiika
  # Metadata for a stored Node
  class Node::Meta < TypeNode::ClassTyping
    property value : TypeNode
    property descriptors : Set(Node::Desc)?
    property visibility : Visibility

    def initialize(
        @value : TypeNode,
        @_type : TypeNodeIdent? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @visibility : Visibility = Visibility::Public)
      verify_type!
      super(nil)
    end

    def inner_type? : TypeNodeIdent?
      @_type
    end

    def type=(_type : TypeNodeIdent)
      @_type = _type
    end

    def verify_type?(node : TypeNode) : ::Bool
      _type = @_type
      return Typing.type?(node, _type) unless _type.nil?
      true
    end

    def verify_type!(node : TypeNode)
      raise Error::InternalType.new unless verify_type?(node)
    end

    private def verify_type!
      verify_type!(@value)
    end

    def magic? : ::Bool
      @_type.nil?
    end

    def nilable? : ::Bool
      true
    end

    def const? : ::Bool
      false
      #descriptors = @descriptors
      #return false if descriptors.nil?
      #descriptors.any? { |descriptor| descriptor.is_a?(ConstConstraint) }
    end

    def eval(scope : Scope) : TypeNode
      @value.eval(scope)
    end
  end
end
