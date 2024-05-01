module Magiika
  # Descriptor
  abstract class Node::Desc < NodeClassBase
    @properties : Hash(String, NodeObj)?

    getter name

    def initialize(
        @name : String,
        @properties : Hash(String, NodeObj)? = nil)
    end

    def []?(ident : String) : NodeObj?
      properties = @properties
      properties[ident]? unless properties.nil?
    end

    def has_properties? : ::Bool
      !@properties.nil?
    end

    abstract def validate(node : NodeObj) : MatchResult
    abstract def validate!(node : NodeObj) : MatchResult
  end

  #class Node::FnDesc < Node::Desc
  #  @properties : Hash(String, NodeObj)?
  #  @fn : Node::Function?
  #
  #  getter name
  #
  #  forward_missing_to @fn
  #
  #  def initialize(
  #      name : String,
  #      properties : Hash(String, NodeObj)? = nil,
  #      @fn : Node::Function? = nil)
  #    super(name, properties)
  #  end
  #
  #  def can_be_validated? : ::Bool
  #    !@fn.nil?
  #  end
  #
  #  def validate(node : NodeObj) : MatchResult
  #    fn = @fn
  #    return MatchResult.new(true) if fn.nil?
  #    fn.validate
  #  end
  #
  #  def validate!(node : NodeObj) : MatchResult
  #    fn = @fn
  #    raise Error::Internal.new("no fn") if fn.nil?
  #    fn.validate
  #  end
  #end
end
