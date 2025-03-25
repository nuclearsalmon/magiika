module Magiika::Syntax
  define_syntax do
    group :retrieve do
      rule :NAME do |context|
        name_t = context.token
        name = name_t.value

        position = name_t.position

        node = Ast::Retrieve.new(name, position)
        context.become(node)
      end
    end

    group :assign do
      rule :NAME, :assignment_op, :cond do |context|
        name_t = context[:NAME].token
        name = name_t.value
        op = context[:assignment_op].token.value
        value = context[:cond].node

        position = name_t.position

        node = Ast::Assign.new(
          position,
          name,
          value,
          op)
        context.become(node)
      end
    end
  end
end
