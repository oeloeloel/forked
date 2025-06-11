module Forked
  # Display class
  class Display
    def display_button_row(y_pos, item)
      # "==== def display_button_row(y_pos, #{item})"
      return y_pos if item.content.empty?

      display_method = "display_#{item.type}".to_sym
      return unless self.methods.include?(display_method)

      display = data.style.display
      style = data.style.button
      rows = [[]]
      running_w = 0
      max_w = data.style.display.w
      last_remaining_space = 0
      running_y = y_pos 
      button_rect = {}
      item.content.each_with_index do |button, idx|
        left = data.style.display.margin_left + data.style.button.margin_left + running_w
        button_rect = { x: left, y: running_y, w: 0, h: 0}
        btn = make_button(button_rect, button)

        running_w += data.style.button.margin_left + button_rect.w

        if running_w > max_w && idx > 0
          # wrapping. Add a new row and put the button in it
          running_w = style.margin_left
          running_y -= style.margin_bottom +
                       button_rect.h +
                       style.margin_top +
                       style.spacing_between * button_rect.h
          btn.x = running_w + display.margin_left
          center_button_row(rows[-1], last_remaining_space)

          rows << []
          running_w += style.margin_left + button_rect.w
        else
          # not wrapping. Add the button's right margin and calc the remaining space
          running_w += style.margin_right
          last_remaining_space = max_w - running_w
        end

        btn.y = running_y - btn.h
        rows[-1] << btn

        # if last button, center the row
        if idx == item.content.size - 1
          last_remaining_space = max_w - running_w
          # center the last row
          center_button_row(rows[-1], last_remaining_space)
        end
      end

      data.primitives << rows
      data.options << rows
      data.options.flatten!

      # buttons need this in order to be highlighted
      highlight_selected_option

      running_y -= (style.margin_bottom + button_rect.h + style.spacing_after * button_rect.h)
    end

    def center_button_row(row, space)
      if row.size == 1 && row[0].w > space
      else
        row.each { |b| b.x += space / 2}
      end
    end

    # def make_button(y_pos, item)
    def make_button(button_rect, item)
      y_pos = button_rect.y
      button = data.style.button
      display = data.style.display

      button.size_px = args.gtk.calcstringbox('X', button.size_enum, button.font)[1]

      # previous element is also a button? use spacing_between instead of spacing_after
      if @last_printed_element_type == :button
        y_pos += button.spacing_after * button.size_px
        y_pos -= button.spacing_between * button.size_px
      end

      if item.action.empty?
        button = data.style.disabled_button
      end

      text_w, button.size_px = args.gtk.calcstringbox(item.text, button.size_enum, button.font)
      text_w = text_w.to_i
      button_h = (button.size_px + button.padding_top + button.padding_bottom)
      x = button_rect.x
      y = (y_pos - button_h).to_i
      w = text_w + button.padding_left + button.padding_right
      h = (button.size_px + button.padding_top + button.padding_bottom).to_i

      button_rect.w = w
      button_rect.h = h

      pill_button_base = { x: x, y: y, w: w, h: h, text: item.text, action: item.action }

      enabled = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: { r: button.r, g: button.g, b: button.b, a: button.a || 255 },
        bg: { 
          r: button.background_color.r, 
          g: button.background_color.g, 
          b: button.background_color.b, 
          a: button.a || 255
        },
        font: button.font,
        size_enum: button.size_enum
      )
      focused = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: {
          r: data.style.selected_button.r,
          g: data.style.selected_button.g,
          b: data.style.selected_button.b,
          a: data.style.selected_button.a || 255
        },
        bg: {
          r: data.style.selected_button.background_color.r,
          g: data.style.selected_button.background_color.g,
          b: data.style.selected_button.background_color.b,
          a: data.style.selected_button.background_color.a || 255
        },
        font: data.style.selected_button.font,
        size_enum: data.style.selected_button.size_enum
      )
      active = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: {
          r: data.style.active_button.r,
          g: data.style.active_button.g,
          b: data.style.active_button.b,
          a: data.style.active_button.a || 255
        },
        bg: {
          r: data.style.active_button.background_color.r,
          g: data.style.active_button.background_color.g,
          b: data.style.active_button.background_color.b,
          a: data.style.active_button.a || 255
        },
        font: data.style.active_button.font,
        size_enum: data.style.active_button.size_enum
      )
      disabled = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: {
          r: data.style.disabled_button.r,
          g: data.style.disabled_button.g,
          b: data.style.disabled_button.b,
          a: data.style.disabled_button.a || 255
        },
        bg: {
          r: data.style.disabled_button.background_color.r,
          g: data.style.disabled_button.background_color.g,
          b: data.style.disabled_button.background_color.b,
          a: data.style.disabled_button.background_color.a || 255
        },
        font: data.style.disabled_button.font,
        size_enum: data.style.disabled_button.size_enum
      )

      option = Effed::FButton.new(
        rect: pill_button_base,
        enabled: enabled,
        focused: focused,
        active: active,
        disabled: disabled
      )

      option.force_status_change(:disabled) if item.action.empty?
      y_pos - (button.padding_top +
               button.padding_bottom +
               button.size_px +
               button.size_px * button.spacing_after)

      return option
    end
  end
end