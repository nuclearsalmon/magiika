EXTEND_OBJECT = false

module Magiika::Util
  extend self

  macro upcase?(obj)
    ((s = {{obj}}.to_s).upcase == s)
  end

  macro downcase?(obj)
    ((s = {{obj}}.to_s).downcase == s)
  end

  macro is_a!(obj, _type)
    raise Error::InternalType.new unless {{obj}}.is_a?({{_type}})
  end
end

{% if EXTEND_OBJECT == true %}
  class Object
    macro upcase?
      Util.upcase?(self)
    end

    macro downcase?
      Util.downcase?(self)
    end

    def is_a!(_type)
      Util.is_a!(self, _type)
    end
  end
{% end %}
