# Stores Body instances and methods for manipulating them as a group
class System
  attr_accessor :bodies
  def initialize(input)
    @bodies = generate_bodies(input)
    @input = input
  end

  def simulate(steps = 1)
    steps.times do
      accelerate_bodies
      move_bodies
    end
  end

  def reset
    @bodies = generate_bodies(@input)
  end

  def state
    @bodies.map(&:state).join("\n")
  end

  def total_energy
    @bodies.map(&:total_energy).reduce(:+)
  end

  # Returns the number of steps until system returns to original state
  def steps_to_repeat
    periods = %i[x y z].map do |axis|
      axis_period(axis)
    end
    periods.reduce(:lcm)
  end

  private

    def axis_period(axis)
      reset
      start_positions = axis_positions(axis)
      start_velocities = axis_velocities(axis)
      simulate
      count = 1
      until axis_positions(axis) == start_positions &&
            axis_velocities(axis) == start_velocities
        simulate
        count += 1
      end
      count
    end

    def move_bodies
      @bodies.each(&:move)
    end

    def accelerate_bodies
      reference_bodies = body_positions
      @bodies.each do |body|
        %i[x y z].each do |axis|
          accelerate_body_axis(body, axis, reference_bodies)
        end
      end
    end

    def accelerate_body_axis(body, axis, reference_bodies)
      references = []
      reference_bodies.each do |reference_body|
        next if reference_body[:body] == body

        references << reference_body[:position][axis]
      end
      body.set_velocity(axis, references)
    end

    def body_positions
      @bodies.map do |body|
        { body: body, position: body.position }
      end
    end

    def axis_positions(axis)
      @bodies.map do |body|
        body.position[axis]
      end
    end

    def axis_velocities(axis)
      @bodies.map do |body|
        body.velocity[axis]
      end
    end

    def generate_bodies(input)
      input.split("\n").map do |position|
        Body.new(position)
      end
    end
end

# Stores Body instance variables and individual methods
class Body
  attr_accessor :position, :velocity

  def initialize(position_string)
    @position = parse_position(position_string)
    @velocity = { x: 0, y: 0, z: 0 }
  end

  def state
    "pos: #{@position}, vel: #{@velocity}"
  end

  # reference: axis-position of influencing body
  def set_velocity(axis, references)
    starting_position = @position[axis]
    acceleration = 0
    references.each do |reference|
      if starting_position < reference
        acceleration += 1
      elsif starting_position > reference
        acceleration -= 1
      end
    end
    @velocity[axis] += acceleration
  end

  # Only call once per step; velocity will be affected by system gravity
  def move
    @position.each_key do |axis|
      @position[axis] += @velocity[axis]
    end
  end

  def total_energy
    potential_energy * kinetic_energy
  end

  private

    def potential_energy
      @position.values.reduce(0) do |a, b|
        a.abs + b.abs
      end
    end

    def kinetic_energy
      @velocity.values.reduce(0) do |a, b|
        a.abs + b.abs
      end
    end

    def parse_position(position_string)
      position_array = position_string[1..-2].split(', ').map do |axis|
        axis.split('=')
      end
      position_array.to_h.transform_keys(&:to_sym).transform_values(&:to_i)
    end
end

input = File.read('input.txt')

system = System.new(input)

puts system.steps_to_repeat
