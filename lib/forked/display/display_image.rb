
module Forked
  # Display class
  class Display

    # display image 2 accepts a rect representing
    # the space available for the image to occupy
    def display_image2(rect, item)
      image = data.style.image
      display = data.style.display

      # outputs.static_debug << rect.dup.border!(r: 255)

      # I don't know why path doesn't work *as is*
      # It's a string, and it doesn't have any odd
      # characters in it
      # But putting it into a _new_ string makes it work
      path = item[:path].strip.to_s
      merger = {}
      if path.end_with?('}') && path.include?('{')
        path, remnant = Forked::Parser.pull_out('{', '}', path)
        merger = eval('{' + remnant + '}')
      end

      h = merger.h || 80
      w = merger.w || 80

      im = {
        **image,
        x: rect.x,
        y: rect.y.to_i - h,
        w: w,
        h: h,
        path: path,
        anchor_x: 0,
      }.sprite!

      data.primitives << im.merge(merger)

      outputs.static_debug << im.rect.dup.border!(g: 255, b: 255)

      rect.y -= (h + image.spacing_after)
      rect
    end

    def display_image(y_pos, item)
      image = data.style.image
      display = data.style.display

      # I don't know why path doesn't work *as is*
      # It's a string, and it doesn't have any odd
      # characters in it
      # But putting it into a _new_ string makes it work
      path = item[:path].strip.to_s
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