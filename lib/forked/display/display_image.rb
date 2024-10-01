
module Forked
  # Display class
  class Display
    def display_image(y_pos, item)
      image = data.style.image
      display = data.style.display

      # I don't know why path doesn't work *as is*
      # It's a string, and it doesn't have any odd
      # characters in it
      # But putting it into a _new_ string makes it work
      path = item[:path].to_s
      merger = {}
      if path.end_with?('}') && path.include?('{')
        path, remnant = Forked::Parser.pull_out('{', '}', path)
        merger = eval('{' + remnant + '}')
      end

      h = merger.h || 80
      # w = merger.w || 80

      im = {
        x: display.margin_left,
        y: y_pos.to_i - h,
        w: 80,
        h: h,
        path: path
      }.sprite!(image)

      data.primitives << im.merge(merger)

      y_pos - (h + image.spacing_after)
    end
  end
end