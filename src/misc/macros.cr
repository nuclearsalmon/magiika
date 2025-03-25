module Magiika::Util
  macro def_iface_is_a(ident, instance_iface, class_iface)
    def is_a_{{ident}}?({{ident}}) : ::Bool
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

  macro pvar(stmt)
    puts "{{ stmt }}:\n  #{ {{ stmt }}.pretty_inspect }"
  end
end