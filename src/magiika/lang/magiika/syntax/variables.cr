module Magiika::Lang::Syntax
  protected def register_variables
    group :get_value do
      rule :NAME do |context|
        name_t = context.token
        name = name_t.value
        position = name_t.position

        node = Node::RetrieveVar.new(name, position)
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

        node = Node::AssignVar.new(
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

        node = Node::AssignVar.new(
          pos,
          name,
          value,
          AssignMode::Replace)
        context.become(node)
      end
    end

    group :get_member_value do
      noignore :SPACE

      rule :get_value, :MEMBER, :get_member_value do |context|
        source = context[:get_value].node
        action = context[:members].node
        position = source.position

        node = Node::RetrieveMember.new(source, action, position)
        context.become(node)
      end
    end

    group :set_member_value do
      noignore :SPACE

      rule :get_member_value, :MEMBER, :set_value do |context|
        target = context[:get_member_value].node
        action = context[:set_value].node
        position = target.position

        #node = Node::ScopedExpr.new(position, target, action)
        #context.become(node)
      end
    end
  end
end
