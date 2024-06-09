module Magiika::Members
  # add support for members feature in node
  macro def_members_feat
    @@members = Hash(String, Node::Fn).new

    def []?(ident) : Psuedo::TypeNode?
      @@members[ident]?
    end

    private def self.def_fn(
        name : String,
        body : Proc(Scope::Fn, Psuedo::TypeNode),
        params : FnParams? = nil,
        ret_type : Psuedo::TypeNodeIdent? = nil)
      params = FnParams.new if params.nil?
      params << FnParam.new("self", self)

      fn_ret = ret_type.nil? ? nil : FnRet.new(ret_type)

      @@members[name] = NativeFn.new(name, params, body, fn_ret)
    end
  end

  macro def_fn(name, body_fn, params, ret_type)
    self.def_fn(
      {{ name }},
      ->(scope : Scope::Fn){ {{ body_fn }}(scope) },
      {{ params }},
      {{ ret_type }})
  end

  # define variables by pulling from scope
  macro def_scoped_vars(*params)
    {% for param in params %}
      {{ param }}_meta : Psuedo::TypeNode = scope.get({{ param.stringify }})
      {{ param }}_node : Psuedo::TypeNode = {{ param }}_meta.value
    {% end %}
  end
end
