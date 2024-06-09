module Magiika
  abstract class Psuedo::NodeClass
    include Node::InstanceIface
    extend Node::ClassIface
  end

  abstract struct Psuedo::NodeStruct
    include Node::InstanceIface
    extend Node::ClassIface
  end

  alias Psuedo::Node = Psuedo::NodeClass #| Psuedo::NodeStruct
end
