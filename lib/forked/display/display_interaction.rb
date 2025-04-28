module Forked
  class Display
    attr_accessor :bg_clicked, :mouse_up_handled, :mouse_down_handled, :scroll_handled, :roll_handled

    ### INPUT HANDLING

    def input
      # "==== def input"
      scroll_step_to_target
      mouse_scroll
      autoscroll
      @bg_clicked = click_on_bg

      calc_double_click

      if @bg_clicked
        if @double_clicked
          @autoscroll_step = 1.5
        else
          @autoscroll_step = 4
        end
      end

      return if data.options.nil? || data.options.empty?

      if check_mouse_activation_end || check_keyboard_activation_end || check_controller_activation_end
        activate_selected_option
      end

      @mouse_up_handled = false
    end

    def double_click?
      @double_clicked
    end

    def calc_double_click
      delay = 20 # ticks
      @double_clicked = false
      # has the mouse been pressed?
      if args.inputs.mouse.down
        # has the mouse been pressed within a short time of the first press
        # register a possible double click
        if Kernel.global_tick_count - (inputs.mouse.previous_click&.global_created_at || 0) <= delay
          @mouse_double_pressed = true
        else
          @mouse_double_pressed = false
        end
      end
      # has the mouse been released?
      if args.inputs.mouse.up
        if @mouse_double_pressed
          @double_clicked = true
          return true
        end
      end

      nil
    end

    def click_on_bg
      result = false
      if args.inputs.mouse.down && !@mouse_down_handled
        @mouse_down_on_bg = true
      elsif args.inputs.mouse.up
        mouse_up_on_bg = true if !@mouse_up_handled
        result = @mouse_down_on_bg && mouse_up_on_bg ? true : false
        @mouse_down_on_bg = false
      end
      result
    end

    ### END OF INPUT HANDLING

    


    def init_scrolling
      # "==== def init_scrolling"
      @scroll_bottom = 0 # not used?
      @last_scroll_cause = :player # or :story. Indicates need for autoscrolling
      @scroll_min ||= 0 # minimum scroll height
      @scroll_max ||= 0 # maximum scroll height - set in display update
      @scroll_offset ||= 0 # scroll height
      @scroll_target = 0
      @scroll_vel ||= 0 # velocity of scrolling
      @scroll_speed = 10 # used to increase scroll velocity
      @scroll_friction = 0.8 # used to slow scroll velocity
      @scroll_height = 0
      @autoscroll_step = 4
      @scroll_handled = false
      @rollover_handled = false
      @scroll_lines = 5
    end

    def reset_scroll
      @scroll_offset = 0
      @scroll_target = 0
    end

    def scroll_by(dist)
      # "==== def scroll_by #{dist}"
      @scroll_target -= dist
      @scroll_target = @scroll_target.clamp(@scroll_min, @scroll_max)
    end

    def calc_scroll_by_row_amount(rows)
      para = data.style.paragraph
      para.size_px = size_enum_to_size_px(para.size_enum)
      line_height = para.size_px * para.line_spacing
      line_height * rows
    end

    def calc_scroll_by_screen_amount
      args.grid.h - 120
    end

    def scroll_by_row(n)
      para = data.style.paragraph
      line_height = para.size_px * para.line_spacing
      scroll_dist = line_height * n
      @scroll_target -= scroll_dist
      @scroll_target = @scroll_target.clamp(@scroll_min, @scroll_max)
    end

    def scroll_to_top
      @scroll_target = 0
    end

    def scroll_to_bottom
      @scroll_target = @scroll_max
    end

    # automatically scrolls to @scroll_target
    def scroll_step_to_target
      diff = -(@scroll_offset - @scroll_target)
      @scroll_offset += diff / @autoscroll_step 
    end

    def mouse_scroll
      # "==== def mouse_scroll"
      return if @scroll_handled

      @last_scroll_cause = :player if inputs.mouse.wheel # no to autoscrolling
      return unless @last_scroll_cause == :player

      calc_scroll_max
      scroll_accel = ($args.inputs.mouse.wheel&.y || 0) * @scroll_speed
      @scroll_vel -= scroll_accel
      @scroll_vel *= @scroll_friction
      @scroll_vel = 0 if @scroll_vel.abs < 0.01
      @scroll_target += @scroll_vel
      @scroll_target = @scroll_target.clamp(@scroll_min, @scroll_max)
    end

    def autoscroll
      return unless @last_scroll_cause == :story

      bottom = $top_of_the_bottom + 40
      scroll_area_height = 720 - bottom
      autoscroll_target = if @scroll_height < scroll_area_height
                            0
                          else
                            @scroll_height - scroll_area_height
                          end
      diff = -(@scroll_offset - autoscroll_target)
      @scroll_offset += diff / @autoscroll_step
    end

    def calc_scroll_max
      @scroll_max += @scroll_offset + ($top_of_the_bottom || 0) + 40
      @scroll_max = @scroll_max.clamp(0)
    end

    # never called
    # def calc_autoscroll
    #   # "==== calc_autoscroll #{caller}"
    #   @last_scroll_cause = :story # yes to autoscrolling
    # end

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
        result = check_mouse_activation_end
        @mouse_up_handled = false if result
        result
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
      return if @mouse_down_handled

      result = inputs.mouse.down
      @mouse_down_handled = true if result
      result
    end

    def check_mouse_activation
      inputs.mouse.held
    end

    def check_mouse_activation_end
      return if @mouse_up_handled

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

      rollover
    end
    
    def get_keyboard_selection
      kd = inputs.keyboard.key_down
      kh = inputs.keyboard.key_held

      # TODO

      # Bugging
      # navigation between pages must reset scroll

      # √ Cycle buttons: Tab/Shift-Tab
      # √ Cycle visible buttons: Left/Right Arrows
      # √ Scroll by lines: Up/Down Arrows
      # √ Pgup/Pgdn
      # Implement everything for controller
      # √ New file for display interactions (button handling, scrolling, etc)
      # Home/end

      # √ Cycle buttons:
      # √ Scroll to button (wraparound)
      # √ Return new buttons selection (always)

      # √ Cycle visible buttons
      # √ Select next visible button (wraparound)
      # √ WHAT IF NO BUTTONS ARE VISIBLE? No action, deselect
      # √ Return new button selection if not deselected

      # √ Scroll by lines
      # √ Scroll by 5 lines in direction
      # ? If current selection is not on-screen, deselect? Maybe not.

      # Pgup/Pgdn
      # √ scroll by almost one screen's height

      scroll_by_line_amount = calc_scroll_by_row_amount(@scroll_lines)
      scroll_by_page_amount = calc_scroll_by_screen_amount

      data.keyboard_input_defaults.each do |act, keys|
        keys.each do |key|
          if key.start_with?('shift_')
            mod = :shift
            key = key.to_s.split('_')[1].to_sym
          end

          next if !kd.send(key) ||
                  (mod && !kh.send(mod)) ||
                  (!mod && kh.shift)

          case act
          when :next
            # tab forward through all reachable buttons
            target = relative_to_absolute_selection(1)
            scroll_to_button(target)
            return target
          when :prev
            # tab backward through all reachable buttons
            target = relative_to_absolute_selection(-1)
            scroll_to_button(target)
            return target
          when :next_visible
            # cycle forward through all visible buttons
            visible_buttons = get_all_visible_buttons
            return if visible_buttons.empty?

            # use previously selected option if no selection
            if data.selected_option == -1
              data.selected_option = data.previous_selected_option
            end

            if data.selected_option == -1 ||
                data.selected_option < visible_buttons[0] ||
                data.selected_option > visible_buttons[-1]
              return visible_buttons[0]
            else
              selection_idx = visible_buttons.find_index(data.selected_option)
              next_selection_idx = (selection_idx + 1).clamp_wrap(0, visible_buttons.size - 1)
              next_selection = visible_buttons[next_selection_idx]
              return next_selection if rect_is_fully_onscreen?(data.options[next_selection]) 
            end
          when :prev_visible
            # cycle backward through all visible buttons
            visible_buttons = get_all_visible_buttons
            return if visible_buttons.empty?

            if data.selected_option == -1
              data.selected_option - data.previous_selected_option
            end

            if data.selected_option == -1 ||
                data.selected_option < visible_buttons[0] ||
                data.selected_option > visible_buttons[-1]
              return visible_buttons[-1]
            else
              selection_idx = visible_buttons.find_index(data.selected_option)
              next_selection_idx = (selection_idx - 1).clamp_wrap(0, visible_buttons.size - 1)
              next_selection = visible_buttons[next_selection_idx]
              return next_selection if rect_is_fully_onscreen?(data.options[next_selection])
            end
          when :up
            # scroll up by specified number of lines
            scroll_by_line_amount = calc_scroll_by_row_amount(@scroll_lines)
            scroll_by(scroll_by_line_amount)
          when :down
            # scroll down by specified number of lines
            scroll_by_line_amount = -1 * calc_scroll_by_row_amount(@scroll_lines)
            scroll_by(scroll_by_line_amount)
          when :page_up
            # scroll up by almost one screen
            scroll_by(scroll_by_page_amount)
          when :page_down
            # scroll down by almost one screen
            scroll_by(-scroll_by_page_amount)
          when :home
            scroll_to_top
          when :end
            scroll_to_bottom
          end
        end
      end

      nil
    end

    def get_all_visible_buttons
      data.options.map_with_index do |b, i| 
        i if b.inside_rect?(args.grid.rect)
      end.compact
    end

    def rect_is_fully_onscreen?(rect)
      rect.intersect_rect?(args.grid.rect)
    end

    def scroll_to_button(button_id)
      dist = button_scroll_dist(button_id)
      return if dist.zero?

      scroll_by(dist + 20 * dist.sign)
    end

    def button_scroll_dist(button)
      b = data.options[button]
      # how far below the bottom of the visible screen is the bottom of the button?
      return b.y if b.y < 0

      # how far above the top of the visible screen is the top of the button?
      dist = b.y + b.h - args.grid.h
      return dist if dist > 0

      # button is not off-screen
      return 0
    end

    def get_controller_selection
      # "==== def get_controller_selection"
      kd = inputs.controller_one.key_down

      scroll_by_line_amount = calc_scroll_by_row_amount(@scroll_lines)
      scroll_by_page_amount = calc_scroll_by_screen_amount

      data.controller_input_defaults.each do |act, keys|
        keys.each do |key|
         next if !kd.send(key)

         case act
         when :next
             # tab forward through all reachable buttons
             target = relative_to_absolute_selection(1)
             scroll_to_button(target)
             return target 
          when :prev
            # tab backward through all reachable buttons
            target = relative_to_absolute_selection(-1)
            scroll_to_button(target)
            return target
          when :next_visible
            # cycle forward through all visible buttons
            visible_buttons = get_all_visible_buttons
            return if visible_buttons.empty?

            # use previously selected option if no selection
            if data.selected_option == -1
              data.selected_option = data.previous_selected_option
            end

            if data.selected_option == -1 ||
                data.selected_option < visible_buttons[0] ||
                data.selected_option > visible_buttons[-1]
              return visible_buttons[0]
            else
              selection_idx = visible_buttons.find_index(data.selected_option)
              next_selection_idx = (selection_idx + 1).clamp_wrap(0, visible_buttons.size - 1)
              next_selection = visible_buttons[next_selection_idx]
              return next_selection if rect_is_fully_onscreen?(data.options[next_selection]) 
            end

          when :prev_visible
            # cycle backward through all visible buttons
            visible_buttons = get_all_visible_buttons
            return if visible_buttons.empty?

            if data.selected_option == -1
              data.selected_option - data.previous_selected_option
            end

            if data.selected_option == -1 ||
                data.selected_option < visible_buttons[0] ||
                data.selected_option > visible_buttons[-1]
              return visible_buttons[-1]
            else
              selection_idx = visible_buttons.find_index(data.selected_option)
              next_selection_idx = (selection_idx - 1).clamp_wrap(0, visible_buttons.size - 1)
              next_selection = visible_buttons[next_selection_idx]
              return next_selection if rect_is_fully_onscreen?(data.options[next_selection])
            end
          when :up
            # scroll up by specified number of lines
            scroll_by_line_amount = calc_scroll_by_row_amount(@scroll_lines)
            scroll_by(scroll_by_line_amount)
          when :down
            # scroll down by specified number of lines
            scroll_by_line_amount = -1 * calc_scroll_by_row_amount(@scroll_lines)
            scroll_by(scroll_by_line_amount)
          when :page_up
            # scroll up by almost one screen
            scroll_by(scroll_by_page_amount)
          when :page_down
            # scroll down by almost one screen
            scroll_by(-scroll_by_page_amount)
          when :home
            scroll_to_top
          when :end
            scroll_to_bottom
          end
        end
      end

    

      # if c1.connected
      #   if data.controller_input_defaults[:next].any? { |k| c1.key_down.send(k) }
      #     return relative_to_absolute_selection(1)
      #   elsif data.controller_input_defaults[:prev].any? { |k| c1.key_down.send(k) }
      #     return relative_to_absolute_selection(-1)
      #   end
      # end

      nil
    end
  end
end