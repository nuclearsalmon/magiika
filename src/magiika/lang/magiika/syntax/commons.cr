module Magiika::Lang::Syntax
  private def register_commons
    #group :nls do
    #  noignore :NEWLINE
    #  noignore :INLINE_NEWLINE
    #
    #  rule :NEWLINE
    #  rule :INLINE_NEWLINE
    #end

    group :def do
      rule :DEFINE, :NAME do |context|
        context.become(:NAME)
      end
    end

    group :t_def do
      rule :NAME, :DEFINE, :NAME do |context|
        context.drop(:DEFINE)

        _type = context[:NAME].token(0)
        context.drop(:NAME, 0)
        context.add(:TYPE, _type)
      end
      rule :DEFINE, :NAME do |context|
        context.drop(:DEFINE)
      end
    end
  end
end
