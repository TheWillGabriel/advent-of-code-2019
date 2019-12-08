module_masses = File.read('input.txt').split

def combined_fuel(masses)
  module_fuels(masses).reduce(:+)
end

def module_fuels(masses)
  masses.map do |mass|
    mass_fuel(mass.to_i)
  end
end

def mass_fuel(mass)
  fuel = (mass / 3) - 2
  return 0 if fuel <= 0

  fuel + mass_fuel(fuel)
end

puts combined_fuel(module_masses)
