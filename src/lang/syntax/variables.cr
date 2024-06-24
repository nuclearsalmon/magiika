module Magiika::Syntax
  protected def register_variables
    group :get_value do
      rule :NAME do |context|
        name_t = context.token
        name = name_t.value
        position = name_t.position

        node = Node::Retrieve.new(name, position)
        context.become(node)
      end
    end

    group :def_value do
      rule :def, :ASSIGN, :cond do |context|
        name_t = context[:def].token
        name = name_t.value
        #op = context[:ASSIGN].token.value
        value = context[:cond].node
        pos = name_t.position

        node = Node::Assign.new(
          pos,
          name,
          value,
          AssignMode::Declare)
        context.become(node)
      end
    end

    group :set_value do
      rule :NAME, :ASSIGN, :cond do |context|
        name_t = context[:NAME].token
        name = name_t.value
        #op = context[:ASSIGN].token.value
        value = context[:cond].node
        pos = name_t.position

        node = Node::Assign.new(
          pos,
          name,
          value,
          AssignMode::Replace)
        context.become(node)
      end
    end
  end
end
