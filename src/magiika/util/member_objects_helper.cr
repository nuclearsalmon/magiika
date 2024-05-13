module Magiika
  # add support for members feature in node
  macro def_members_feat
    @@members = Hash(String, Node::Fn).new

    def []?(ident) : NodeObj?
      return @@members[ident]?
    end

    private def self.def_fn(
        name : String,
        body : Proc(Scope::MethodScope, NodeObj),
        params : FnParams? = nil,
        ret_type : NodeType? = nil)
      params = FnParams.new if params.nil?
      params << FnParam.new("self", self)

      fn_ret = ret_type.nil? ? nil : FnRet.new(ret_type)

      @@members[name] = NativeFn.new(name, params, body, fn_ret)
    end
  end

  macro def_fn(name, body_fn, params, ret_type)
    self.def_fn(
      {{ name }},
      ->(scope : Scope::MethodScope){ {{ body_fn }}(scope) },
      {{ params }},
      {{ ret_type }})
  end

  # define variables by pulling from scope
  macro def_scoped_vars(*params)
    {% for param in params %}
      {{ param }}_meta : NodeObj = scope.get({{ param.stringify }})
      {{ param }}_node : NodeObj = {{ param }}_meta.data
    {% end %}
  end
end
