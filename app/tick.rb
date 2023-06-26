
def tick args
  defaults args unless args.state.defaults_set
  input args
  calc args
  render args

  args.gtk.reset_next_tick if args.inputs.keyboard.key_down.backspace
end

def defaults args
  args.state.display_margin_x = 20
  args.state.display_margin_y = 20
  args.state.display_w = 600
  args.state.line_height = 26

  args.state.story = Forking::Story.instance.compile

  args.state.root_node = args.state.story[:content][0]
  args.state.title = args.state.story[:title]

  args.state.current_node = args.state.root_node
  args.state.current_heading = args.state.current_node[:heading] || ""
  args.state.current_description = carve args, args.state.current_node[:description]

  args.state.current_choices = args.state.current_node[:choices]
  args.state.options = []

  args.state.defaults_set = true
end

def input args
  return if args.state.options.empty?

  args.state.options.each do |o|
    if o.intersect_rect? args.inputs.mouse.point
      follow args, o if args.inputs.click
      rollover args, o
    end
  end
end

def calc args

end

def follow args, option
  args.state.current_node = args.state.story.content.select { |k| k[:id] == option.action}[0]
  args.state.current_description = carve args, args.state.current_node[:description]
  args.state.current_choices = args.state.current_node[:choices] || []
  args.state.options = []
  args.state.current_heading = args.state.current_node[:heading] || ""
end

def carve args, txt
  paragraphs = txt.split "\n"
  lines = []

  paragraphs.each do |para|
    words = para.split ' '
    line = ''

    until words.empty?
      new_line = line + words[0]

      if calcstringwidth(new_line) > args.state.display_w
        lines << line
        line = new_line = ''
      end

      line += words.delete_at(0) + ' '
      lines << line if words.size.zero?
    end
    lines << "" if line.size.zero?
  end

  lines
end

def rollover args, rect
  args.outputs.primitives << rect.solid!(r: 255)
end

def render args
  line_height = args.state.line_height
  y_position = args.state.display_margin_y.from_top

  labels = []
  labels << {
    x: 20, y: y_position,
    text: args.state.current_heading,
    vertical_alignment_enum: 2
  }

  y_position -= line_height

  labels << args.state.current_description.map do |line|
    y_position -= line_height
    {
      x: 20, y: y_position,
      text: line,
      vertical_alignment_enum: 2
    }
  end

  y_position -= line_height * 0.5

  unless args.state.current_choices.empty?
    args.state.options = []

    args.state.current_choices.each do |o|
      opt_text = " -> #{o.choice}"
      box = args.gtk.calcstringbox opt_text
      y_position -= line_height * 1.5

      args.state.options << {
        x: args.state.display_margin_x,
        y: y_position - line_height + 2,
        w: box[0] + 5,
        h: line_height,
        action: o.destination
      }

      labels << {
        x: args.state.display_margin_x,
        y: y_position,
        text: opt_text,
        vertical_alignment_enum: 2,
        r: 255, g: 255, b: 255
      }
    end

    args.outputs.solids << args.state.options
  end

  args.outputs.labels << labels
end

def calcstringwidth str
  $gtk.calcstringbox(str)[0]
end
