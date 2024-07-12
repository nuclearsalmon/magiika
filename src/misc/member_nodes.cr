module Magiika::Members
  macro inherited
    getter scope : Scope::Standalone = \
      Scope::Standalone.new(self.type_name, self.position?)
  end

  macro extended
    class_getter scope : Scope::Standalone = \
      Scope::Standalone.new(self.type_name, nil)

    def scope : Scope::Standalone
      self.class.scope
    end
  end

  def def_fn(
      name : String,
      body : Proc(Scope::Fn, TypeNode),
      params : FnParams? = nil,
      ret_type : TypeNodeIdent? = nil,
      visibility : Visibility = Visibility::Public)
    params = FnParams.new if params.nil?
    params << Node::FnParam.new("self", self)
    fn_ret = ret_type.nil? ? nil : FnRet.new(ret_type)

    node = Node::NativeFn.new(self.scope, name, params, body, fn_ret)
    meta = Node::Meta.new(node, Node::NativeFn, nil, visibility)

    scope.set(name, meta)
  end

  macro def_fn(name, body_fn, params, ret_type)
    self.def_fn(
      {{ name }},
      ->(scope : Scope::Fn){ {{ body_fn }}(scope) },
      {{ params }},
      {{ ret_type }})
  end

  macro def_fn(name, body_fn, params, ret_type, visibility)
    self.def_fn(
      {{ name }},
      ->(scope : Scope::Fn){ {{ body_fn }}(scope) },
      {{ params }},
      {{ ret_type }},
      {{ visibility }})
  end

  # define variables by pulling from scope
  macro get_scoped_vars(*params)
    {% for param in params %}
      {{ param }}_meta : TypeNode = scope.get({{ param.stringify }})
      {{ param }}_node : TypeNode = {{ param }}_meta.value
    {% end %}
  end
end
