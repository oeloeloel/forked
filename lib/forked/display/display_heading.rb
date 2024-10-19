
module Forked
  # Display class
  class Display
    def display_heading(y_pos, item, _previous_element_type)
      heading = data.style.heading
      display = data.style.display
      heading.size_px = args.gtk.calcstringbox('X', heading.size_enum, heading.font)[1]

      if heading.align
        canvas_w = display.w
        x_offset = canvas_w * heading.align
        x_pos = display.margin_left + x_offset
        anchor_x = heading.align
      end

      data.primitives << {
        x: x_pos || display.margin_left,
        y: y_pos.to_i,
        text: item.text,
        anchor_x: anchor_x || 0
      }.label!(heading)

      y_pos - heading.size_px * heading.spacing_after
    end
  end
end