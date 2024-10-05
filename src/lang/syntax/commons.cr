module Magiika::Syntax
  define_syntax do
    group :typed_def do
      ignore :SPACE

      rule :NAME, :NAME do |context|  # -> :_TYPE, :NAME
        type_t = context[:NAME].token(0)
        context.drop(:NAME, 0)
        context.add(:_TYPE, type_t)
      end
    end

    group :any_def do
      rule :typed_def
      rule :NAME do |context|  # -> :NAME
        context.to_subcontext(:NAME)
      end
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
