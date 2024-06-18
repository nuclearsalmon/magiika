module Magiika::Lang
  class Group::Builder
    @name : Symbol
    @rules = Array(Rule).new
    @lr_rules = Array(Rule).new
    @ignores : Array(Symbol)? = nil
    @noignores : Array(Symbol)? = nil
    @trailingignores : Array(Symbol)? = nil

    def self.new(name : Symbol, &)
      with Group.new(name) yield
    end

    def initialize(@name : Symbol)
    end

    def build : Group
      Group.new(
        @name,
        @rules,
        @lr_rules,
        @ignores,
        @noignores,
        @trailing_ignores)
    end

    private def rule(rule : Rule) : Nil
      if rule.pattern[0] == @name
        rule.pattern.shift
        @lr_rules << rule
      else
        @rules << rule
      end
    end

    private def rule(pattern : Symbol) : Nil
      rule(Rule.new([pattern], nil))
    end

    private def rule(*pattern : Symbol) : Nil
      rule(Rule.new(pattern.to_a, nil))
    end

    private def rule(pattern : Symbol, &block : RuleBlock) : Nil
      rule(Rule.new([pattern], block))
    end

    private def rule(*pattern : Symbol, &block : RuleBlock) : Nil
      rule(Rule.new(pattern.to_a, block))
    end

    private def rule(pattern : Array(Symbol)) : Nil
      rule(Rule.new(pattern.to_a, nil))
    end

    private def rule(pattern : Array(Symbol), &block : RuleBlock) : Nil
      rule(Rule.new(pattern.to_a, block))
    end

    private def noignore() : Nil
      noignores = @noignores
      @noignores = Array(Symbol).new if noignores.nil?
    end

    private def noignore(pattern : Symbol) : Nil
      (@noignores ||= Array(Symbol).new) << pattern
    end

    private def ignore(pattern : Symbol) : Nil
      (@ignores ||= Array(Symbol).new) << pattern
    end

    private def ignore_trailing(pattern : Symbol) : Nil
      (@trailing_ignores ||= Array(Symbol).new) << pattern
    end
  end
end
