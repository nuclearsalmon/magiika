module Magiika::Lang::Syntax
  private def register_conditions
    group :cond do  # exists for the sake of readability
      rule(:or_cond, :BOR, :and_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:or_cond, :OR, :and_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:and_cond)
    end

    group :and_cond do
      rule(:and_cond, :BAND, :xnor_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:and_cond, :AND, :xnor_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:xnor_cond)
    end
  
    group :xnor_cond do
      rule(:xnor_cond, :BXNOR, :xor_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:xnor_cond, :XNOR, :xor_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:xor_cond)
    end
  
    group :xor_cond do
      rule(:xor_cond, :BXOR, :nor_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:xor_cond, :XOR, :nor_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:nor_cond)
    end
  
    group :nor_cond do
      rule(:BNOR, :nand_cond) do |(op),(l,r)|
        Node::UnaryExpr.new(l.position, op.value, r)
      end
      rule(:nor_cond, :BNOR, :nand_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:nor_cond, :NOR, :nand_cond) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:nand_cond)
    end
  
    group :nand_cond do
      rule(:nand_cond, :BNAND, :expr) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:nand_cond, :NAND, :expr) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      rule(:comp)
    end

    group :comp do
      rule(:expr, :COMP, :expr) do |(op),(l,r)|
        Node::BinaryExpr.new(l.position, l, op.value, r)
      end
      #rule(:NOT, :cond) do |_,(value)|
      #  BooleanInverterNode.new(l.position, value)
      #end
      #rule(:expr)
    end
  end
end
