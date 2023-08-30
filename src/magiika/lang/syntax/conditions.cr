module Magiika::Lang::Syntax
  private def register_conditions
    group :cond do  # exists for the sake of readability
      bin_expr_rule(:or_cond, :BOR, :and_cond)
      bin_expr_rule(:or_cond, :OR, :and_cond)
      rule(:and_cond)
    end

    group :and_cond do
      bin_expr_rule(:and_cond, :BAND, :xnor_cond)
      bin_expr_rule(:and_cond, :AND, :xnor_cond)
      rule(:xnor_cond)
    end

    group :xnor_cond do
      bin_expr_rule(:xnor_cond, :BXNOR, :xor_cond)
      bin_expr_rule(:xnor_cond, :XNOR, :xor_cond)
      rule(:xor_cond)
    end

    group :xor_cond do
      bin_expr_rule(:xor_cond, :BXOR, :nor_cond)
      bin_expr_rule(:xor_cond, :XOR, :nor_cond)
      rule(:nor_cond)
    end

    group :nor_cond do
      rule(:BNOR, :nand_cond) do |(op),(l,r)|
        Node::UnaryExpr.new(l.position, op.value, r)
      end
      bin_expr_rule(:nor_cond, :BNOR, :nand_cond)
      bin_expr_rule(:nor_cond, :NOR, :nand_cond)
      rule(:nand_cond)
    end

    group :nand_cond do
      bin_expr_rule(:nand_cond, :BNAND, :expr)
      bin_expr_rule(:nand_cond, :NAND, :expr)
      rule(:comp)
    end

    group :comp do
      bin_expr_rule(:expr, :COMP, :expr)
      #rule(:NOT, :cond) do |_,(value)|
      #  BooleanInverterNode.new(l.position, value)
      #end
      #rule(:expr)
    end
  end
end
