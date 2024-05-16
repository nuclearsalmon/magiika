module Magiika::Lang::Syntax
  private def register_commons
    group :def do
      rule :DEFINE, :NAME do |context|
        context.become(:NAME)
      end
    end
  end
end
