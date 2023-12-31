module Magiika::Lang::Syntax
  private macro ret(value)
    {% if value.is_a?(Hash) %}
      next {{value}}.as( \
        Hash( \
          Symbol, \
          Array(Magiika::Lang::MatchedToken) \
          | Array(Magiika::Node) \
          | Magiika::Lang::MatchedToken \
          | Magiika::Node))
    {% else %}
      ret = Hash( \
        Symbol, \
        Array(Magiika::Lang::MatchedToken) \
        | Array(Magiika::Node) \
        | Magiika::Lang::MatchedToken \
        | Magiika::Node).new
      ret[:_] = {{value}}
      next ret
    {% end %}
  end

  private macro bin_expr(l, op, r)
    ret( Node::BinaryExpr.new({{l}}.position, {{l}}, {{op}}.value, {{r}}) )
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

      {% if (l2 = "#{l}").upcase == l2 && \
          (r2 = "#{r}").upcase != r2 %}
        # prefix
        ret( Node::UnaryExpr.new(op.pos, op.value, obj, false) )
      {% else %}
        raise Error::Internal.new( \
          "One argument must be referencing a group," + \
          "the other one must be referencing a token.")
      {% end %}
    end
  end
end
