module Magiika
  # Descriptor
  abstract class Node::Desc < NodeClass
    @properties : Hash(String, Psuedo::Node)?

    getter name

    def initialize(
        @name : String,
        @properties : Hash(String, Psuedo::Node)? = nil)
    end

    def []?(ident : String) : Psuedo::Node?
      properties = @properties
      properties[ident]? unless properties.nil?
    end

    def has_properties? : ::Bool
      !@properties.nil?
    end

    abstract def validate(node : Psuedo::Node) : MatchResult
    abstract def validate!(node : Psuedo::Node) : MatchResult
  end

  #class Node::FnDesc < Node::Desc
  #  @properties : Hash(String, Psuedo::Node)?
  #  @fn : Node::Fn?
  #
  #  getter name
  #
  #  forward_missing_to @fn
  #
  #  def initialize(
  #      name : String,
  #      properties : Hash(String, Psuedo::Node)? = nil,
  #      @fn : Node::Fn? = nil)
  #    super(name, properties)
  #  end
  #
  #  def can_be_validated? : ::Bool
  #    !@fn.nil?
  #  end
  #
  #  def validate(node : Psuedo::Node) : MatchResult
  #    fn = @fn
  #    return MatchResult.new(true) if fn.nil?
  #    fn.validate
  #  end
  #
  #  def validate!(node : Psuedo::Node) : MatchResult
  #    fn = @fn
  #    raise Error::Internal.new("no fn") if fn.nil?
  #    fn.validate
  #  end
  #end
end
