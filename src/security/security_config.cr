module Magiika
  class SecurityConfig
    property resource_limits : ResourceLimits = ResourceLimits.new
    property visibility : SecurityVisibility = SecurityVisibility.new
    property module_access : SecurityVisibility = SecurityVisibility.new

    VALID_VISIBILITY_FLAGS = Set{
      "max_time", "max_memory",
      "time_elapsed", "time_remaining",
      "memory_used",
    }

    # Parse a key=value config file.
    #
    # Supported keys:
    #   max_time          - max execution seconds (float, 0=unlimited)
    #   max_memory        - max heap bytes (int, 0=unlimited)
    #   visibility_mode   - allow_all | deny_all
    #   visibility.<flag> - true | false (per-flag override)
    #   module_mode       - allow_all | deny_all
    #   module.<name>     - true | false (per-module override)
    def self.from_file(path : ::String) : SecurityConfig
      config = SecurityConfig.new

      File.each_line(path) do |raw_line|
        line = raw_line.strip
        next if line.empty? || line.starts_with?('#')

        key, _, value = line.partition('=')
        key = key.strip
        value = value.strip

        case key
        when "max_time"
          config.resource_limits.max_time_seconds = value.to_f64
        when "max_memory"
          config.resource_limits.max_memory_bytes = value.to_u64
        when "visibility_mode"
          case value.downcase
          when "allow_all"
            config.visibility.mode = SecurityVisibilityMode::AllowAll
          when "deny_all"
            config.visibility.mode = SecurityVisibilityMode::DenyAll
          else
            raise Error::Internal.new(
              "Unknown visibility mode in security config: '#{value}'")
          end
        when "module_mode"
          case value.downcase
          when "allow_all"
            config.module_access.mode = SecurityVisibilityMode::AllowAll
          when "deny_all"
            config.module_access.mode = SecurityVisibilityMode::DenyAll
          else
            raise Error::Internal.new(
              "Unknown module mode in security config: '#{value}'")
          end
        else
          if key.starts_with?("visibility.")
            flag = key[("visibility.".size)..]
            unless VALID_VISIBILITY_FLAGS.includes?(flag)
              raise Error::Internal.new(
                "Unknown visibility flag in security config: '#{flag}'")
            end
            config.visibility.overrides[flag] =
              CrystalUtils.s_to_bool(value, case_sensitive: false)
          elsif key.starts_with?("module.")
            mod_name = key[("module.".size)..]
            config.module_access.overrides[mod_name] =
              CrystalUtils.s_to_bool(value, case_sensitive: false)
          end
        end
      end

      config
    end
  end
end
