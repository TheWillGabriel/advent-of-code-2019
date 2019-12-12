# All bodies directly orbit only one other body
class Body
  attr_accessor :orbiting
  attr_reader :name, :orbited_by

  def initialize(name, orbiting = nil)
    @name = name
    @orbiting = orbiting
    @orbited_by = []
  end

  def orbits
    return 0 if @orbiting.nil?

    @orbiting.orbits + 1
  end

  def add_orbiting_body(body)
    @orbited_by << body
  end
end

# A collection of objects related by orbit to a Center of Mass (COM)
class OrbitalMap
  def initialize(map_list)
    @com = Body.new('COM')
    @bodies = [@com]
    build_map(map_list)
  end

  def build_map(map_list)
    map_list.each do |orbit|
      bodies = orbit.split(')')
      add_orbit(bodies[0], bodies[1])
    end
  end

  def add_orbit(orbited_name, orbiting_name)
    orbited = find_or_create_body(orbited_name)
    orbiting = Body.new(orbiting_name, orbited)
      orbited.add_orbiting_body(orbiting)
      @bodies << orbiting
    end

  def find_or_create_body(name)
    find_body(name) || create_body(name)
  end

  def create_body(name, parent = nil)
    body = Body.new(name, parent)
    @bodies << body
    body
  end

  def find_body(name)
    @bodies.each do |body|
      return body if body.name == name
    end
    nil
  end

  def all_orbits
    orbits = 0
    @bodies.each do |body|
      orbits += body.orbits
    end
    orbits
  end
end
