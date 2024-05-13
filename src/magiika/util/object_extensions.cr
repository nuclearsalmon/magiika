EXTEND_OBJECT = false

module Magiika::ObjectExtensions
  def upcase?(obj)
    s = obj.to_s
    s.upcase == s
  end

  def downcase?(obj)
    s = obj.to_s
    s.downcase == s
  end

  {% if EXTEND_OBJECT == true %}
    def upcase?
      upcase?(self)
    end

    def downcase?
      downcase?(self)
    end
  {% else %}
    extend self
  {% end %}
end

{% if EXTEND_OBJECT %}
  class Object
    include Magiika::ObjectExtensions
  end
{% end %}

module Magiika::Util
  include Magiika::ObjectExtensions
  extend self
end
