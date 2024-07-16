module Magiika::Syntax
  protected def register_commons
    group :magic_def do
      rule :NAME
    end

    group :typed_def do
      rule :NAME, :NAME do |context|  # -> :NAME, :_TYPE
        _type = context[:NAME].token(0)
        context.drop(:NAME, 0)
        context.add(:_TYPE, _type)
      end
    end

    group :any_def do
      rule :magic_def do
        name = context.token
        context.drop_tokens
        context.add(:NAME, name)
      end
      rule :typed_def
    end

    group :assignment_op do
      rule :ASSIGN
      rule :ASSIGN_SUB
      rule :ASSIGN_ADD
      rule :ASSIGN_MULT
      rule :ASSIGN_DIV
      rule :ASSIGN_POW
      rule :ASSIGN_PIPE
    end
  end
end
