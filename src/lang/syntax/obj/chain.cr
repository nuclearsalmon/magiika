module Magiika::Syntax
  define_syntax do
    group :chain_stmt do
      rule :fn_call
      rule :retrieve
    end

    group :chain_stmts do
      rule :chain_stmts, :DOT, :chain_stmt do |context|
        context.flatten
      end

      rule :chain_stmt
    end

    group :chain do
      rule :chain_stmts do |context|
        stmts = context.nodes
        position = context.first_position

        if stmts.size == 1
          context.become(stmts[0])
        else
          chain = Node::Chain.new(stmts, position)
          context.become(chain)
        end
      end
    end
  end
end
