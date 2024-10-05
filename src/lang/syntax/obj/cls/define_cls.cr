module Magiika::Syntax
  define_syntax do
    group :cls_stmt do
      rule :if_else

      rule :instance_define_fn
      rule :static_define_fn

      rule :define_cls

      rule :instance_define_var
      rule :static_define_var

      rule :assign
      rule :cash_stmt

      rule :cond
    end

    group :cls_stmts do
      ignore :NEWLINE
      ignore :INLINE_NEWLINE

      rule :cls_stmts, :cls_stmt do |context|
        context.absorb(:cls_stmts)
        context.absorb(:cls_stmt)
      end
      rule :cls_stmt
    end

    group :any_cls_def do
      rule :NAME
      rule :CLS_T, :NAME do |context|
        context.become(:NAME)
      end
    end

    group :_cls_body_block do
      ignore(:NEWLINE)

      rule :R_BRC

      rule :cls_stmts, :R_BRC  do |context|
        context.become(:cls_stmts)
      end

      # error trap
      rule :cls_stmts do |context|
        position = context.after_last_position
        raise Error::ExpectedCharacter.new("Expected \"}\".", position)
      end
    end

    group :cls_body_block do
      ignore :NEWLINE

      rule :L_BRC, :_cls_body_block do |context|
        context.become(:_cls_body_block)
      end

      # error trap
      rule :L_BRC do |context|
        position = context.after_last_position
        raise Error::ExpectedCharacter.new("Expected \"}\".", position)
      end
    end

    group :define_cls do
      ignore :NEWLINE

      rule :COLON, :any_cls_def, :cls_body_block do |context|
        name_t = context[:any_cls_def].token
        name = name_t.value
        pos = name_t.position

        body = context[:cls_body_block].nodes

        cls = Node::DefCls.new(name, false, body, pos)

        context.become(cls)
      end
    end
  end
end