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

    terminate
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
        fetch_input(mode: parameter_modes[0], argument: @pointer + 1)
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
      end
  end

    # Determines what to return when run() is finished
    def terminate
      if @output_mode == :console
        @memory
      elsif @output_mode == :return
        @output
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

    # Sum parameter will always be in position mode
    def add(modes:, arguments:)
      addend1 = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      addend2 = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      sum_address = arguments[2]

      @memory[sum_address] = addend1 + addend2
      @pointer += 4
    end

    # Product parameter will always be in position mode
    def multiply(modes:, arguments:)
      factor1 = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      factor2 = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      product_address = arguments[2]

      @memory[product_address] = factor1 * factor2
      @pointer += 4
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
      @pointer += 2
    end

    def send_output(modes:, arguments:)
      value = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      if @output_mode == :console
        puts "Diagnostic code: #{value}"
      elsif @output_mode == :return
        @output = value
      end
      @pointer += 2
      @paused = true if @output_mode == :return
    end

    # Returns the new pointer index
    def jump_if_true(modes:, arguments:)
      jump = modes[0] == 1 ? !arguments[0].zero? : !@memory[arguments[0]].zero?
      address = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      @pointer = jump ? address : @pointer + 3
    end

    # Returns the new pointer index
    def jump_if_false(modes:, arguments:)
      jump = modes[0] == 1 ? arguments[0].zero? : @memory[arguments[0]].zero?
      address = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      @pointer = jump ? address : @pointer + 3
    end

    # Result will always be in position mode
    def less_than(modes:, arguments:)
      term1 = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      term2 = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      result_address = arguments[2]

      @memory[result_address] = term1 < term2 ? 1 : 0
      @pointer += 4
    end

    # Result will always be in position mode
    def equals(modes:, arguments:)
      term1 = modes[0] == 1 ? arguments[0] : @memory[arguments[0]]
      term2 = modes[1] == 1 ? arguments[1] : @memory[arguments[1]]
      result_address = arguments[2]

      @memory[result_address] = term1 == term2 ? 1 : 0
      @pointer += 4
    end
end
