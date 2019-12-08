module_masses = File.read('input.txt').split

def combined_fuel(fuels)
  fuels.reduce(:+)
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

fuels = module_fuels(module_masses)
puts fuels

total = combined_fuel(fuels)
puts total
