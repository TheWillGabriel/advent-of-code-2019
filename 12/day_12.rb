# Stores Body instances and methods for manipulating them as a group
class System
  attr_accessor :bodies
  def initialize(input)
    @bodies = generate_bodies(input)
  end

  private

    def accelerate_bodies
      reference_bodies = body_positions
      @bodies.each do |body|
        %i[x y z].each do |axis|
          accelerate_body_axis(axis, body, reference_bodies)
        end
      end
    end

    def accelerate_axis(axis, body, reference_bodies)
      references = []
      reference_bodies.each do |reference_body|
        next if position[:body] == body

        references << reference_body.position[axis]
      end
      body.set_velocity(axis, references)
    end

    def body_positions
      @bodies.map do |body|
        { body: body, position: @body.position }
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
  attr_accessor :position

  def initialize(position_string)
    @position = parse_position(position_string)
    @velocity = { x: 0, y: 0, z: 0 }
  end

  def state
    "pos=#{@position}, vel=#{@velocity}".gsub('{', '<')
                                        .gsub('}', '>')
                                        .gsub(':', '')
                                        .gsub('=>', '=')
  end

  private

    # reference: axis-position of influencing body
    def set_velocity(axis, references)
      starting_position = @position[axis]
      acceleration = 0
      references.each do |reference|
        acceleration = if starting_position < reference
                         acceleration + 1
                       elsif starting_position > reference
                         acceleration - 1
                       end
      end
      @velocity[axis] += acceleration
    end

    def parse_position(position_string)
      position_array = position_string[1..-2].split(', ').map do |axis|
        axis.split('=')
      end
      position_array.to_h.transform_keys(&:to_sym).transform_values(&:to_i)
    end
end

input = File.read('example.txt')

system = System.new(input)

system.bodies.each do |body|
  puts body.state
end
