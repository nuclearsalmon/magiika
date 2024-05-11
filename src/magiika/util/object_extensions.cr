EXTEND_OBJECT = false

module Magiika::ObjectExtensions
  def upcase?(obj)
    s = to_s
    s.upcase == s
  end

  def downcase?(obj)
    s = to_s
    s.downcase == s
  end

  {% if EXTEND_OBJECT %}
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
{% else %}
  module Magiika::Util
    include Magiika::ObjectExtensions
    extend self
  end
{% end %}
