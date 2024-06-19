module Magiika::Lang::ParserValidator
  private def validate_references_existance : Nil
    group_symbols = @groups.keys.to_set
    token_symbols = @tokens.keys.to_set

    @groups.each { |group_name, group|
      unless Util.downcase?(group_name.to_s)
        raise Error::Internal.new("name must be lowercase")
      end

      [*group.rules, *group.lr_rules].each { |rule|
        rule.pattern.each { |symbol|
          if Util.upcase?(symbol.to_s)
            unless token_symbols.includes?(symbol)
              raise Error::Internal.new(
                "Invalid rule in group ':#{group_name}' - " +
                "Unknown token ':#{symbol}'")
            end
          else
            unless group_symbols.includes?(symbol)
              raise Error::Internal.new(
                "Invalid rule in group ':#{group_name}' - " +
                "Unknown group ':#{symbol}'")
            end
          end
        }
      }
    }
  end

  private def inexplicit_recursive_reference?(
      to_group : Symbol,
      from_group : Symbol) : Bool
    pending_detection = Array(Symbol).new
    pending_detection << to_group

    iterations = 0
    loop do
      group_sym = pending_detection.shift?
      return false if group_sym.nil?

      @groups[group_sym].rules.each { |rule|
        if rule.pattern[0] == from_group
          return true
        else
          new_to_group = rule.pattern[0]
          unless Util.upcase?(new_to_group.to_s)
            pending_detection << new_to_group
          end
        end
      }

      iterations += 1
      if iterations >= PARSER_REFERENCE_RECURSION_LIMIT
        raise Error::Internal.new(
          "Potentially infinite recursion detected" +
          "from group ':#{from_group}'.")
      end
    end
    return false
  end

  private def detect_and_fix_left_recursive_rules : Nil
    @groups.each { |group_name, group|
      group.rules.each { |rule|
        to_group = rule.pattern[0]

        # skip tokens
        next if Util.upcase?(to_group.to_s)

        # fix it if it's an inexplicit recursive reference
        if inexplicit_recursive_reference?(
            to_group, group_name)
          group.rules.delete(rule)
          rule.pattern.shift if rule.pattern.size > 1
          group.lr_rules << rule
        end
      }
    }
  end

  private def detect_unused_tokens : Nil
    unused : Array(Symbol) = @tokens.map { |sym, _| sym }

    groups : Array(Group) = \
      @groups.map { |_, group| group }.tap(&.<< @root)

    groups.each { |group|
      syms = Array(Symbol).new

      rules = group.rules.dup.tap(&.concat(group.lr_rules))
      rules.each { |rule|
        rule.pattern.each { |sym|
          syms << sym if Util.upcase?(sym.to_s)
        }
      }

      ignores = group.ignores
      syms.concat(ignores) unless ignores.nil?

      noignores = group.noignores
      syms.concat(noignores) unless noignores.nil?

      trailing_ignores = group.trailing_ignores
      syms.concat(trailing_ignores) unless trailing_ignores.nil?

      syms.each { |sym| unused.delete(sym) }
    }

    return if unused.empty?
    raise Error::Internal.new("Unused tokens: #{unused}")
  end

  private def detect_unused_groups : Nil
    unused : Array(Symbol) = @groups.map { |sym, _| sym }
    @groups.each { |_, group|
      rules = group.rules.tap(&.dup).tap(&.concat(group.lr_rules))
      rules.each { |rule|
        rule.pattern.each { |sym|
          unused.delete(sym) if Util.downcase?(sym.to_s)
        }
      }
    }

    return if unused.empty?
    raise Error::Internal.new("Unused groups: #{unused}")
  end
end