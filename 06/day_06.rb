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

  def transfers_to(parent_body)
    return 0 if self == parent_body

    @orbiting.transfers_to(parent_body) + 1
  end

  def children
    @orbited_by.map(&:children).flatten + @orbited_by
  end

  def add_orbiting_body(body)
    @orbited_by << body
  end
end

# A collection of objects related by orbit to a Center of Mass (COM)
class OrbitalMap
  def initialize(map_list)
    @bodies = []
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
    orbiting = find_or_create_body(orbiting_name, orbited)
    orbited.add_orbiting_body(orbiting)
  end

  def find_or_create_body(name, parent = nil)
    body = find_body(name) || create_body(name, parent)
    body.orbiting ||= parent
    body
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

  def nearest_common_parent(body1, body2)
    parent = body1.orbiting

    until parent.children.include?(body2)
      parent = parent.orbiting
      return nil if parent.nil?
    end

    parent
  end

  def orbital_transfers(name1, name2)
    current_orbit = find_body(name1).orbiting
    destination_orbit = find_body(name2).orbiting
    common_parent = nearest_common_parent(current_orbit,
                                          destination_orbit)

    hops_up = current_orbit.transfers_to(common_parent)
    hops_down = destination_orbit.transfers_to(common_parent)

    hops_up + hops_down
  end
end

input = File.read('input.txt').split
orbital_map = OrbitalMap.new(input)
puts orbital_map.orbital_transfers('YOU', 'SAN')
