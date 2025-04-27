require "./is_of"

module CrystalUtils
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

  # Returns the class of the object if it is not already a class.
  macro to_class(obj)
    obj.class unless obj.is_a?(::Object.class)
  end
  
  macro pvar(stmt)
    puts "{{ stmt }}:\n  #{ {{ stmt }}.pretty_inspect }"
  end

  def s_to_bool(
      str : ::String, 
      case_sensitive : ::Bool = true,
      matches : Array(String) = ["true", "false"]
    ) : ::Bool
    str = str.downcase unless case_sensitive
    match = matches[0] # "true"
    match = match.downcase unless case_sensitive
    return true if str == match
    
    match = matches[1] # "false" 
    match = match.downcase unless case_sensitive
    return false if str == match
    raise ::Exception::TypeCastError.new("cast to Bool failed: #{str}")
  end

  macro env_exists?(key)
    !(ENV.[{{ key }}]?.nil?)
  end

  # for use in compile-time expressions
  def env_to_bool(key : ::String) : ::Bool
    value = ENV.[key]?.try &.downcase || "false"
    return false if value == "false"
    return true if value == "true"
    raise ::TypeCastError.new("cast to Bool failed: #{ENV.[key]? || "false"}")
  end
end

CRYSTAL_UTILS_DO_PATCH = CrystalUtil.env_to_bool("CRYSTAL_UTILS_DO_PATCH")
{% if CRYSTAL_UTILS_DO_PATCH %}
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

  class ::String
    def to_bool : ::Bool
      Util.s_to_bool(self)
    end
  end
{% end %}
