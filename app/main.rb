$gtk.reset

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

  args.state.story = fetch_story

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

def continue_story args

end

def follow args, option
  args.state.current_node = args.state.story.content.select { |k| k[:id] == option.action}[0]
  args.state.current_description = carve args, args.state.current_node[:description]
  args.state.current_choices = args.state.current_node[:choices] || []
  args.state.options = []
  args.state.current_heading = args.state.current_node[:heading] || ""
end

def carve args, txt
  words = txt.split ' '
  lines = []
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
      opt_text = "-> #{o.choice}"
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

def fetch_story
  {
    title: "The Threshold",
    content: [
      {
        id: "threshold",
        heading: "The Threshold",
        description: "You have never been here before. You have never seen this house. 
        But you feel like it knows you. Why did you come here? You heard the call.
        You heard the call and you answered.",
        choices: [
          {
            choice: "Enter.",
            destination: "door"
          },
          {
            choice: "Flee!",
            destination: "driveway"
          }
        ],
      },
      {
        id: "door",
        heading: "The Door",
        description: "The door is not locked. It yields to your touch. 
                      The door swings ajar by a few inches, revealing a tall slice of shadow. 
                      Reach for the handle. Quickly now, pull it closed. 
                      This door is not for opening. 
                      It is for holding back the nameless dread, 
                      to keep it from leaking out into the world of light and warmth and life. 
                      The world you leave behind you now, as you cross over the threshold.",
        choices: [
          {
            choice: "Your fate is sealed. This story is over. Begin again.",
            destination: "threshold"
          }
        ]
      },
      {
        id: "driveway",
        heading: "The Driveway",
        description: "Your heels spin, 
                      your shoes tap down the stone steps and crunch over the sparse gravel
                      of the overgrown driveway. 
                      What might be stealing up behind you? 
                      A stripe of terror rises up your neck and you bolt forwards, 
                      towards the gate, where you stop. 
                      The voice. There is the voice again. It calls you. 
                      You turn and walk towards the house.",
        choices: [
          {
            choice: "Your fate is sealed. This story is over. Begin again.",
            destination: "threshold"
          }
        ]
      }
    ]
  }
end

def calcstringwidth str
  $gtk.calcstringbox(str)[0]
end
