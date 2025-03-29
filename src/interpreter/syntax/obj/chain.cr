module Magiika::Syntax
  define_syntax do
    group :chain_stmt do
      rule :fn_call
      rule :retrieve
    end

    group :chain_stmts do
      noignore :INLINE_NEWLINE

      rule :chain_stmts, :DOT, :chain_stmt do |context|
        context.drop(:DOT)
        context.absorb(:chain_stmts)
        context.absorb(:chain_stmt)
      end

      rule :chain_stmt, :DOT, :chain_stmt do |context|
        context.drop(:DOT)
        context.absorb(:chain_stmt)
      end
    end

    group :chain do
      rule :chain_stmts do |context|
        context.flatten
        stmts = context.nodes
        position = context.first_position

        chain = Ast::Chain.new(stmts, position)
        context.become(chain)
      end
    end
  end
end
