module Magiika
  # Metadata for a stored Node
  class Node::Meta < NodeClassBase
    property data : NodeObj
    property descriptors : Set(Node::Desc)?
    property visibility : Visibility

    def initialize(
        @data : NodeObj,
        @_type : NodeType? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @visibility : Visibility = Visibility::Public,
        @static : ::Bool = false)
      verify_type!
      super(nil)
    end

    def inner_type? : NodeType?
      @_type
    end

    def type=(_type : NodeType)
      @_type = _type
    end

    def verify_type?(node : NodeObj) : ::Bool
      _type = @_type
      return Typing.type?(node, _type) unless _type.nil?
      true
    end

    def verify_type!(node : NodeObj)
      raise Error::InternalType.new unless verify_type?(node)
    end

    private def verify_type!
      verify_type!(@data)
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

    def static? : ::Bool
      @static
    end

    def eval(scope : Scope) : NodeObj
      @data.eval(scope)
    end
  end
end
