class Author
  attr_gtk

  AUTHOR_MODE_TEXT_STYLE = {
    # font: 'fonts/Roboto/Roboto-Regular.ttf',
    font: 'fonts/Roboto_Mono/static/RobotoMono-Regular.ttf',
    r: 0, g: 0, b: 76,
    size_px: 18,
  }

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
    fall if k_d.send(fall_key)
    rise if k_d.send(rise_key)
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
        'Author Mode',
        '===========',
        "chunk id: #{args.state.forked.current_chunk[:id]}",
        "chunk heading: #{args.state.forked.current_chunk[:content][0].text}"
      ]

      y_loc = 0

      am_prims << am_labels.map_with_index do |text, i|
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
    args.outputs.primitives << args.state.forked.author_mode_primitives
  end
end