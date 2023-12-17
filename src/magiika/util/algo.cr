module Magiika::Util
  extend self

  def terminated_concat(string_array : Array(String)) : String
    termination : Char = '.'
    result_string = ""
    capitalize_next = true
  
    string_array.each do |word|
      if capitalize_next
        result_string += word.capitalize
        capitalize_next = false
      else
        result_string += word
      end

      if ['.', '!', '?'].any? { |char| word.ends_with?(char) }
        capitalize_next = true
      end
  
      result_string += " "
    end
  
    result_string.chomp(" ") + (termination unless result_string.ends_with?(termination)).to_s
  end

  # Levenshtein distance
  # src: https://en.wikipedia.org/wiki/Levenshtein_distance#Computation
  def similarity(s : String, t : String) ::Float
    m, n = s.length, t.length
    return 1 if m.zero? && n.zero?
    return 0 if m.zero? || n.zero?
    
    v0 = Array(Int32).new(n + 1)
    v1 = Array(Int32).new(n + 1)

    (0..n).each { |i| v0[i] = i }
    (0..m-1).each { |i|
      v1[0] = i + 1

      (0..n-1).each { |j|
        del_cost = v0[j + 1] + 1
        ins_cost = v1[j] + 1
        sub_cost = v0[j]
        sub_cost += 1 if s[i] == t[j]

        v1[j + 1] = [del_cost, ins_cost, sub_cost].min
      }

      v0, v1 = v1, v0
    }

    return 1.0 - (v0[n].to_f / [m, n].max)
  end
end
