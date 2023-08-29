module Magiika::Lang::Syntax
  private def register_base
    root do
      ignore(:LINE_SEGMENT)
      ignore(:SPACE)

      rule(:stmts)
    end

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

    group(:stmts) do
      ignore(:NEWLINE)
      
      rule(:stmt, :stmts) do |_,(stmt,stmts)|
        type(stmts, Array)
        type(stmt, Node::Node)
        
        [stmt, *stmts]
      end
      rule(:stmt)
    end

    group(:stmt) do
      rule(:setvar)
      rule(:getvar)
    end
    
    group(:value) do
      rule(:BOOL) do |(value),_|
        Magiika::Node::Bool.new(value.value == "true", value.pos)
      end

      rule(:INT) do |(value),_|
        Magiika::Node::Int.new(value.value.to_i32, value.pos)
      end

      rule(:FLT) do |(value),_|
        Magiika::Node::Flt.new(value.value.to_f32, value.pos)
      end
    end
  end
end
