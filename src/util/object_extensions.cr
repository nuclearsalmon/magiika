EXTEND_OBJECT = false

module Magiika::Util
  extend self

  macro is_a!(obj, _type)
    raise Error::InternalType.new unless {{obj}}.is_a?({{_type}})
  end

  abstract def is_a_node?(obj)
  def_iface_is_a(node, Node::InstanceIface, Node::ClassIface)

  abstract def is_a_type_node?(obj)
  def_iface_is_a(type_node, TypeNode::InstanceIface, TypeNode::ClassIface)
end

{% if EXTEND_OBJECT == true %}
  class Object
    def is_a!(_type)
      Util.is_a!(self, _type)
    end

    def is_a_node?
      Util.is_a_node?(self)
    end

    def is_a_type_node?
      Util.is_a_type_node?(self)
    end
  end
{% end %}
