require 'pry'

# Output modes: :list, :single
# list: Stores as an array
# single: Stores a single result then pauses
class Computer
  attr_reader :done

  def initialize(intcode, output_mode = :list)
    @memory = intcode.dup
    @inputs = nil
    @pointer = 0
    @relative_base = 0
    @output_mode = output_mode
    @output = []
    @done = false
    @paused = false
  end

  # Takes a list of inputs as an argument. Will prompt if none passed.
  def run(*args)
    @inputs = args
    @paused = false

    while @done == false && @paused == false
      opcode = @memory[@pointer] % 100
      run_instruction(opcode)

      @done = true if @memory[@pointer] == 99 || @pointer + 1 >= @memory.length
    end

    @output
  end

  private

    # instruction_params:
    # { modes: parameter_modes, arguments: current_arguments }
    def run_instruction(opcode)
      case opcode
      when 1
        add(**instruction_params)
      when 2
        multiply(**instruction_params)
      when 3
        fetch_input(**instruction_params)
      when 4
        send_output(**instruction_params)
      when 5
        jump_if_true(**instruction_params)
      when 6
        jump_if_false(**instruction_params)
      when 7
        less_than(**instruction_params)
      when 8
        equals(**instruction_params)
      when 9
        relative_base(**instruction_params)
      end
    end

    def instruction_params
      { modes: parameter_modes, arguments: current_arguments }
    end

    def parameter_modes
      mode1 = @memory[@pointer] / 100 % 10
      mode2 = @memory[@pointer] / 1000 % 10
      mode3 = @memory[@pointer] / 10_000 % 10
      [mode1, mode2, mode3]
    end

    def current_arguments
      @memory[(@pointer + 1)..(@pointer + 3)]
    end

    # mode 0: Position
    # mode 1: Immediate
    # mode 2: Relative
    # nil addresses return zero
    def read(address:, mode:)
      case mode
      when 0
        @memory[address] || 0
      when 1
        address
      when 2
        @memory[@relative_base + address] || 0
      else
        puts "Warning: invalid mode given for address #{address}"
      end
    end

    # mode 0: Position
    # mode 2: Relative
    # writes are never in immediate mode
    def write(address:, mode:)
      case mode
      when 0
        address
      when 2
        @relative_base + address
      end
    end

    def add(modes:, arguments:)
      addend1 = read(address: arguments[0], mode: modes[0])
      addend2 = read(address: arguments[1], mode: modes[1])
      sum_address = write(address: arguments[2], mode: modes[2])

      @memory[sum_address] = addend1 + addend2
      @pointer += 4
    end

    def multiply(modes:, arguments:)
      factor1 = read(address: arguments[0], mode: modes[0])
      factor2 = read(address: arguments[1], mode: modes[1])
      product_address = write(address: arguments[2], mode: modes[2])

      @memory[product_address] = factor1 * factor2
      @pointer += 4
    end

    # Pulls next input from the front of input array if any exist
    def fetch_input(modes:, arguments:)
      destination_address = write(address: arguments[0], mode: modes[0])
      if @inputs.empty?
        puts 'Enter the ID of the system to test'
        input = gets.chomp.to_i
      else
        input = @inputs.shift
      end
      @memory[destination_address] = input
      @pointer += 2
    end

    def send_output(modes:, arguments:)
      value = read(address: arguments[0], mode: modes[0])
      if @output_mode == :list
        @output << value
      elsif @output_mode == :single
        @output = value
      end
      @pointer += 2
      @paused = true if @output_mode == :single
    end

    # Returns the new pointer index
    def jump_if_true(modes:, arguments:)
      value = read(address: arguments[0], mode: modes[0])
      address = read(address: arguments[1], mode: modes[1])
      jump = !value.zero?
      @pointer = jump ? address : @pointer + 3
    end

    # Returns the new pointer index
    def jump_if_false(modes:, arguments:)
      value = read(address: arguments[0], mode: modes[0])
      address = read(address: arguments[1], mode: modes[1])
      jump = value.zero?
      @pointer = jump ? address : @pointer + 3
    end

    # Result will always be in position mode
    def less_than(modes:, arguments:)
      term1 = read(address: arguments[0], mode: modes[0])
      term2 = read(address: arguments[1], mode: modes[1])
      result_address = write(address: arguments[2], mode: modes[2])

      @memory[result_address] = term1 < term2 ? 1 : 0
      @pointer += 4
    end

    # Result will always be in position mode
    def equals(modes:, arguments:)
      term1 = read(address: arguments[0], mode: modes[0])
      term2 = read(address: arguments[1], mode: modes[1])
      result_address = write(address: arguments[2], mode: modes[2])

      @memory[result_address] = term1 == term2 ? 1 : 0
      @pointer += 4
    end

    def relative_base(modes:, arguments:)
      @relative_base += read(address: arguments[0], mode: modes[0])
      @pointer += 2
    end
end

memory = File.read('input.txt').split(',').map(&:to_i)

computer = Computer.new(memory)
puts computer.run(1)
