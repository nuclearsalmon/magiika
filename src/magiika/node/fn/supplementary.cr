module Magiika
  class Node::FnParam < NodeClassBase
    getter name : String
    getter _type : NodeAny?
    getter descriptors : Set(Node::Desc)?
    getter value : NodeObj?

    def initialize(
        @name : String,
        @_type : NodeAny? = nil,
        @descriptors : Set(Node::Desc)? = nil,
        @value : NodeObj? = nil,
        position : Lang::Position? = nil)
      super(position)
    end

    def initialize(
        @name : String,
        @_type : NodeAny? = nil,
        descriptor : Node::Desc? = nil,
        @value : NodeObj? = nil,
        position : Lang::Position? = nil)
      unless descriptor.nil?
        descriptors = Set(Node::Desc).new
        descriptors << descriptor
        @descriptors = descriptors
      end
      super(position)
    end

    def validate(node : NodeObj) : MatchResult
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

  #record FnArg,
  #  name : String?,
  #  value : NodeObj

  class Node::FnArg < NodeClassBase
    getter name : String?
    getter value : NodeObj

    def initialize(@value : NodeObj, @name : String? = nil)
    end
  end

  alias FnArgs = Array(Node::FnArg)

  record FnRet,
    _type : NodeType? = nil,
    descs : Set(Node::Desc)? = nil
end
