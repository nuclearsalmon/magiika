module Magiika::Syntax
  protected def register_define_cls
    group :any_cls_def do
      rule :NAME
      rule :CLS_T, :NAME do |context|
        context.become(:NAME)
      end
    end

    group :_cls_body_block do
      ignore(:NEWLINE)

      rule :R_BRC

      rule :stmts, :R_BRC  do |context|
        context.become(:stmts)
      end

      # error trap
      rule :stmts do |context|
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

      rule :any_cls_def, :_define_cls do |context|
        name_t = context[:any_cls_def].token
        name = name_t.value
        pos = name_t.position

        cls_def_ctx = context[:_define_cls]

      end
    end

    group :global_define_cls do
      rule :S_QUOT, :define_cls do |context|
        context.become(:define_cls)
      end
    end

    group :instance_define_cls do
      rule :DOT, :define_cls do |context|
        context.become(:define_cls)
      end
    end

    group :static_define_cls do
      rule :COLON, :define_cls do |context|
        context.become(:define_cls)
      end
    end
  end
end