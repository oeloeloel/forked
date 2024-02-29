module Forked
  class Author
    attr_gtk

    AUTHOR_MODE_TEXT_STYLE = {
      font: 'fonts/roboto_mono/static/robotomono-regular.ttf',
      r: 0, g: 0, b: 76,
      size_px: 18,
    }

    def initialize(story)
      @story = story
    end

    def tick
      defaults unless args.state.forked.defaults_set
      check_inputs
      calc
      render
    end

    def defaults
      args.state.forked.author_mode = false
    end

    def check_inputs
      return unless args.state.forked.author_mode

      # keyboard shortcuts

      k_d = args.inputs.keyboard.key_down
      k_h = args.inputs.keyboard.key_held

      fall_key = :n
      rise_key = :h
      left_sidebar_key = :q
      @story.jump(1) if k_d.send(fall_key)
      @story.jump(-1) if k_d.send(rise_key)
      args.state.forked.author_mode_sidebar = k_h.send(left_sidebar_key)
    end

    def calc
      return unless args.state.forked.author_mode

      am_prims = [
        # author mode indicator
        {x: 0, y: 0, w: 10, h: 10, r: 255, g: 0, b: 0}.sprite!
      ]

      # left sidebar
      if args.state.forked.author_mode_sidebar

        # background
        am_prims << {x: 0, y: 0, w: 640, h: 720, a: 155}.sprite!

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
          'hold q: open the Author Mode Sidebar',
          '',
        ]

        hist = $story.history_get.reverse

        am_labels += [
        "Navigation History (#{hist.size})",
          "------------------"
        ]

        am_labels += hist[0..10].map_with_index { |h, i|
          
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

        am_labels += $story.bag.map_with_index { |h| h }

        y_loc = 0

        am_prims += am_labels.map_with_index do |text, i|
          prim = { 
            x: 1, y: y_loc.from_top,
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