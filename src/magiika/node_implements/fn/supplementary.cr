module Magiika
  class Node::FnParam < NodeClass
    getter name : String
    getter _type : Psuedo::NodeIdent?
    getter descriptors : Set(Node::Desc)?
    getter value : Psuedo::Node?

    def initialize(
        @name : String,
        @_type : Psuedo::NodeIdent? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @value : Psuedo::Node? = nil,
        position : Position? = nil)
      super(position)
    end

    def initialize(
        @name : String,
        @_type : Psuedo::NodeIdent? = nil,
        descriptor : Node::Desc? = nil,
        @value : Psuedo::Node? = nil,
        position : Position? = nil)
      unless descriptor.nil?
        descriptors = Set(Node::Desc).new
        descriptors << descriptor
        @descriptors = descriptors
      end
      super(position)
    end

    def validate(node : Psuedo::Node) : MatchResult
      descriptors = @descriptors
      unless descriptors.nil?
        descriptors.each { |descriptor|
          result = descriptor.validate(node)
          return result unless result.matched?
        }
      end
      return MatchResult.new(true)
    end
  end

  alias Node::FnParams = Array(Node::FnParam)

  class Node::FnArg < NodeClass
    property name : String?
    property value : Psuedo::Node

    def initialize(
      @value : Psuedo::Node,
      @name : String? = nil)
    end
  end

  alias FnArgs = Array(Node::FnArg)

  record FnRet,
    _type : Psuedo::TypeNodeIdent? = nil,
    descs : Set(Node::Desc)? = nil
end
