module Magiika::Syntax
  define_syntax do
    group :expr do
      bin_expr_rule :expr, :ADD, :term
      bin_expr_rule :expr, :SUB, :term

      rule :term
    end

    group :term do
      bin_expr_rule :term, :MULT, :un_prfx_op
      bin_expr_rule :term, :DIV, :un_prfx_op
      bin_expr_rule :term, :IDIV, :un_prfx_op
      bin_expr_rule :term, :MOD, :un_prfx_op

      rule :un_prfx_op
    end

    group :un_prfx_op do
      un_expr_rule :INC, :un_pofx_op
      un_expr_rule :DEC, :un_pofx_op
      un_expr_rule :ADD, :un_pofx_op
      un_expr_rule :SUB, :un_pofx_op

      rule :un_pofx_op
    end

    group :un_pofx_op do
      un_expr_rule :value, :INC
      un_expr_rule :value, :DEC

      rule :value
    end
  end
end
