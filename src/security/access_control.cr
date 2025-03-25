enum Magiika::Access
  Public
  Protected
  Private
end

module Magiika::AccessControl
  extend self

  def access_of?(
      evaluating_scope : Scope,
      caller_scope : Scope::Class) : Access
    # try to locate caller scope
    # within evaluating scope by seek
    immediate = true
    access = evaluating_scope.seek { |scope|
      if immediate
        if scope.is_a?(Scope::Class)
          if scope == caller_scope
            # immediate identical match
            next Access::Private
          else
            immediate = false
            next nil
          end
        end
      else
        if scope.is_a?(Scope::Class)
          if scope == caller_scope
            # deep match
            next Access::Protected
          end
        else
          # no elevated permissions
          next Access::Public
        end
      end
    }

    access ? access : Access::Public
  end

  def access_of?(
      evaluating_scope : Scope,
      caller_scope : Scope? = nil) : Access
    if !caller_scope.nil? && !caller_scope.is_a?(Scope::Class)
      # attempt to seek to class scope
      tmp_scope = caller_scope.seek { |scope|
        next scope if scope.is_a?(Scope::Class)
      }
      if tmp_scope.nil?
        return Access::Public
      else
        caller_scope = tmp_scope.as(Scope::Class)
      end
    end

    # look up access
    access_of?(evaluating_scope, caller_scope)
  end

  def access?(have_access : Access, need_access : Access) : ::Bool
    case need_access
    in Access::Public
      true
    in Access::Protected
      have_access != Access::Public
    in Access::Private
      have_access == Access::Private
    end
  end
end
