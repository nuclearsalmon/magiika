# For describing constraints in typing for a given field or expected type.
class Magiika::Object::TypeConstraint < Magiika::MetaObject
  getter type : AnyObject?
  getter? nilable : ::Bool

  def initialize(
    type : AnyObject? = nil,
    @nilable : ::Bool = false,
    position : Position? = nil,
    allow_slot : ::Bool = false
  )
    if !allow_slot && (type.is_a?(Object::Slot) || type.is_a?(Object::Slot.class))
      raise Error::Internal.new("#{Object::Slot} is not allowed.")
    end
    @type = type
    super(position)
  end

  def magic? : ::Bool
    @type.nil?
  end
end
