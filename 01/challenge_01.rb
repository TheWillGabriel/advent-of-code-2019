masses = File.read('input.txt').split
fuel = masses.reduce(0) do |sum, mass|
  sum + ((mass.to_i / 3) - 2)
end

puts fuel
