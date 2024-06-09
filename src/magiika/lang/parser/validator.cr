module Magiika::Lang::ParserValidator
  private def validate_group_rules
    valid_group_names = @groups.keys.to_set
    valid_token_names = @tokens.keys.to_set

    @groups.each do |group_name, group|
      group_name_s = group_name.to_s

      unless Util.downcase?(group_name_s)
        raise Error::Internal.new("name must be lowercase")
      end

      validate_rules(group_name, group.rules, valid_group_names, valid_token_names, "rule")
      validate_rules(group_name, group.lr_rules, valid_group_names, valid_token_names, "LR rule")
    end
  end

  private def validate_rules(group_name : Symbol, rules : Array(Rule), valid_group_names : Set(Symbol), valid_token_names : Set(Symbol), rule_type : String)
    rules.each do |rule|
      rule.pattern.each do |symbol|
        sym_s = symbol.to_s
        if Util.upcase?(sym_s)
          unless valid_token_names.includes?(symbol)
            raise "Invalid #{rule_type} in group '#{group_name}': No token found for symbol ':#{symbol}'"
          end
        else
          unless valid_group_names.includes?(symbol)
            raise "Invalid #{rule_type} in group '#{group_name}': No group found for symbol ':#{symbol}'"
          end
        end
      end
    end
  end
end
