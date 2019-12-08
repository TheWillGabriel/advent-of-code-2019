def run_intcode(input)
  intcode = input.dup
  opcode_index = 0

  while opcode_index + 1 < intcode.length && intcode[opcode_index] != 99
    index1 = intcode[opcode_index + 1]
    index2 = intcode[opcode_index + 2]
    index3 = intcode[opcode_index + 3]

    if intcode[opcode_index] == 1
      intcode[index3] = intcode[index1] + intcode[index2]
    elsif intcode[opcode_index] == 2
      intcode[index3] = intcode[index1] * intcode[index2]
    end

    opcode_index += 4
  end

  intcode
end

intcode_array = File.read('input.txt').split(',').map(&:to_i)
intcode_array[1] = 12
intcode_array[2] = 2
result = run_intcode(intcode_array)

p intcode_array
p result
