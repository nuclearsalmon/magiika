require "../type/fn.cr"

module Magiika
  class Node::DescFn < Node::Function
    @properties : Hash(String, Node)?
    @constraint : Node::Function?

    forward_missing_to @constraint

    def initialize(
        name : String,
        @properties : Hash(String, Node)? = nil,
        @constraint : Node::Function? = nil)


      super(name, params, returns)
    end

    def []?(ident : String) : Node?
      @properties[ident]?
    end

    def has_properties? : ::Bool
      !@properties.nil?
    end

    def can_be_validated? : ::Bool
      !@constraint.nil?
    end

    def validate : ::MatchResult
      constraint = @constraint
      raise Error::Internal.new("no constraint") if constraint.nil?
      constraint.validate
    end
  end
end
