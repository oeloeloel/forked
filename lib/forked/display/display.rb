require_relative 'display_paragraph.rb'
require_relative 'display_blockquote.rb'

$gtk.reset

module Forked
  # Display class
  class Display
    attr_gtk

    def initialize(theme = nil)
      # set the current theme if passed
      @theme = theme
    end

    def tick
      defaults unless data.defaults_set
      input
      render
    end

    # stores object data in state
    def data
      args.state.forked.display ||= args.state.new_entity('forked display')
    end

    def defaults
      data.style = config_defaults # display defaults
      data.options = []             # current options (buttons) in chunk
      apply_theme(@theme)           # set the current theme

      # get input defaults (from input.rb)
      data.keyboard_input_defaults = Forked.keyboard_input_defaults
      data.controller_input_defaults = Forked.controller_input_defaults

      data.selected_option = -1 # set the current selection to no selection
      data.mouse_cursor = :arrow # set the default cursor

      data.defaults_set = true # and don't come back
    end

    ########
    # THEMES
    ########

    def apply_theme(theme)
      # "==== apply_theme(#{theme})"
      theme ||= {}

      data.style = config_defaults

      theme = theme.theme if theme.is_a?(Module)

      theme.each do |k, v|
        next unless data.style[k]

        data.style[k].merge!(v)
      end

      # TODO: this line might not be needed (seems like it's there
      # to ensure the current selection is highlighted after navigation)
      highlight_selected_option
    end

    #######################
    # PLAYER INPUT HANDLING
    #######################

    ### GET INPUT

    def input
      update_selection
      return if data.options.nil? || data.options.empty?

      if check_keyboard_activation_end ||
         check_controller_activation_end ||
         check_mouse_activation_end

        activate_selected_option
      end
    end

    ### UPDATE SELECTION

    def update_selection(navigated = nil)
      return if data.options.nil? || data.options.empty?

      # check whether input is selecting a button
      select = check_button_selected

      # did we come here from a navigation command?
      # deselect the buttons (the selection is not valid)
      # and return the cursor to arrow
      # otherwise, maintain the same selection (we just executed some code)
      if navigated
        data.selected_option = -1
        next_cursor = :arrow
      end

      # check whether input is activating a button
      activating = true if data.selected_option != -1 && check_activation_start

      # check whether input is deactivating a button
      deactivating = data.selected_option != -1 && check_activation_end

      # button is deactivating? (e.g. key/controller/mouse released)
      # revert to selection highlighting

      highlight_selected_option if deactivating && data.selected_option >= 0

      # check whether input is deactivating a button
      # clicked = true if data.selected_option != -1 && check_activation_end

      if select
        unhighlight_selected_option if data.selected_option >= 0
        data.selected_option = select
        highlight_selected_option if data.selected_option >= 0
        if inputs.last_active == :mouse
          next_cursor = if data.selected_option >= 0
                          # try to change to the hand cursor
                          :hand
                        else
                          # try to change to the arrow cursor
                          :arrow
                        end
        end
      end

      # player clicked the button
      highlight_active_option if activating

      highlight_active_option if select != -1 && check_activation

      # set the cursor when it has changed
      if next_cursor && next_cursor != data.mouse_cursor
        gtk.set_system_cursor(next_cursor)
        data.mouse_cursor = next_cursor
      end
    end

    ### CHECKS

    def check_button_selected
      case inputs.last_active
      when :keyboard
        get_keyboard_selection
      when :controller
        get_controller_selection
      when :mouse
        get_mouse_selection
      end
    end

    def check_activation_start
      case inputs.last_active
      when :keyboard
        check_keyboard_activation_start
      when :controller
        check_controller_activation_start
      when :mouse
        check_mouse_activation_start
      end
    end

    def check_activation
      case inputs.last_active
      when :keyboard
        check_keyboard_activation
      when :controller
        check_controller_activation
      when :mouse
        check_mouse_activation
      end
    end

    def check_activation_end
      case inputs.last_active
      when :keyboard
        check_keyboard_activation_end
      when :controller
        check_controller_activation_end
      when :mouse
        check_mouse_activation_end
      end
    end

    def check_keyboard_activation_start
      kd = inputs.keyboard.key_down
      data.keyboard_input_defaults[:activate].any? { |k| kd.send(k) }
    end

    def check_keyboard_activation
      kh = inputs.keyboard.key_held
      data.keyboard_input_defaults[:activate].any? { |k| kh.send(k) }
    end

    def check_keyboard_activation_end
      ku = inputs.keyboard.key_up
      data.keyboard_input_defaults[:activate].any? { |k| ku.send(k) }
    end

    def check_controller_activation_start
      c1 = inputs.controller_one
      data.controller_input_defaults[:activate].any? { |k| c1.key_down.send(k) } if c1.connected
    end

    def check_controller_activation
      c1 = inputs.controller_one
      data.controller_input_defaults[:activate].any? { |k| c1.key_held.send(k) } if c1.connected
    end

    def check_controller_activation_end
      c1 = inputs.controller_one

      data.controller_input_defaults[:activate].any? { |k| c1.key_up.send(k) } if c1.connected
    end

    def check_mouse_activation_start
      inputs.mouse.down
    end

    def check_mouse_activation
      inputs.mouse.held
    end

    def check_mouse_activation_end
      inputs.mouse.up
    end

    ### GET PLAYER SELECTION

    def get_mouse_selection
      rollover = -1
      data.options.each_with_index do |option, idx|
        next if option.action.empty?

        if option.intersect_rect?(inputs.mouse.point)
          rollover = idx
          break
        end
      end

      rollover if rollover != data.selected_option
    end

    def get_keyboard_selection
      kd = inputs.keyboard.key_down

      if data.keyboard_input_defaults[:next].any? { |k| kd.send(k) }
        return relative_to_absolute_selection(1)
      elsif data.keyboard_input_defaults[:prev].any? { |k| kd.send(k) }
        return relative_to_absolute_selection(-1)
      end

      nil
    end

    def get_controller_selection
      c1 = inputs.controller_one

      if c1.connected
        if data.controller_input_defaults[:next].any? { |k| c1.key_down.send(k) }
          return relative_to_absolute_selection(1)
        elsif data.controller_input_defaults[:prev].any? { |k| c1.key_down.send(k) }
          return relative_to_absolute_selection(-1)
        end
      end

      nil
    end

    ### DISPLAY SELECTION CHANGES

    def highlight_selected_option
      return unless data.options && data.selected_option && data.selected_option >= 0

      opt = data.options[data.selected_option]
      return unless opt

      opt.force_status_change(:focused)
    end

    def unhighlight_selected_option
      return unless data.selected_option >= 0

      return if data.selected_option >= data.options.count

      data.options[data.selected_option].force_status_change(:enabled)
    end

    def highlight_active_option
      return unless data.options && data.selected_option && data.selected_option >= 0

      opt = data.options[data.selected_option]
      return unless opt

      opt.force_status_change(:active)
    end

    ### PERFORM OPTION

    def activate_selected_option
      return unless data.selected_option >= 0

      $story.follow(args, data.options[data.selected_option])
    end

    ### HELPER

    def relative_to_absolute_selection(index)
      sel_opt = data.selected_option
      if data.selected_option.negative? || data.selected_option.nil?
        sel_opt = index.positive? ? data.options.size - 1 : 0
      end
      sel_opt += index
      sel_opt.clamp_wrap(0, data.options.size - 1)
    end

    ################
    # UPDATE DISPLAY
    ################

    def update(content, navigated)
      update_selection(navigated)

      data.primitives = []
      data.options = []

      y_pos = data.style.display.margin_top.from_top
      next_y_pos = y_pos

      content.each_with_index do |item, i|
        previous_element_type = content[i - 1][:type]
        @last_element_type = content[i - 1][:type]
        @last_printed_element_type ||= :none

        case item[:type]
        when :heading
          next_y_pos = display_heading(y_pos, item, previous_element_type)
        when :rule
          next_y_pos = display_rule(y_pos, item, previous_element_type)
        when :paragraph
          next_y_pos = display_paragraph(y_pos, item)
        when :code_block
          next_y_pos = display_code_block(y_pos, item, previous_element_type)
        when :blockquote
          # next_y_pos = display_blockquote(y_pos, item, previous_element_type, content, i)
          next_y_pos = display_blockquote(y_pos, item)
        when :button
          next_y_pos = display_button(y_pos, item, content, i)
          highlight_selected_option
        when :image
          next_y_pos = display_image(y_pos, item)
        when :blank
          # nothing
        end

        if !(next_y_pos - y_pos).zero? ||
           item[:type] == :blank
          @last_printed_element_type = item[:type]
        end
        y_pos = next_y_pos
      end
    end

    #######################
    # DISPLAY ELEMENT TYPES
    #######################

    ### BUTTON
    # TODO: prevent buttons from being instantiated if object already exists
    # TODO: wrap up button generation code and put it in the button module
    def display_button(y_pos, item, _content, __i)
      button = data.style.button
      display = data.style.display
      button_box = data.style.button_box

      button.size_px = args.gtk.calcstringbox('X', button.size_enum, button.font)[1]

      # previous element is also a button? use spacing_between instead of spacing_after
      if @last_printed_element_type == :button
        y_pos += button.spacing_after * button.size_px
        y_pos -= button.spacing_between * button.size_px
      end

      if item.action.empty?
        button = data.style.disabled_button
        button_box = data.style.disabled_button_box
      end

 
      text_w, button.size_px = args.gtk.calcstringbox(item.text, button.size_enum, button.font)
      text_w = text_w.to_i
      button_h = (button.size_px + button_box.padding_top + button_box.padding_bottom)

      x = display.margin_left
      y = (y_pos - button_h).to_i
      w = text_w + button_box.padding_left + button_box.padding_right
      h = (button.size_px + button_box.padding_top + button_box.padding_bottom).to_i

      pill_button_base = { x: x, y: y, w: w, h: h, text: item.text, action: item.action }

      enabled = Effed.pill_button_layer(
        args,
        rect: pill_button_base,
        color: { r: button.r, g: button.g, b: button.b, a: button.a || 255 },
        bg: { r: button_box.r, g: button_box.g, b: button_box.b, a: button.a || 255 },
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
          r: data.style.selected_button_box.r,
          g: data.style.selected_button_box.g,
          b: data.style.selected_button_box.b,
          a: data.style.selected_button_box.a || 255
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
          r: data.style.active_button_box.r,
          g: data.style.active_button_box.g,
          b: data.style.active_button_box.b,
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
          r: data.style.disabled_button_box.r,
          g: data.style.disabled_button_box.g,
          b: data.style.disabled_button_box.b,
          a: data.style.disabled_button_box.a || 255
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

      data.options << option if item&.action && !item.action.empty?
      data.primitives << option

      y_pos - (button_box.padding_top +
               button_box.padding_bottom +
               button.size_px +
               button.size_px * button.spacing_after)
    end

    ### HEADING

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

    ### RULE

    def display_rule(y_pos, item, _previous_element_type)
      rule = data.style.rule
      display = data.style.display
      weight = rule.weight
      weight = item.weight if item.weight

      data.primitives << {
        x: display.margin_left,
        y: y_pos.to_i,
        w: display.w,
        h: weight
      }.sprite!(rule)

      y_pos - rule.spacing_after
    end

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

    ### CODE BLOCK

    def display_code_block(y_pos, item, _previous_element_type)
      code_block = data.style.code_block
      display = data.style.display
      code_block_box = data.style.code_block_box

      text_array = wrap_lines_code_block(
        item.text, code_block.font, code_block.size_enum,
        display.w - (code_block_box.padding_left + code_block_box.padding_right)
      )
      code_block.size_px = args.gtk.calcstringbox('X', code_block.size_enum, code_block.font)[1]

      box_height = text_array.count * (code_block.size_px * code_block.line_spacing) +
                   code_block_box.padding_top + code_block_box.padding_bottom

      temp_y_pos = y_pos

      rect = {
        x: display.margin_left, 
        y: y_pos - box_height.to_i, 
        w: display.w, h: box_height,
        r: code_block_box.r,
        g: code_block_box.g,
        b: code_block_box.b
      }
      bg = Effed.rounded_panel(rect: rect)
      data.primitives << bg

      temp_y_pos -= code_block_box.padding_top
      data.primitives << text_array.map do |line|
        label = {
          x: display.margin_left + code_block_box.padding_left,
          y: temp_y_pos.to_i,
          text: line
        }.label!(code_block)

        temp_y_pos -= code_block.size_px * code_block.line_spacing

        label
      end

      y_pos -= box_height
      # y_pos - code_block.size_px * code_block.spacing_after
      y_pos -= code_block_box.margin_bottom
    end

    ################
    # STYLE HANDLING
    ################

    def get_font_style(styles)
      if styles.include?(:bold) && styles.include?(:italic)
        data.style.bold_italic
      elsif styles.include? :bold_italic
        data.style.bold_italic
      elsif styles.include? :bold
        data.style.bold
      elsif styles.include? :italic
        data.style.italic
      elsif styles.include? :code
        data.style.code
      else
        data.style.paragraph
      end
    end

    ############
    # PRIMITIVES
    ############



    ###############
    # TEXT HANDLING
    ###############

    def wrap_lines_code_block(str, font, size_px, width)
      wrapped_text = []
      str.lines.map do |l|
        l += ' ' # <== It's a hack :)
        fixed_width_line = ''
        frag = ''
        sp = 0 # index of first space
        while sp
          sp = l.index(' ')
          if sp
            if sp.zero?
              # space is the first character?
              # check width of line so far (fixed_width_line + frag)
              test_w = args.gtk.calcstringbox(fixed_width_line + frag, size_px, font)[0]
              # we're still inside the boundary?
              if test_w < width
                # add the current fragment to the line
                fixed_width_line += frag
                # add the current character (a space) to the line
                frag = ' '
              else # the next frag will push us over the line so soft wrap
                wrapped_text << fixed_width_line

                # empty the line and add the non-fitting frag to it
                fixed_width_line = frag.delete_prefix!(' ')
                # empty the frag but add a space
                frag = ' '
              end

              # empty frag and add a space

              # All hell will break loose if this line is removed
              # removes the found space, whether or not if goes in the
              # current soft line
              l.delete_prefix!(' ')

            else # space is not the first character. Add the previous word to frag
              ret = l.slice!(0, sp)
              frag += ret
            end
          else # there are no more spaces left in this line
            # add the remnant to frag
            frag += l
            # at the end of the line so add it to fwl
            fixed_width_line += frag
            # and add that to the wrapped text array
            wrapped_text << fixed_width_line
          end
        end
      end

      wrapped_text
    end

    def wrap_lines_code_block_slow(str, font, size_px, width)
      wrapped_text = []
      str.lines.map do |l|
        fixed_width_line = ''

        c = 0
        frag = ''
        while c < l.length

          if l.chars[c] == ' '
            # check w of frag + fixed_width_line
            test_w = args.gtk.calcstringbox(fixed_width_line + frag, size_px, font)[0]
            # if it fits display w

            if test_w < width
              # add frag to line
              fixed_width_line += frag
              # empty frag and add the matched space
              frag = ' '
            else # the line is too long to add the frag
              # add the line to the wrapped text array

              wrapped_text << fixed_width_line
              # empty the line and add the non-fitting frag to it
              fixed_width_line = frag
              # empty the frag
              frag = ' '
            end
          else # any character that is not a space
            # add char to frag
            frag += l.chars[c]
          end

          # we got to the end of the line
          if c == l.length - 1
            fixed_width_line += frag
            wrapped_text << fixed_width_line
          end
          c += 1
        end
      end

      # TODO: Small wrinkle with this code: a word can happily sit at the end of a line
      # but when another word is added after, the word will shift to the next line.
      # This might be due to the word having a space added to the width calculation?
      wrapped_text
    end

    def wrap_lines(str, font, size_px, width)
      wrapped_text = []
      str.lines.map do |l|
        fixed_width_line = ''

        words = l.strip.split(" ")

        until words.empty?
          line_next = fixed_width_line + words[0]
          if args.gtk.calcstringbox(line_next, size_px, font)[0] < width
            fixed_width_line = line_next + ' '
            words.shift
          else
            wrapped_text << fixed_width_line
            fixed_width_line = ''
          end

          wrapped_text << fixed_width_line if words.empty?
        end
      end

      wrapped_text
    end

    ## split string (str) on space
    ## preserve a maximum of one consecutive space
    def split_preserve_one_space(str)
      arr = []
      while str.length > 0
        if (idx = str.index(' '))
          capture = str[0...idx + 1]
          # prevent runs of spaces
          arr << capture unless capture == ' ' && arr[-1]&.end_with?(" ")
          str = str [idx + 1..-1]
        else
          # the string does not or no longer contains a space
          arr << str
          str = ''
        end
      end
      arr
    end

    ## split string (str) on space
    ## preserve spaces
    def split_preserve_space(str)
      arr = []
      while str.length > 0
        idx = str.index(' ')
        if idx
          cap = str[0...idx + 1]
          arr << cap
          str = str [idx + 1..-1]
        else
          arr << str
          str = ''
        end
      end
      arr
    end

    ########
    # RENDER
    ########

    def render
      outputs.background_color = data.style.display.background_color.values
      args.outputs.primitives << data.primitives
    end
  end
end
