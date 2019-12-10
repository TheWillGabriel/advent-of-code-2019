require 'benchmark'

min_max = File.read('input.txt').split('-')
range = min_max[0].to_i..min_max[1].to_i

def find_passwords(range)
  passwords = []

  range.each do |number|
    digits = number.digits.reverse
    next unless adjacent_match?(digits)
    next unless increase_only?(digits)

    passwords << number
  end
  passwords
end

def adjacent_match?(digits)
  digits.each_index do |index|
    break if index == digits.size - 1
    return true if digits[index] == digits[index + 1]
  end
  false
end

def increase_only?(digits)
  digits.each_index do |index|
    break if index == digits.size - 1
    return false if digits[index] > digits[index + 1]
  end
  true
end

puts find_passwords(range).size
