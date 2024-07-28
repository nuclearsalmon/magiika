module Type
  abstract def type_id : Typing::TypeID
  abstract def type_name : ::String
  abstract def superclass? : Typing::Type?

  def inherits_from_type?(other : Type) : ::Bool
    it_count = 0
    target : Type? = other.superclass?
    while target.is_a?(Type)
      return false if target.nil?
      return true if target.exact_type?(self)

      it_count += 1
      target = target.superclass?
      if it_count > Magiika::INHERITANCE_LIMIT
        raise Error::Type.new(
          other,
          self,
          "Exceeded inheritance limit when looking up #{other}.")
      end
    end
    false
  end

  def inherits_from_type!(other : Type) : ::Nil
    if !inherits_from_type?(other)
      raise Error::Type.new(
        other,
        self,
        "Expected #{self} to inherit from #{other}")
    end
  end

  def fits_exact_type?(other : Type) : ::Bool
    type_id == other.type_id
  end

  def fits_exact_type!(other : Type) : ::Nil
    if !fits_exact_type?(other)
      raise Error::Type.new(other, self, "Expected exact type")
    end
  end

  def fits_type?(other : Type) : ::Bool
    if other.responds_to?(:types)
      other.types.each { |_type|
        return true if fits_type?(_type)
      }
      return false
    else
      return true if fits_exact_type?(other)
      return inherits_from_type?(other)
    end
  end

  def fits_type!(other : Type) : ::Nil
    if !fits_type?(other)
      raise Error::Type.new(other, self)
    end
  end
end