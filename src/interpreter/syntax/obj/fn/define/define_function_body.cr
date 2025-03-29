module Magiika::Syntax
  define_syntax do
    group :function_stmt do
      rule :if_else
      rule :assign
      rule :retrieve
      rule :cash_stmt

      rule :cond
    end

    group :function_stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :function_stmts, :function_stmt do |context|
        context.absorb(:function_stmts)
        context.absorb(:function_stmt)
      end
      rule :function_stmt
    end

    group :function_body do
      ignore :NEWLINE

      rule :L_BRC, :R_BRC
      
      rule :L_BRC, :function_stmts, :R_BRC do |context|
        context.become(:function_stmts)
      end

      rule :L_BRC, :function_stmts do |context|
        position = context.after_last_position
        raise Error::ExpectedCharacter.new("Expected \"}\".", position)
      end
      
      rule :L_BRC do |context|
        position = context.after_last_position
        raise Error::ExpectedCharacter.new("Expected \"}\".", position)
      end
    end
  end
end
