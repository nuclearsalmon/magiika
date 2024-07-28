module Magiika
  class Node::FnParam < Node
    getter name : String
    getter _type : Typing::EvalsToType?
    getter descriptors : Set(Node::Desc)?
    getter value : Node?

    def initialize(
        @name : String,
        @_type : Typing::EvalsToType? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @value : Node? = nil,
        position : Position? = nil)
      super(position)
    end

    def initialize(
        @name : String,
        @_type : Typing::EvalsToType? = nil,
        descriptor : Node::Desc? = nil,
        @value : Node? = nil,
        position : Position? = nil)
      unless descriptor.nil?
        (@descriptors = Set(Node::Desc).new) << descriptor
      end
      super(position)
    end

    def validate(node : Node) : MatchResult
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

  alias FnParams = Array(Node::FnParam)

  class Node::FnArg < Node
    property name : String?
    property value : Node

    def initialize(
      @value : Node,
      @name : String? = nil)
    end
  end

  alias FnArgs = Array(Node::FnArg)

  record FnRet,
    _type : Typing::EvalsToType? = nil,
    descs : Set(Node::Desc)? = nil
end
