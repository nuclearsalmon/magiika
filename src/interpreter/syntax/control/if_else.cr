module Magiika::Syntax
  define_syntax do
    group :stmts_block do
      ignore(:NEWLINE)

      rule :L_BRC, :R_BRC
      rule :L_BRC, :stmts, :R_BRC  do |context|
        context.become(:stmts)
        root_node = Ast::Statements.new(context.nodes)
        context.become(root_node)
      end
    end

    group :else do
      rule :ELSIF, :cond, :stmts_block, :else do |context|
        cond = context[:cond].node
        stmt_on_true = Ast::Statements.new(context[:stmts_block].nodes)
        stmt_on_false = context[:else].node

        node = Ast::IfElse.new(
          nil,
          cond,
          stmt_on_true,
          stmt_on_false)
        context.become(node)
      end

      rule :ELSIF, :cond, :stmts_block do |context|
        cond = context[:cond].node
        stmt = Ast::Statements.new(context[:stmts_block].nodes)

        node = Ast::IfElse.new(
          nil,
          cond,
          stmt)
        context.become(node)
      end

      rule :ELSE, :stmts_block do |context|
        stmt = Ast::Statements.new(context[:stmts_block].nodes)
        context.become(stmt)
      end
    end

    group :if do
      rule :IF, :cond, :stmts_block do |context|
        context.drop(:IF)
      end
    end

    group :if_else do
      rule :if, :else do |context|
        cond = context[:if][:cond].node
        stmts_on_true = Ast::Statements.new(context[:if][:stmts_block].nodes)
        stmts_on_false = context[:else].node

        node = Ast::IfElse.new(
          nil,
          cond,
          stmts_on_true,
          stmts_on_false)
        context.become(node)
      end

      rule :if do |context|
        cond = context[:if][:cond].node
        stmts = Ast::Statements.new(context[:if][:stmts_block].nodes)

        node = Ast::IfElse.new(
          nil,
          cond,
          stmts)
        context.become(node)
      end
    end
  end
end
