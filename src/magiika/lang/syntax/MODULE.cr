module Magiika::Lang::Syntax
  private macro bin_expr(l, op, r)
    Node::BinaryExpr.new(
      {{l}}.position,
      {{l}},
      {{op}}.value,
      {{r}})
  end

  private macro bin_expr_rule(l_s, op_s, r_s)
    rule({{l_s}}, {{op_s}}, {{r_s}}) do |(op),(l,r)|
      bin_expr(l, op, r)
    end
  end

  private macro un_expr_rule(l, r)
    rule({{l}}, {{r}}) do |(op),(obj)|
      {% if l.to_s.upcase == l.to_s && r.to_s.upcase != r.to_s %}
        # prefix
        Node::UnaryExpr.new(
          op.position,
          op.value,
          obj,
          false)
      {% elsif l.to_s.upcase != l.to_s && r.to_s.upcase == r.to_s %}
        # postfix
        Node::UnaryExpr.new(
          obj.position,
          op.value,
          obj,
          true)
      {% else %}
        raise Error::Internal.new( \
          "One argument must be referencing a group," + \
          "the other one must be referencing a token.")
      {% end %}
    end
  end
end

