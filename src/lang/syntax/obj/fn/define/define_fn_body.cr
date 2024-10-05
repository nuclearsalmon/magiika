module Magiika::Syntax
  define_syntax do
    group :fn_stmt do
      rule :if_else
      rule :assign
      rule :retrieve
      rule :cash_stmt

      rule :cond
    end

    group :fn_stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :fn_stmts, :fn_stmt do |context|
        context.flatten
      end
      rule :fn_stmt
    end

    group :_fn_body_block do
      ignore :NEWLINE

      rule :R_BRC

      rule :fn_stmts, :R_BRC do |context|
        context.become(:fn_stmts)
      end

      rule :fn_stmts do |context|
        position = context.after_last_position
        raise Error::ExpectedCharacter.new("Expected \"}\".", position)
      end
    end

    group :fn_body_block do
      ignore :NEWLINE

      rule :L_BRC, :_fn_body_block do |context|
        context.become(:_fn_body_block)
      end

      # error trap
      rule :L_BRC do |context|
        position = context.after_last_position
        raise Error::ExpectedCharacter.new("Expected \"}\".", position)
      end
    end
  end
end
