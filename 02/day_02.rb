def run_intcode(memory)
  intcode = memory.dup
  opcode_address = 0

  while opcode_address + 1 < intcode.length && intcode[opcode_address] != 99
    address1 = intcode[opcode_address + 1]
    address2 = intcode[opcode_address + 2]
    result_address = intcode[opcode_address + 3]

    intcode[result_address] = if intcode[opcode_address] == 1
                                intcode[address1] + intcode[address2]
                              elsif intcode[opcode_address] == 2
                                intcode[address1] * intcode[address2]
                              end

    opcode_address += 4
  end

  intcode
end

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

input = find_input(memory, 19_690_720)

puts input
