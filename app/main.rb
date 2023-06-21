$gtk.reset

# STORY_FILE = 'app/story.md'
STORY_FILE = 'app/peas.md'

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

  args.state.story = fetch_story args
 
  args.state.root_node = args.state.story[:content][0]
  args.state.title = args.state.story[:title]
  
  follow args

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

def follow args, option = nil
  args.state.current_node =
    if option
      args.state.story.content.select { |k| k[:id] == option.action }[0]
    else
      args.state.root_node
    end
  args.state.current_description = args.state.current_node[:description]
  args.state.current_choices = args.state.current_node[:choices] || []
  args.state.options = []
  args.state.current_heading = args.state.current_node[:heading] || ''
end

def carve args, paragraphs
  paragraphs = paragraphs.split("\n")
  lines = []

  paragraphs.each do |para|
    words = para.split(' ')
    line = ''

    until words.empty?
      new_line = line + words[0]

      if calcstringwidth(new_line) > args.state.display_w
        lines << line
        line = new_line = ''
      end

      line += words.delete_at(0) + ' '

      if words.size.zero?
        lines << line
      end
    end

    lines << '' if line.size.zero?
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

  heading = args.state.current_heading
  heading = args.state.title if heading.empty?
  labels << {
    x: 20, y: y_position,
    text: heading,
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
      opt_text = " > #{o.choice}"
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

def fetch_story args
  story_text = args.gtk.read_file STORY_FILE
  parse_story args, story_text
end

def parse_story args, story_file
  story = { content: [] }
  current_heading_number = -1
  temp_description = ''
  flush_description = false

  story_file.each_line.with_index do |l, i|
    l.strip!
    if l.start_with? '##'
      # found heading
      current_heading_number += 1
      story[:content] << new_heading(args, l)
      flush_description = true
    elsif l.start_with? '#'
      # found title
      story[:title] = l[2..l.length]
    elsif l.start_with? '['
      # found link
      story[:content][current_heading_number][:choices] << new_choice(l)
    else
      # found description
      temp_description += "\n" + l
    end

    if flush_description || i == story_file.size - 1 # eof
      story[:content][current_heading_number - 1][:description] = new_description(args, temp_description)
      temp_description = ''
      flush_description = false
    end
  end

  story[:content][current_heading_number][:description] = new_description(args, temp_description)

  story
end

def new_heading args, line
  line.delete_prefix!('##').strip!
  heading, id = line.split('{')
  heading.strip!

  id.chomp!('}').strip!
  {
    heading: heading,
    id: id,
    choices: [],
    description: []
  }
end

def new_description args, para
  carve args, para.strip
end

def new_choice line
  choice, destination = line.strip.split(']')
  choice.delete!('[').strip!
  destination.delete!('()').strip!
  {
    choice: choice,
    destination: destination
  }
end

def calcstringwidth str
  $gtk.calcstringbox(str)[0]
end