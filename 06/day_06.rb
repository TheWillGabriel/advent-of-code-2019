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
