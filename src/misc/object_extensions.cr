EXTEND_OBJECT = false

module Magiika::Util
  extend self

  macro upcase?(obj)
    ((s = {{obj}}.to_s).upcase == s)
  end

  macro downcase?(obj)
    ((s = {{obj}}.to_s).downcase == s)
  end

  macro is_a!(obj, type)
    raise Error::InternalType.new unless {{obj}}.is_a?({{type}})
  end

  def ifNotNil(obj, &block)
    (obj != nil) ? yield(obj) : nil
  end
end

{% if EXTEND_OBJECT == true %}
  class ::Object
    macro upcase?
      Util.upcase?(self)
    end

    macro downcase?
      Util.downcase?(self)
    end

    def is_a!(type)
      Util.is_a!(self, type)
    end

    def ifNotNil(&block)
      Util.ifNotNil(self, &block)
    end
  end
{% end %}
