class AsteroidMap
  attr_reader :asteroids

  def initialize(input)
    @chart = input
    @asteroids = asteroid_list
  end

  def best_location
    locations = [] # ({:location, :count})
    @asteroids.each do |station|
      locations << { location: station, visible: count_asteroids(station) }
    end

    locations.max_by { |station| station[:visible] }
  end

  def vaporize
    vaporized = []
    angle_groups = asteroid_angles(best_location[:location])

    until vaporized.length == @asteroids.length - 1
      angle_groups.each_value do |group|
        vaporized << group.shift unless group.empty?
      end
    end

    vaporized
  end

  private

    # Translates [column, row] into [x, y]
    def asteroid_list
      rows = @chart.map.with_index do |row, y_index|
        asteroids = row.each_index.select do |x_index|
          row[x_index] == '#'
        end
        asteroids.map { |x_index| [x_index, y_index] }
      end
      rows.flatten(1)
    end

    def count_asteroids(station)
      visible_asteroids = 0

      @asteroids.each do |asteroid|
        if asteroid != station &&
           !blocked?(station[0], station[1], asteroid[0], asteroid[1])
          visible_asteroids += 1
        end
      end

      visible_asteroids
    end

    def asteroid_angles(station)
      # Stores angle (radians) => asteroids ([[x1,y1], [x2,y2], ...])
      asteroid_groups = {}

      @asteroids.each do |asteroid|
        next if asteroid == station

        angle = asteroid_angle(station, asteroid)
        asteroid_groups[angle] ||= []
        asteroid_groups[angle] << asteroid
      end

      sort_by_distance!(station, asteroid_groups)

      # Return hash sorted by angle
      asteroid_groups.sort.to_h
    end

    # Angle in radians
    def asteroid_angle(station, asteroid)
      Math.atan2(asteroid[0] - station[0],
                 -(asteroid[1] - station[1])) % (2 * Math::PI)
    end

    def sort_by_distance!(station, asteroid_groups)
      asteroid_groups.each_value do |group|
        group.sort_by! do |asteroid|
          (asteroid[0] - station[0]).abs + (asteroid[1] - station[1]).abs
        end
      end
    end

    # space1 and space2 must be different
    def blocked?(station_x, station_y, asteroid_x, asteroid_y)
      x_distance = asteroid_x - station_x
      y_distance = asteroid_y - station_y

      x_interval = x_distance / x_distance.gcd(y_distance)
      y_interval = y_distance / x_distance.gcd(y_distance)

      x_next = station_x + x_interval
      y_next = station_y + y_interval

      until x_next == asteroid_x && y_next == asteroid_y
        return true if @chart[y_next][x_next] == '#'

        x_next += x_interval
        y_next += y_interval
      end

      false
    end
end

input = File.read('input.txt').split.map { |line| line.split('') }
map = AsteroidMap.new(input)
p map.vaporize[199]
