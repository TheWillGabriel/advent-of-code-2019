require 'colorize'

# Pauses execution if awaiting an input
class Computer
  attr_reader :done

  def initialize(intcode)
    @memory = intcode.dup
    @inputs = []
    @pointer = 0
    @relative_base = 0
    @outputs = []
    @done = false # Program reached opcode 99
    @paused = false # Program awaiting input
  end

  # Takes a list of inputs as an argument. Will prompt if none passed.
  def run(*args)
    @inputs = args.flatten
    @outputs = []
    @paused = false

    while @done == false && @paused == false
      opcode = @memory[@pointer] % 100
      run_instruction(opcode)

      @done = true if @memory[@pointer] == 99 || @pointer + 1 >= @memory.length
    end

    @outputs
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
        @paused = true
        return
      else
        input = @inputs.shift
      end
      @memory[destination_address] = input
      @pointer += 2
    end

    def send_output(modes:, arguments:)
      value = read(address: arguments[0], mode: modes[0])
      @outputs << value
      @pointer += 2
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

# Controller for hull painting robot; uses left-handed coordinates.
class PaintingRobot
  attr_reader :canvas

  WHITE = '  '.colorize(background: :white)
  BLACK = '  '.colorize(background: :black)
  COLORS = %i[black white].freeze
  DIRECTIONS = %i[north east south west].freeze
  MOVES = { north: [0, -1],
            east: [1, 0],
            south: [0, 1],
            west: [-1, 0] }.freeze

  def initialize(memory, starting_color)
    @computer = Computer.new(memory)
    @canvas = { '0,0' => starting_color }
    @position = [0, 0]
    @direction = :north
  end

  def run
    until @computer.done
      coordinates = to_coordinates(@position)
      output = if @canvas[coordinates].nil?
                 0
               else
                 COLORS.index(@canvas[coordinates])
               end
      input = @computer.run(output)
      paint(input[0])
      move(input[1])
    end
  end

  def pretty_print
    output = render.map do |row|
      row.map do |space|
        space == '#' ? WHITE : BLACK
      end.join
    end
    output
  end

  private

    def render
      x_coordinates = @canvas.keys.map { |coords| coords.split(',')[0].to_i }
      y_coordinates = @canvas.keys.map { |coords| coords.split(',')[1].to_i }
      offset = [x_coordinates.min, y_coordinates.min]
      width = x_coordinates.max - x_coordinates.min + 1
      height = y_coordinates.max - y_coordinates.min + 1
      grid = Array.new(width) { Array.new(height, '.') }
      add_white(grid, offset)
      grid.transpose
    end

    # Takes a generated grid and marks white coordinates
    def add_white(grid, offset)
      @canvas.each do |coordinates, color|
        if color == :white
          position = to_position(coordinates)
          grid[position[0] - offset[0]][position[1] - offset[1]] = '#'
        end
      end
      grid
    end

    def paint(color_code)
      coordinates = to_coordinates(@position)
      color = COLORS[color_code]
      @canvas[coordinates] = color
    end

    # robot always moves forward one panel after it turns
    def move(direction_code)
      turn(direction_code)
      @position = [@position[0] + MOVES[@direction][0],
                   @position[1] + MOVES[@direction][1]]
    end

    # direction codes: 0 == left, 1 == right
    def turn(direction_code)
      current_index = DIRECTIONS.index(@direction)
      @direction = if direction_code.zero?
                     DIRECTIONS[current_index - 1]
                   elsif direction_code == 1
                     DIRECTIONS[(current_index + 1) % 4]
                   end
    end

    def to_coordinates(position)
      "#{position[0]},#{position[1]}"
    end

    def to_position(coordinates)
      coordinates.split(',').map(&:to_i)
    end
end

memory = File.read('input.txt').split(',').map(&:to_i)

robot = PaintingRobot.new(memory, :white)
robot.run
puts robot.pretty_print
