module Magiika::Lang::Syntax
  private macro bin_expr(l, op, r)
    Node::BinaryExpr.new({{l}}.position, {{l}}, {{op}}.value, {{r}})
  end

  private macro bin_expr_rule(l_s, op_s, r_s)
    rule({{l_s}}, {{op_s}}, {{r_s}}) do |context|
      op = context.token({{op_s}})
      l = context.node({{l_s}})
      r = context.node({{r_s}})

      bin_expr(l, op, r)
    end
  end

  private macro un_expr_rule(l, r)
    rule({{l}}, {{r}}) do |context|
      op = context.token({{l}})
      obj = context.node({{r}})

      {% if ("#{l}".upcase == "#{l}") == ("#{r}".upcase == "#{r}") %}
        {% raise "Compile-time validation of unary expr rule (#{l}, #{r}) failed. " +
        "One argument must be referencing a group, the other one must be referencing a token." %}
      {% else %}
        Node::UnaryExpr.new(op.pos, op.value, obj, false)
      {% end %}
    end
  end
end
