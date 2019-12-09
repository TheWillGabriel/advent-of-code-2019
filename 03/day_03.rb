wires = File.read('input.txt').split
wire1 = wires[0].split(',')
wire2 = wires[1].split(',')
CENTRAL_PORT = [0, 0].freeze

def shortest_distance(coordinate_list)
  distances = []
  coordinate_list.each do |coordinates|
    distances.push taxicab_distance(coordinates)
  end
  distances.min
end

def taxicab_distance(coordinates)
  x_distance = CENTRAL_PORT[0] + coordinates[0].abs
  y_distance = CENTRAL_PORT[1] + coordinates[1].abs
  x_distance + y_distance
end

def shortest_wire_distance(wire_a, wire_b)
  intersection_steps(wire_a, wire_b).min
end

def intersection_steps(wire_a, wire_b)
  path_a = wire_path(wire_a)
  path_b = wire_path(wire_b)
  intersections = path_a & path_b
  lengths_to_intersections = []

  intersections.each do |node|
    a_steps = steps_to(path_a, node)
    b_steps = steps_to(path_b, node)
    lengths_to_intersections.push(a_steps + b_steps)
  end

  lengths_to_intersections
end

def steps_to(path, coordinates)
  path.index(coordinates) + 1
end

def wire_path(wire)
  path = []
  current_line = [CENTRAL_PORT]
  wire.each do |wire_length|
    current_line = wire_line(current_line.last, wire_length)
    path.concat current_line
  end
  path
end

def wire_line(start, vector)
  path = []
  current_node = start
  direction = vector[0]
  length = vector[1..-1].to_i

  length.times do
    current_node = move_one(current_node, direction)
    path.push current_node
  end
  path
end

def move_one(last_node, direction)
  case direction
  when 'U'
    [last_node[0], last_node[1] + 1]
  when 'D'
    [last_node[0], last_node[1] - 1]
  when 'R'
    [last_node[0] + 1, last_node[1]]
  when 'L'
    [last_node[0] - 1, last_node[1]]
  end
end

p shortest_wire_distance(wire1, wire2)
