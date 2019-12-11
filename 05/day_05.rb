def run_intcode(memory)
  intcode = memory.dup
  opcode_address = 0

  while opcode_address + 1 < intcode.length && intcode[opcode_address] != 99
    opcode = intcode[opcode_address] % 100
    mode1 = intcode[opcode_address] / 100 % 10
    mode2 = intcode[opcode_address] / 1000 % 10
    mode3 = intcode[opcode_address] / 10_000 % 10
    argument1 = intcode[opcode_address + 1]
    argument2 = intcode[opcode_address + 2]
    argument3 = intcode[opcode_address + 3]

    if opcode == 1
      add(intcode: intcode,
          modes: [mode1, mode2],
          arguments: [argument1, argument2, argument3])
      opcode_address += 4
    elsif opcode == 2
      multiply(intcode: intcode,
               modes: [mode1, mode2],
               arguments: [argument1, argument2, argument3])
      opcode_address += 4
    elsif opcode == 3
      intcode[argument1] = fetch_input
      opcode_address += 2
    elsif opcode == 4
      send_output(intcode: intcode,
                  mode: mode1,
                  argument: argument1)
      opcode_address += 2
    end
  end

  intcode
end

# Sum parameter will always be in position mode
def add(intcode:, modes:, arguments:)
  addend1 = modes[0] == 1 ? arguments[0] : intcode[arguments[0]]
  addend2 = modes[1] == 1 ? arguments[1] : intcode[arguments[1]]
  sum_index = arguments[2]
  intcode[sum_index] = addend1 + addend2
end

# Product parameter will always be in position mode
def multiply(intcode:, modes:, arguments:)
  addend1 = modes[0] == 1 ? arguments[0] : intcode[arguments[0]]
  addend2 = modes[1] == 1 ? arguments[1] : intcode[arguments[1]]
  product_index = arguments[2]
  intcode[product_index] = addend1 * addend2
end

def fetch_input
  puts 'Enter the ID of the system to test'
  gets.chomp.to_i
end

def send_output(intcode:, mode:, argument:)
  value = mode == 1 ? argument : intcode[argument]
  puts "Deviance from expected value: #{value}"
end

# Finds which noun and verb will produce given output with given memory state
def find_input(memory, output)
  success = false
  new_memory = []

  100.times do |noun|
    100.times do |verb|
      new_memory = memory.dup
      new_memory[1] = noun
      new_memory[2] = verb

      success = true if run_intcode(new_memory)[0] == output
      break if success
    end
    break if success
  end

  100 * new_memory[1] + new_memory[2]
end

memory = File.read('input.txt').split(',').map(&:to_i)

run_intcode(memory)
