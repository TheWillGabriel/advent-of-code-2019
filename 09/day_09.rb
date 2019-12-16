# Output modes: :console, :return
class Computer
  attr_reader :done

  def initialize(intcode, output_mode = :console)
    @memory = intcode.dup
    @inputs = nil
    @pointer = 0
    @output_mode = output_mode
    @output = nil
    @done = false
  end

  # Takes a list of inputs as an argument. Will prompt if none passed.
  def run(*args)
    @inputs = args

    while @done == false
      opcode = @memory[@pointer] % 100
      mode1 = @memory[@pointer] / 100 % 10
      mode2 = @memory[@pointer] / 1000 % 10
      mode3 = @memory[@pointer] / 10_000 % 10
      argument1 = @memory[@pointer + 1]
      argument2 = @memory[@pointer + 2]
      argument3 = @memory[@pointer + 3]

      if opcode == 1
        add(modes: [mode1, mode2],
            arguments: [argument1, argument2, argument3])
        @pointer += 4
      elsif opcode == 2
        multiply(modes: [mode1, mode2],
                 arguments: [argument1, argument2, argument3])
        @pointer += 4
      elsif opcode == 3
        fetch_input(mode: mode1,
                    argument: @pointer + 1)
        @pointer += 2
      elsif opcode == 4
        send_output(mode: mode1,
                    argument: argument1)
        @pointer += 2
        break if @output_mode == :return
      elsif opcode == 5
        @pointer = jump_if_true(modes: [mode1, mode2],
                                arguments: [argument1, argument2])
      elsif opcode == 6
        @pointer = jump_if_false(modes: [mode1, mode2],
                                 arguments: [argument1, argument2])
      elsif opcode == 7
        less_than(modes: [mode1, mode2],
                  arguments: [argument1, argument2, argument3])
        @pointer += 4
      elsif opcode == 8
        equals(modes: [mode1, mode2],
               arguments: [argument1, argument2, argument3])
        @pointer += 4
      end

      @done = true if @memory[@pointer] == 99 || @pointer + 1 >= @memory.length
    end

    terminate
  end

  private

    # Determines what to return when run() is finished
    def terminate
      if @output_mode == :console
        @memory
      elsif @output_mode == :return
        @output
      end
    end

    # Sum parameter will always be in position mode
    def add(modes:, arguments:)
      addend1 = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      addend2 = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      sum_address = arguments[2]

      @memory[sum_address] = addend1 + addend2
    end

    # Product parameter will always be in position mode
    def multiply(modes:, arguments:)
      factor1 = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      factor2 = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      product_address = arguments[2]

      @memory[product_address] = factor1 * factor2
    end

    # Pulls next input from the front of input array if any exist
    def fetch_input(mode:, argument:)
      destination_address = mode == 1 ? argument : @memory[argument]
      if @inputs.empty?
        puts 'Enter the ID of the system to test'
        input = gets.chomp.to_i
      else
        input = @inputs.shift
      end
      @memory[destination_address] = input
    end

    def send_output(mode:, argument:)
      value = mode == 1 ? argument : @memory[argument]
      if @output_mode == :console
        puts "Diagnostic code: #{value}"
      elsif @output_mode == :return
        @output = value
      end
    end

    # Returns the new pointer index
    def jump_if_true(modes:, arguments:)
      jump = modes[0] == 1 ? !arguments[0].zero? : !@memory[arguments[0]].zero?
      address = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      jump ? address : @pointer + 3
    end

    # Returns the new pointer index
    def jump_if_false(modes:, arguments:)
      jump = modes[0] == 1 ? arguments[0].zero? : @memory[arguments[0]].zero?
      address = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      jump ? address : @pointer + 3
    end

    # Result will always be in position mode
    def less_than(modes:, arguments:)
      term1 = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      term2 = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      result_address = arguments[2]

      @memory[result_address] = term1 < term2 ? 1 : 0
    end

    # Result will always be in position mode
    def equals(modes:, arguments:)
      term1 = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      term2 = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      result_address = arguments[2]

      @memory[result_address] = term1 == term2 ? 1 : 0
    end
end