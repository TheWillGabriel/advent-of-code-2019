class AsteroidMap
  def initialize(input)
    # map coordinates as (row, column); opposite of (x, y)
    @map = input
    # all possible lines of sight for X in (-1..1)
    @y_angles = -input.length..input.length
    # all possible lines of sight for Y in (-1..1)
    @x_angles = -input[0].length..input[0].length
  end

  def best_location
    # locations = [] ({:location, :count})
    # For each coordinate pair
    # - If coordinate pair == '#'
    # - - locations << {location: (x,y), count: count_asteroids(x,y)}

    # locations.max_by(&:count)
  end

  def count_asteroids(coordinates)
    # visible_asteroids = 0
    # For each line of sight
    # - Assign the first LoS coordinate
    # - While the current LoS coordinate is within the map size
    # - - (visible_asteroids += 1) && break if (x,y) == '#'
    # - - Assign the next Los coordinate

    # visible_asteroids
  end
end

input = File.read('example.txt').split.map { |line| line.split('') }
map = AsteroidMap.new(input)