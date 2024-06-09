require "./iface.cr"
require "./psuedo.cr"
require "./defaults"

module Magiika
  abstract class NodeClass < Psuedo::NodeClass
    extend Node::ClassDefaults
    include Node::InstanceDefaults
  end

  abstract struct NodeStruct < Psuedo::NodeStruct
    extend Node::ClassDefaults
    include Node::InstanceDefaults
  end
end
