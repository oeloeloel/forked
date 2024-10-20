module Forked
  class Author
    attr_gtk

    AUTHOR_MODE_TEXT_STYLE = {
      font: 'fonts/roboto_mono/static/robotomono-regular.ttf',
      r: 11, g: 11, b: 11,
      size_px: 18,
    }

    def initialize(story)
      @story = story
      @sidebar_display_toggle = false
      @fps_toggle = false
    end

    def tick
      defaults unless args.state.forked.author_defaults_set
      check_inputs
      calc
      render
    end

    def defaults
      args.state.forked.author_mode = false
      define_keys

      args.state.forked.author_defaults_set = true
    end

    def define_keys
      @fall_key = :n
      @rise_key = :h
      @left_sidebar_key = :q
      @framerate_key = :d # for diagnostic 
      @orientation_toggle_key = :o
    end

    def check_inputs
      return unless args.state.forked.author_mode

      # keyboard shortcuts

      k_d = args.inputs.keyboard.key_down
      k_h = args.inputs.keyboard.key_held

      nav(1) if k_d.send(@fall_key)
      nav(-1) if k_d.send(@rise_key)

      @sidebar_display_toggle = !@sidebar_display_toggle if k_d.send(@left_sidebar_key)
      args.state.forked.author_mode_sidebar = @sidebar_display_toggle

      @fps_toggle = !@fps_toggle if k_d.send(@framerate_key)
      outputs.debug << "FPS: #{args.gtk.current_framerate_calc.round.to_s}(#{
      args.gtk.current_framerate.round.to_s})" if @fps_toggle

      if k_d.send(@orientation_toggle_key)
        $gtk.toggle_orientation
      end
    end

    def nav by
      @story.jump(by)
      @story.save_game if state.forked.defaults[:autosave]
    end

    def calc
      return unless args.state.forked.author_mode

      am_prims = [
        # author mode indicator
        {x: 0, y: 0, w: 10, h: 10, r: 255, g: 0, b: 0}.sprite!
      ]

      # right sidebar (formerly left sidebar)
      if args.state.forked.author_mode_sidebar

        # background
        am_prims << {x: args.grid.w / 2, y: 0, w: args.grid.w / 2, h: args.grid.h, r: 255, g: 222, b: 37, a: 225}.sprite!

        # labels
        am_labels = [
          'AUTHOR MODE',
          '===========',
          "current chunk id: #{args.state.forked.current_chunk[:id]}",
          "current chunk heading: #{args.state.forked.current_chunk[:content][0].text}",
          "",
          'Shortcuts',
          '---------',
          'hold f, press u: Toggle Author Mode on/off',
          'n: go to next chunk in story file',
          'h: go to previous chunk in story file',
          'q: toggle the Author Mode Sidebar',
          'hold d: display the current framerate',
          '',
        ]

        hist = $story.history_get.reverse

        am_labels += [
        "Navigation History (#{hist.size - 9}-#{hist.size}/#{hist.size})",
          "------------------"
        ]

        am_labels += hist[0...10].map_with_index { |h, i|
          str = ""
          str += "## #{h[2]} " if h[2]
          str += "{#{h[1]}}" if h[1]
          str
        }

        am_labels += [
          "",
          "Bag",
          "------------------",
        ]
        
        if $story.bag.empty?
          am_labels << "Nothing" 
        else
          am_labels += $story.bag.map_with_index { |h| h }
        end

        am_labels += [
          "",
          "Memos",
          "------------------", 
        ]
        
        if $story.memo.empty?
          am_labels << "None"
        else
          am_labels += $story.memo.map { |m| "#{m[0]}: #{m[1]}" }
        end


        am_labels += [
          "",
          "Counters",
          "------------------", 
        ]

        if $story.counter.empty?
          am_labels << "None"
        else
          am_labels += $story.counter.map { |c| "#{c[0]}: #{c[1]}" }
        end


        am_labels += [
          "",
          "Timers",
          "------------------", 
        ]

        if $story.timer.empty?
          am_labels << "None"
        else
          am_labels += $story.timer.map { |t|
            name = t[0]

            next "#{name}: Done" if $story.timer_done? name
            val  = $story.timer_check name
            sec  = $story.timer_seconds name
            "#{name}: #{sec} secs / #{val} ticks"
          }
        end

        am_labels += [
          "",
          "Wallet",
          "------------------",
        ]

        am_labels << "$" + $story.wallet.to_s
        
        y_loc = 0
        am_prims += am_labels.map_with_index do |text, i|
          prim = { 
            x: 2 + args.grid.w / 2, y: y_loc.from_top,
            text: text,
          }.label!(AUTHOR_MODE_TEXT_STYLE)
          y_loc += AUTHOR_MODE_TEXT_STYLE.size_px * 0.8

          prim
        end


      end

      args.state.forked.author_mode_primitives = am_prims
    end

    def render
      return unless args.state.forked.author_mode
      
      args.outputs.primitives << args.state.forked.author_mode_primitives
    end
  end
end