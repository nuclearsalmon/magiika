# **Feature:**
# - Defining member functions/variables
#   within sub-scope(s).
module Magiika::MembersFeat
  macro included
    include SubscopingFeat

    getter scope : Scope::Standalone = \
      Scope::Standalone.new(
        self.type_name,
        position: self.position?)
  end

  macro extended
    extend SubscopingFeat

    class_getter scope : Scope::Standalone = \
      Scope::Standalone.new(self.type_name)

    def scope : Scope::Standalone
      self.class.scope
    end
  end

  def def_fn_proc(
      name : String,
      body : Proc(Scope::Fn, TypeNode),
      params : FnParams? = nil,
      ret_type : EvalType? = nil,
      access : Access = Access::Public)
    params = FnParams.new if params.nil?
    params << Node::FnParam.new("self", self)
    fn_ret = ret_type.nil? ? nil : FnRet.new(ret_type)

    node = Node::NativeFn.new(self.scope, name, params, body, fn_ret)
    meta = Node::Meta.new(node, Node::NativeFn, nil, access)

    scope.define(name, meta)
  end

  macro def_fn(name, body_fn, params, ret_type)
    self.def_fn_proc(
      {{ name }},
      ->(scope : Scope::Fn) { {{ body_fn }}(scope) },
      {{ params }},
      {{ ret_type }})
  end

  macro def_fn(name, body_fn, params, ret_type, access)
    self.def_fn_proc(
      {{ name }},
      ->(scope : Scope::Fn) { {{ body_fn }}(scope) },
      {{ params }},
      {{ ret_type }},
      {{ access }})
  end

  # define variables by pulling from scope
  macro get_scoped_vars(*params)
    {% for param in params %}
      {{ param }}_meta : TypeNode = scope.retrieve({{ param.stringify }})
      {{ param }}_node : TypeNode = {{ param }}_meta.value
    {% end %}
  end
end
