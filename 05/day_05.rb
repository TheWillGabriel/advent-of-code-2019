def run_intcode(memory)
  intcode = memory.dup
  pointer = 0

  while pointer + 1 < intcode.length && intcode[pointer] != 99
    opcode = intcode[pointer] % 100
    mode1 = intcode[pointer] / 100 % 10
    mode2 = intcode[pointer] / 1000 % 10
    mode3 = intcode[pointer] / 10_000 % 10
    argument1 = intcode[pointer + 1]
    argument2 = intcode[pointer + 2]
    argument3 = intcode[pointer + 3]

    if opcode == 1
      add(intcode: intcode,
          modes: [mode1, mode2],
          arguments: [argument1, argument2, argument3])
      pointer += 4
    elsif opcode == 2
      multiply(intcode: intcode,
               modes: [mode1, mode2],
               arguments: [argument1, argument2, argument3])
      pointer += 4
    elsif opcode == 3
      fetch_input(intcode: intcode,
                  mode: mode1,
                  argument: pointer + 1)
      pointer += 2
    elsif opcode == 4
      send_output(intcode: intcode,
                  mode: mode1,
                  argument: argument1)
      pointer += 2
    elsif opcode == 5
      pointer = jump_if_true(intcode: intcode,
                             pointer: pointer,
                             mode: mode1,
                             arguments: [argument1, argument2])
    elsif opcode == 6
      pointer = jump_if_false(intcode: intcode,
                              pointer: pointer,
                              mode: mode1,
                              arguments: [argument1, argument2])
    elsif opcode == 7
      less_than(intcode: intcode,
                modes: [mode1, mode2, mode3],
                arguments: [argument1, argument2, argument3])
    elsif opcode == 8
      equals(intcode: intcode,
             modes: [mode1, mode2, mode3],
             arguments: [argument1, argument2, argument3])
    end
  end

  intcode
end

# Sum parameter will always be in position mode
def add(intcode:, modes:, arguments:)
  addend1 = modes[0] == 1 ? arguments[0] : intcode[arguments[0]]
  addend2 = modes[1] == 1 ? arguments[1] : intcode[arguments[1]]
  sum_address = arguments[2]

  intcode[sum_address] = addend1 + addend2
end

# Product parameter will always be in position mode
def multiply(intcode:, modes:, arguments:)
  factor1 = modes[0] == 1 ? arguments[0] : intcode[arguments[0]]
  factor2 = modes[1] == 1 ? arguments[1] : intcode[arguments[1]]
  product_address = arguments[2]

  intcode[product_address] = factor1 * factor2
end

def fetch_input
  puts 'Enter the ID of the system to test'
  gets.chomp.to_i
end

def send_output(intcode:, mode:, argument:)
  value = mode == 1 ? argument : intcode[argument]
  puts "Deviance from expected value: #{value}"
end

def jump_if_true(intcode:, pointer:, mode:, arguments:)
  jump = !arguments[0].zero?
  address = mode == 1 ? arguments[1] : intcode[arguments[1]]

  jump ? address : pointer + 3
end

def jump_if_false(intcode:, pointer:, mode:, arguments:)
  jump = arguments[0].zero?
  address = mode == 1 ? arguments[1] : intcode[arguments[1]]

  jump ? address : pointer + 3
end

def less_than(intcode:, modes:, arguments:)
  term1 = modes[0] == 1 ? arguments[0] : intcode[arguments[0]]
  term2 = modes[1] == 1 ? arguments[1] : intcode[arguments[1]]
  result_address = modes[2] == 1 ? arguments[2] : intcode[arguments[2]]

  intcode[result_address] = 1 if term1 < term2
end

def equals(intcode:, modes:, arguments:)
  term1 = modes[0] == 1 ? arguments[0] : intcode[arguments[0]]
  term2 = modes[1] == 1 ? arguments[1] : intcode[arguments[1]]
  result_address = modes[2] == 1 ? arguments[2] : intcode[arguments[2]]

  intcode[result_address] = 1 if term1 == term2
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
