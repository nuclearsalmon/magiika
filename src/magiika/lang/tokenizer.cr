module Magiika::Lang::Tokenizer
  def tokenize(str : String, filename : String) : Array(MatchedToken)
    tokens_found = Array(MatchedToken).new
    row, col = 1, 1

    while !(str.empty?)
      @tokens.values.each { | token |
        match = token.pattern.match(str)
        next if match.nil?

        content = ""
        match.to_a.each { | group | content += group unless group.nil? }

        next if content.empty?

        position = Lang::Position.new(filename, row, col)
        token = Lang::MatchedToken.new(token.name, content, position)
        tokens_found << token

        str = str[content.size..-1]
        content.each_char { | char |
          if char == '\n'
            row += 1
            col = 1
          else
            col += 1
          end
        }

        break
      }

      if tokens_found.empty?
        raise Error::UnexpectedCharacter.new(str[0], Position.new(filename, row, col))
      end
    end

    return tokens_found
  end
end
