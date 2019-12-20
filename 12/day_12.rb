# Stores Body instances and methods for manipulating them as a group
class System
  attr_accessor :bodies
  def initialize(input)
    @bodies = generate_bodies(input)
  end

  private

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
  end

  private

    def parse_position(position_string)
      position_array = position_string[1..-2].split(', ').map do |axis|
        axis.split('=')
      end
      position_array.to_h.transform_keys(&:to_sym)
    end
end

input = File.read('example.txt')

system = System.new(input)

system.bodies.each do |body|
  puts body.position
end
