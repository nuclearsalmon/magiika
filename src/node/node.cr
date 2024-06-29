abstract class Magiika::Node
  @position : Position?

  def initialize(@position : Position? = nil)
  end

  def position? : Position?
    @position
  end

  def position : Position
    position = position?
    return Position.default if position.nil?
    position
  end

  def position! : Position
    position = position?
    if position.nil?
      raise Error::Internal.new("No position specified.")
    end
    position
  end

  def eval(scope : Scope) : Node
    self
  end

  def eval_bool(scope : Scope) : ::Bool
    eval(scope).eval_bool(scope)
  end

  def type_name : ::String
    self.class.type_name
  end

  def to_s : ::String
    "#{ type_name } @ #{ position.to_s } ...\n#{ pretty_inspect }"
  end

  def to_s_internal : ::String
    "#{ type_name } @ #{ position.to_s }"
  end

  def self.type_name : ::String
    raise NotImplementedError.new("Should have been implemented via macro.")
  end

  macro finalized
    {% verbatim do %}
      def self.type_name : ::String
        {{ @type.name.stringify.split("::")[-1] }}
      end
    {% end %}
  end

  def self.to_s : ::String
    "#{ type_name } ...\n#{ pretty_inspect }"
  end

  def self.to_s_internal : ::String
    type_name
  end
end
