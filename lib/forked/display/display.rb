require_relative 'display_interaction'
require_relative 'display_text'
require_relative 'display_background'
require_relative 'display_blockquote'
require_relative 'display_button'
require_relative 'display_code_block'
require_relative 'display_heading'
require_relative 'display_image'
require_relative 'display_paragraph'
require_relative 'display_rule'
require_relative 'display_callout'

$gtk.reset

module Forked
  # Display class
  class Display
    attr_gtk

    def initialize(theme = nil)
      # "==== def initialize(theme = nil)"
      # set the current theme if passed
      @theme = theme

      @mouse_down_handled = false
      @mouse_up_handled = false

      init_scrolling
    end

    def tick
      defaults unless data.defaults_set
      input
      render

      @mouse_down_handled = false
      @mouse_up_handled = false
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
      data.previous_selected_option = -1
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
        if data.style[k]
          data.style[k].merge!(v)
        else
          data.style[k] = v
        end
      end

      # TODO: this line might not be needed (seems like it's there
      # to ensure the current selection is highlighted after navigation)
      highlight_selected_option
    end

    ### UPDATE SELECTION

    def update_selection(navigated = nil)
      return if @roll_handled
      return if data.options.nil? || data.options.empty?

      # "==== def update_selection(navigated = nil)"

      # check whether input is selecting a button
      select = check_button_selected

      # did we come here from a navigation command?
      # deselect the buttons (the selection is not valid)
      # and return the cursor to arrow
      # otherwise, maintain the same selection (we just executed some code)
      if navigated
        data.selected_option = -1
        data.previous_selected_option = -1
        next_cursor = :arrow
      end

      # check whether input is activating a button
      as = check_activation_start
      activating = true if data.selected_option != -1 && as

      # check whether input is deactivating a button
      deactivating = data.selected_option != -1 && check_activation_end

      # button is deactivating? (e.g. key/controller/mouse released)
      # revert to selection highlighting

      highlight_selected_option if deactivating && data.selected_option >= 0

      # check whether input is deactivating a button
      # clicked = true if data.selected_option != -1 && check_activation_end

      if select && !navigated
        unhighlight_selected_option if data.selected_option >= 0
        if data.selected_option >= 0
          data.previous_selected_option = data.selected_option
          # putz "previous selected option #{data.previous_selected_option}"
        end
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

    def relative_to_absolute_selection(index, continuous: true)
      # "==== def relative_to_absolute_selection(#{index} continuous: #{continuous})"
      sel_opt = data.selected_option == -1 ? data.previous_selected_option : data.selected_option
      if continuous
        if (sel_opt.negative? || sel_opt.nil?)
          sel_opt = index.positive? ? data.options.size - 1 : 0
        end
      end
      sel_opt += index
      sel_opt.clamp_wrap(0, data.options.size - 1)
    end

    ################
    # UPDATE DISPLAY
    ################

    def update(content, navigated)
      # "==== def update(content, navigated) | #{Kernel.tick_count} | caller: #{caller}"
      update_selection(navigated)

      reset_scroll if navigated

      data.primitives = []
      data.options = []

      ### Add @scroll_offset to y_pos to scroll all elements
      y_pos = data.style.display.margin_top.from_top + @scroll_offset

      original_y_pos = 600
      next_y_pos = y_pos
      height = data.style.display.margin_top

      content.each_with_index do |item, i|
        previous_element_type = content[i - 1][:type]
        @last_element_type = content[i - 1][:type]
        @last_printed_element_type ||= :none

        case item[:type]
        when :heading
          next_y_pos = display_heading(y_pos, item, previous_element_type)
          height += y_pos - next_y_pos
        when :rule
          next_y_pos = display_rule(y_pos, item, previous_element_type)
          height += y_pos - next_y_pos
        when :paragraph
          next_y_pos = display_paragraph(y_pos, item)
          height += y_pos - next_y_pos
        when :code_block
          next_y_pos = display_code_block(y_pos, item, previous_element_type)
          height += y_pos - next_y_pos
        when :blockquote
          next_y_pos = display_blockquote(y_pos, item)
          height += y_pos - next_y_pos
        when :trigger, :button
          next_y_pos = display_button(y_pos, item, content, i)
          height += y_pos - next_y_pos
          highlight_selected_option
        when :image
          next_y_pos = display_image(y_pos, item)
          height += y_pos - next_y_pos
        when :blank
          # nothing
        when :hidden
          # nothing
        when :callout
          next_y_pos = display_callout(y_pos, item)
          height += y_pos - next_y_pos
        when :callout_menu
          next_y_pos = display_callout_menu(y_pos, item)
          height += y_pos - next_y_pos
        when :carousel_menu
          next_y_pos = display_carousel_menu(y_pos, item)
          height += y_pos - next_y_pos
        else
          # this might be a custom block, check it
          next_y_pos = display_custom_block(y_pos, item)
          # if it's not a registered custom block, it will return nil
          raise "Unexpected item type: #{item.type}" unless next_y_pos

          height += y_pos - next_y_pos
        end

        if !(next_y_pos - y_pos).zero? ||
           item[:type] == :blank
          @last_printed_element_type = item[:type]
        end

        @scroll_max = -next_y_pos
        y_pos = next_y_pos
      end

      @scroll_height = height
    end

    def update_old_20250529(content, navigated)
      update_selection(navigated)

      reset_scroll if navigated

      data.primitives = []
      data.options = []

      ### Add @scroll_offset to y_pos to scroll all elements
      y_pos = data.style.display.margin_top.from_top + @scroll_offset

      original_y_pos = 600
      next_y_pos = y_pos
      height = data.style.display.margin_top

      content.each_with_index do |item, i|
        previous_element_type = content[i - 1][:type]
        @last_element_type = content[i - 1][:type]
        @last_printed_element_type ||= :none

        case item[:type]
        when :heading
          next_y_pos = display_heading(y_pos, item, previous_element_type)
          height += y_pos - next_y_pos
        when :rule
          next_y_pos = display_rule(y_pos, item, previous_element_type)
          height += y_pos - next_y_pos
        when :paragraph
          next_y_pos = display_paragraph(y_pos, item)
          height += y_pos - next_y_pos
        when :code_block
          next_y_pos = display_code_block(y_pos, item, previous_element_type)
          height += y_pos - next_y_pos
        when :blockquote
          # next_y_pos = display_blockquote(y_pos, item, previous_element_type, content, i)
          next_y_pos = display_blockquote(y_pos, item)
          height += y_pos - next_y_pos
        when :trigger, :button
          next_y_pos = display_button(y_pos, item, content, i)
          height += y_pos - next_y_pos
          highlight_selected_option
        when :image
          next_y_pos = display_image(y_pos, item)
          height += y_pos - next_y_pos
        when :blank
          # nothing
        when :hidden
          # nothing
        when :callout
          next_y_pos = display_callout(y_pos, item)
          height += y_pos - next_y_pos
        when :callout_menu
          next_y_pos = display_callout_menu(y_pos, item)
          height += y_pos - next_y_pos
        when :carousel_menu
          next_y_pos = display_carousel_menu(y_pos, item)
          height += y_pos - next_y_pos
        else
          raise "Unexpected item type: #{item.type}"
        end

        if !(next_y_pos - y_pos).zero? ||
           item[:type] == :blank
          @last_printed_element_type = item[:type]
        end

        @scroll_max = -next_y_pos # + @scroll_offset
        y_pos = next_y_pos
      end

      @scroll_height = height
    end

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

    def center_row row, row_w, rect
      rect_mid = rect.w / 2
      row_mid = row_w / 2
      row.each do |r|
        r.x += rect_mid - row_mid
      end
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

    def size_enum_to_size_px(size_enum)
      size_enum * 2 + 22
    end

    # converts label size_px to size_enum
    # rounds down (so size_px 22 and 23 are bothe size_enum 0)
    def size_px_to_size_enum(size_px)
      (size_px - 22).div(2)
    end

    def calc_element_rects(y_pos, style)
      display_rect = calc_display_rect
      outer_rect = calc_outer_rect(display_rect, y_pos, style)
      element_rect = calc_element_rect(outer_rect, style)
      inner_rect = calc_inner_rect(element_rect, style)

      {
        display: display_rect,
        outer: outer_rect,
        element: element_rect,
        inner: inner_rect
      }
    end

    def calc_display_rect
      display = data.style.display
      {
        x: display.margin_left,
        y: display.margin_bottom,
        w: display.w,
        h: display.h
      }
    end

    def calc_outer_rect(display_rect, y_pos, style)
      display = data.display.style
      h = (style.margin_top || 0) + (style.margin_bottom || 0)
      {
        top: y_pos,
        x: display_rect.x,
        w: display_rect.w,
        h: h,
        y: y_pos - h
      }
    end

    def calc_element_rect(outer_rect, style)
      style = {
        **default_box,
        **style
      }
      top = (outer_rect.top || 0) - (style.margin_top || 0)
      h = style.padding_top + style.padding_bottom
      {
        top: top,
        x: outer_rect.x + style.margin_left,
        w: outer_rect.w - style.margin_left - style.margin_right,
        h: h,
        y: top - h
      }
    end

    def calc_inner_rect(element_rect, style)
      style = {
        **default_box,
        **style
      }
      top = element_rect.top - style.padding_top
      h = 0
      {
        top: top,
        x: element_rect.x + style.padding_left,
        h: h,
        y: top - h,
        w: element_rect.w - style.padding_left - style.padding_right,
      }
    end


    ########
    # RENDER
    ########

    def render
      background = data.style.background
      if background.path
        outputs.sprites << {
          **background.sprite!
        }
      elsif background.background_color
        outputs.background_color = background.background_color
      end
      args.outputs.primitives << data.primitives
    end
  end
end
