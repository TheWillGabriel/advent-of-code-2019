require 'colorize'

WHITE = '  '.colorize(background: :white)
BLACK = '  '.colorize(background: :black)

# Images encoded in layers of width * height digit length
class Image
  def initialize(image_data, width, height)
    @image_data = image_data
    @width = width
    @height = height
    @layers = layers
  end

  # "Checksum": Product of 1s and 2s counts on layer with least zeroes
  def verify
    verification_layer = @layers[least_zeroes]
    verification_layer.count('1') * verification_layer.count('2')
  end

  def render
    rows = flatten.scan(/.{#{@width}}/)
    rows.each_index do |index|
      rows[index] = rows[index].gsub('0', BLACK).gsub('1', WHITE)
    end
    rows
  end

  def flatten
    image = []

    @layers.reverse.each do |layer|
      image = flatten_layer(image, layer)
    end

    image.join
  end

  private

    def flatten_layer(image, layer)
      output = image

      layer.each_char.with_index do |pixel, index|
        if pixel == '0'
          output[index] = '0'
        elsif pixel == '1'
          output[index] = '1'
        end
      end

      output
    end

    def least_zeroes
      @layers.index(@layers.min { |a, b| a.count('0') <=> b.count('0') })
    end

    # Splits image into a list of layer-size numbers
    def layers
      @image_data.scan(/.{#{layer_size}}/)
    end

    def layer_size
      @width * @height
    end
end

input = File.read('input.txt')
image = Image.new(input, 25, 6)
puts image.render
