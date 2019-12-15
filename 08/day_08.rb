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

  private

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
puts image.verify
