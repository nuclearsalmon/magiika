# For describing constraints in typing for a given field or expected type.
class Magiika::Object::TypeConstraint < Magiika::MetaObject
  getter type : AnyObject?
  getter? nilable : ::Bool

  def initialize(
    @type : AnyObject? = nil,
    @nilable : ::Bool = false,
    position : Position? = nil,
  )
    super(position)
  end

  def magic? : ::Bool
    @type.nil?
  end
end
