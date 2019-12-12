# All bodies directly orbit only one other body
class Body
  attr_reader :name, :orbiting, :orbited_by

  def initialize(name, orbiting = nil)
    @name = name
    @orbiting = orbiting
    @orbited_by = []
  end

  def orbits
    return 1 if @orbiting.name == 'COM'

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
    build_map(map_list)
  end

  def build_map(map_list)
    map_list.each do |orbit|
      bodies = orbit.split(')')
      orbited = find_body(bodies[0])
      orbiting = Body.new(bodies[1], orbited)
      orbited.add_orbiting_body(orbiting)
    end
  end
end
