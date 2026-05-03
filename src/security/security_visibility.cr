module Magiika
  enum SecurityVisibilityMode
    AllowAll
    DenyAll
  end

  class SecurityVisibility
    property mode : SecurityVisibilityMode = SecurityVisibilityMode::AllowAll
    property overrides : Hash(::String, ::Bool) = {} of ::String => ::Bool

    # In AllowAll mode: everything visible unless overridden to false (blacklist)
    # In DenyAll mode: nothing visible unless overridden to true (whitelist)
    def visible?(flag : ::String) : ::Bool
      if (override = @overrides[flag]?)
        return override
      end
      @mode.allow_all?
    end
  end
end
