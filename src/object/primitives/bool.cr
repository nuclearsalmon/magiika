class Magiika::Object::Bool < Magiika::PrimitiveObject
  def initialize(@value : ::Bool, position : Position? = nil)
    super(position)
  end

  def to_s_internal : ::String
    return @value.to_s
  end

  def eval_bool(scope : Scope) : ::Bool
    return @value
  end
end
