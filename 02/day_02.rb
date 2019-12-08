def run_intcode(memory)
  intcode = memory.dup
  p intcode
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

  p intcode
  intcode
end

memory = File.read('input.txt').split(',').map(&:to_i)
memory[1] = 12
memory[2] = 2
memory = run_intcode(memory)

puts memory[0]
