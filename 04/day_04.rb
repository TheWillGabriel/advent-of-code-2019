require 'benchmark'

min_max = File.read('input.txt').split('-')
range = (min_max[0].to_i)..(min_max[1].to_i)

def find_passwords(range)
  passwords = []

  range.each do |number|
    next unless increase_only?(number)
    next unless adjacent_match?(number)

    passwords << number
  end
  passwords
end

def adjacent_match?(number)
  groups = number.to_s.scan(/((\d)\2*)/).map(&:first)
  groups.each do |group|
    return true if group.length == 2
  end
  false
end

def increase_only?(number)
  digits = number.digits.reverse
  digits.each_index do |index|
    break if index == digits.size - 1
    return false if digits[index] > digits[index + 1]
  end
  true
end

puts find_passwords(range).size
