module Magiika::Lang::Syntax
  private macro bin_expr(l, op, r)
    context.clear
    context.add(Node::BinaryExpr.new({{l}}.position, {{l}}, {{op}}.value, {{r}}))
  end

  private macro bin_expr_rule(l_s, op_s, r_s)
    rule({{l_s}}, {{op_s}}, {{r_s}}) do |context|
      l = context[{{l_s}}].node
      op = context[{{op_s}}].token
      r = context[{{r_s}}].node

      bin_expr(l, op, r)
    end
  end

  private macro un_expr_rule(l, r)
    rule({{l}}, {{r}}) do |context|
      op = context[{{l}}].token
      obj = context[{{r}}].node

      {% if ("#{l}".upcase == "#{l}") == ("#{r}".upcase == "#{r}") %}
        {% raise "Compile-time validation of unary expr rule (#{l}, #{r}) failed. " +
        "One argument must be referencing a group, the other one must be referencing a token." %}
      {% end %}

      context.clear
      context.add(Node::UnaryExpr.new(op.pos, op.value, obj, false))
    end
  end
end
