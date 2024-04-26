require "../type/fn.cr"

module Magiika
  # Descriptor
  abstract class Node::Desc < NodeClassBase
    include Desc

    @properties : Hash(String, NodeObj)?

    getter name

    def initialize(
        @name : String,
        @properties : Hash(String, NodeObj)? = nil)
    end

    def []?(ident : String) : NodeObj?
      @properties[ident]?
    end

    def has_properties? : ::Bool
      !@properties.nil?
    end

    abstract def validate : ::MatchResult
  end

  class Node::FnDesc < Node::Desc
    @properties : Hash(String, NodeObj)?
    @constraint : Node::Function?

    getter name

    forward_missing_to @constraint

    def initialize(
        name : String,
        properties : Hash(String, NodeObj)? = nil,
        @constraint : Node::Function? = nil)
      super(name, properties)
    end

    def can_be_validated? : ::Bool
      !@constraint.nil?
    end

    def validate : ::MatchResult
      constraint = @constraint
      return MatchResult.new(true) if constraint.nil?
      constraint.validate
    end

    def validate! : ::MatchResult
      constraint = @constraint
      raise Error::Internal.new("no constraint") if constraint.nil?
      constraint.validate
    end
  end
end
