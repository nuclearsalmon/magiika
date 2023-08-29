module Magiika::Lang::Syntax
  private def register_commons
    group(:nl) do
      rule(:NEWLINE)
      rule(:INLINE_NEWLINE)
    end

    group(:nls) do
      rule(:nl, :nls)
      rule(:nl)
    end

    group(:spc) do
      rule(:TAB)
      rule(:SPACE)
    end

    group(:spcs) do
      rule(:spc, :spcs)
      rule(:spc)
    end
  end
end
