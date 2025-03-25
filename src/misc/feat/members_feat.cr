# **Feature:**
# - Defining member functions/variables
#   within sub-scope(s).
module Magiika::MembersFeat
  macro included
    include SubScopingFeat

    getter scope : Scope = \
      Scope.new(
        self.type_name,
        position: self.position?)
  end

  macro extended
    extend SubScopingFeat

    class_getter scope : Scope = \
      Scope.new(self.type_name)

    def scope : Scope
      self.class.scope
    end
  end

  def def_fn_proc(
    name : ::String,
    body : Proc(Scope, AnyObject),
    parameters : Array(Object::Parameter)? = Array(Object::Parameter).new,
    returns : AnyObject? = nil,
    access : Access = Access::Public
  )
    parameters = Array(Object::Parameter).new if parameters.nil?
    parameters << Object::Parameter.new(SELF_NAME, self)

    obj = Object::NativeFunction.new(
      proc: body, 
      defining_scope: self.scope, 
      static: false, 
      name: name, 
      parameters: parameters, 
      returns: returns)

    info = Object::Slot.new(
      value: obj, 
      final: true, 
      type: Object::NativeFunction, 
      access: access)

    scope.define(name, info)
  end

  macro def_fn(name, body_fn, params, ret_type)
    self.def_fn_proc(
      {{ name }},
      ->(scope : Scope) { {{ body_fn }}(scope) },
      {{ params }},
      {{ ret_type }})
  end

  macro def_fn(name, body_fn, params, ret_type, access)
    self.def_fn_proc(
      {{ name }},
      ->(scope : Scope) { {{ body_fn }}(scope) },
      {{ params }},
      {{ ret_type }},
      {{ access }})
  end

  # define variables by pulling from scope
  macro get_scoped_vars(*params)
    {% for param in params %}
      {{ param }}_info : Slot = scope.retrieve({{ param.stringify }})
      {{ param }}_obj : AnyObject = {{ param }}_info.value
    {% end %}
  end
end
