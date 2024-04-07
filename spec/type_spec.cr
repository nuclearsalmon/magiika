require "./spec_helper"

describe "Type System" do
  it "correctly identifies node types at runtime" do
    position = Magiika::Lang::Position.new
    bool_node = Magiika::Node::Bool.new(true, position)

    bool_node.node_is_a?(Magiika::Node::Bool).should be_true
    bool_node.node_is_a?(Magiika::Node::Int).should be_false

    pp Magiika::Node::TYPE_IDS
  end
end
