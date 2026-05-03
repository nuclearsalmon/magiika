module Magiika::Syntax
  define_syntax do
    group :while_loop do
      rule :WHILE, :cond, :stmts_block do |context|
        cond = context[:cond].node
        body = Ast::Statements.new(context[:stmts_block].nodes)
        node = Ast::While.new(context[:WHILE].token.position, cond, body)
        context.become(node)
      end
    end

    group :for_loop do
      rule :FOR, :NAME, :IN, :cond, :stmts_block do |context|
        name = context[:NAME].token.value
        iterable = context[:cond].node
        body = Ast::Statements.new(context[:stmts_block].nodes)
        node = Ast::For.new(context[:FOR].token.position, name, iterable, body)
        context.become(node)
      end
    end

    group :break_stmt do
      rule :BREAK, :cond do |context|
        node = Ast::Break.new(context[:BREAK].token.position, context[:cond].node)
        context.become(node)
      end

      rule :BREAK do |context|
        node = Ast::Break.new(context.token.position, nil)
        context.become(node)
      end
    end

    group :next_stmt do
      rule :NEXT do |context|
        node = Ast::Next.new(context.token.position, nil)
        context.become(node)
      end
    end
  end
end
