module Magiika::Util
  # Works like forward_missing_to, but for iteratives.
  # Returns the first positive result (anything that
  # would succeed an `if result` check).
  #
  # This is a very very stupid, but potentially convenient...
  macro iterative_forward_missing_to(delegate)
    macro method_missing(call)
      {{delegate}}.each { |delegate_element|
        if delegate_element.responds_to?(:\{{call.name.id}})
          result = delegate_element.\{{call}}
          return result if result
        end
      }
    end
  end

  macro def_iface_is_a(ident, instance_iface, class_iface)
    def is_a_{{ident}}?({{ident}}) : Bool
      if {{ident}}.is_a?({{class_iface}})
    #    if ({{ident}}.responds_to?(:new) &&
    #        {{ident}}.new.is_a?({{instance_iface}}))
        if {{ident}}.new.is_a?({{instance_iface}})
          return true
        end
      elsif {{ident}}.is_a?({{instance_iface}})
    #    if ({{ident}}.responds_to?(:class) &&
    #        {{ident}}.class.is_a?({{class_iface}}))
        if {{ident}}.class.is_a?({{class_iface}})
          return true
        end
      end
      return false
    end
  end
end