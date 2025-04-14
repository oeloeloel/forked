module Forked
  # Forked display class
  class Display
    attr_accessor :scroll_handled, :roll_handled
    ###

    def init_scrolling
      puts "==== def init_scrolling"
      @scroll_bottom = 0
      @last_scroll_cause = :player # or :story. Indicates need for autoscrolling
      @scroll_min ||= 0 # minimum scroll height
      @scroll_max ||= 0 # maximum scroll height - set in display update
      @scroll_offset ||= 0 # scroll height
      @scroll_vel ||= 0 # velocity of scrolling
      @scroll_speed = 10 # used to increase scroll velocity
      @scroll_friction = 0.8 # used to slow scroll velocity
      @scroll_height = 0
      @autoscroll_step = 4
      @scroll_handled = false
      @rollover_handled = false
    end

    def mouse_scroll
      puts "==== def mouse_scroll"
      putz "Scroll handleg? #{@scroll_handled}"
      return if @scroll_handled

      @last_scroll_cause = :player if inputs.mouse.wheel # no to autoscrolling
      return unless @last_scroll_cause == :player

      calc_scroll_max
      scroll_accel = ($args.inputs.mouse.wheel&.y || 0) * @scroll_speed
      @scroll_vel -= scroll_accel
      @scroll_vel *= @scroll_friction
      @scroll_vel = 0 if @scroll_vel.abs < 0.01
      @scroll_offset += @scroll_vel
      @scroll_offset = @scroll_offset.clamp(@scroll_min, @scroll_max)
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

    def calc_autoscroll
      # "==== calc_autoscroll #{caller}"
      @last_scroll_cause = :story # yes to autoscrolling
    end

    def input
      puts "==== def input"
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

    # check for double click
    # on macos
    # the double click is decided between the first and
    # second presses but the double click is activated
    # by the second release

    # TODO: double-click can be used with a background click like this:
    # if $story.display.bg_clicked && $story.display.double_click?
    # but this only checks to see if the second click was on the bg
    # if the first click is on a button or a menu
    # the second click should not register as a double click.
    # Theory: this could be fixed by adding a new method:
    # def was_clicked_on_bg
    # or add a new variable to track whether the previous click was on bg
    # second option maybe better


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
    ###
  end
end