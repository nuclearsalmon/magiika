module Magiika
  # Descriptor
  abstract class Node::Desc < Node
    @properties : Hash(String, Node)?

    getter name

    def initialize(
        @name : String,
        @properties : Hash(String, Node)? = nil)
    end

    def []?(ident : String) : Node?
      properties = @properties
      properties[ident]? unless properties.nil?
    end

    def has_properties? : ::Bool
      !@properties.nil?
    end

    abstract def validate(node : Node) : MatchResult
    abstract def validate!(node : Node) : MatchResult
  end

  #class Node::FnDesc < Node::Desc
  #  @properties : Hash(String, Node)?
  #  @fn : Node::Fn?
  #
  #  getter name
  #
  #  forward_missing_to @fn
  #
  #  def initialize(
  #      name : String,
  #      properties : Hash(String, Node)? = nil,
  #      @fn : Node::Fn? = nil)
  #    super(name, properties)
  #  end
  #
  #  def can_be_validated? : ::Bool
  #    !@fn.nil?
  #  end
  #
  #  def validate(node : Node) : MatchResult
  #    fn = @fn
  #    return MatchResult.new(true) if fn.nil?
  #    fn.validate
  #  end
  #
  #  def validate!(node : Node) : MatchResult
  #    fn = @fn
  #    raise Error::Internal.new("no fn") if fn.nil?
  #    fn.validate
  #  end
  #end
end
