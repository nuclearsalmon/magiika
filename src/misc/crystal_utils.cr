require "./is_of"

module CrystalUtils
  extend self

  macro env_exists?(key)
    !ENV.fetch(key, nil).nil?
  end

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

  # Returns the class of the object if it is not already a class.
  macro to_class(obj)
    obj.class unless obj.is_a?(::Object.class)
  end
  
  macro pvar(stmt)
    puts "{{ stmt }}:\n  #{ {{ stmt }}.pretty_inspect }"
  end
end

EXTEND_OBJECT = CrystalUtils.env_exists?("EXTEND_OBJECT")
{% if EXTEND_OBJECT == true %}
  class ::Object
    include IsOf

    def upcase? : ::Bool
      Util.upcase? self
    end

    def downcase? : ::Bool
      Util.downcase? self
    end

    def is_a!(type)
      Util.is_a! self, type
    end

    def ifNotNil(&block)
      Util.ifNotNil(self, &block)
    end

    def to_class : ::Object.class
      Util.to_class self
    end
  end
{% end %}
