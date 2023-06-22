$gtk.reset

# TODO: description fails if it does not contain newlines

# STORY_FILE = 'app/story.md'
# STORY_FILE = 'app/peas.md'
STORY_FILE = 'app/death-story.md'

def tick args
  defaults args unless args.state.defaults_set
  input args
  calc args
  render args

  if args.inputs.keyboard.key_down.backspace ||
     args.state.reset_at_end_of_tick
    args.gtk.reset_next_tick 
  end
end

def defaults args
  args.state.display_margin_x = 20
  args.state.display_margin_y = 20
  args.state.display_w = 600
  args.state.line_height = 26

  args.state.story = fetch_story args

  args.state.root_node = args.state.story[:content][0]
  args.state.title = args.state.story[:title]


  # death story variables
  args.state.death_story.money = 0
  args.state.death_story.inventory = []


  follow args
  args.state.defaults_set = true
end

def input args
  return unless args.state.options
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
  if option
    if option.action
      if option.action.start_with? "#"
        # "it's a link"
      else
        eval (option.action.to_s + " args")
        return
      end
    end
  end

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

  args.state.current_node.commands.each { |c| eval c }
  raise "Current description is not set in follow method. Current node is #{args.state.current_node}" if args.state.current_description.nil?
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
  y_position = args.state.display_margin_y.from_top - line_height

  args.state.options = []
  options = []

  labels = []
  lines  = []

  heading = args.state.current_heading
  heading = args.state.title if heading.empty?
  labels << {
    x: 20, y: y_position,
    text: heading,
    vertical_alignment_enum: 0
  }

  lines << {
    x: args.state.display_margin_x,
    y: y_position,
    w: args.state.display_w,
    h: 0
  }.line!

  y_position -= line_height

  if args.state.current_description.nil?
    raise "No current description available. Cannot map it."
  end

  labels << args.state.current_description.map do |line|
    y_position -= line_height
    {
      x: 20, y: y_position,
      text: line,
      vertical_alignment_enum: 0
    }
  end

  y_position -= line_height * 0.5

  unless args.state.current_choices.empty?
    args.state.options = []
    options = []

    args.state.current_choices.each do |o|
      opt_text = " > #{o.choice}"
      box = args.gtk.calcstringbox opt_text
      y_position -= line_height * 1.5

      if o.destination.nil?
        opt_color = { r: 0, g: 0, b: 0 }
        bg_color = { r: 200, b: 200, g: 200 }

        lines << {
          x: args.state.display_margin_x, 
          y: y_position + line_height.half, 
          w: box[0] + 5, h: 0
        }
      else
        opt_color = { r: 255, g: 255, b: 255 }
        bg_color = { r: 0, g: 0, b: 0}
      end

      option = {
        x: args.state.display_margin_x,
        y: y_position - 2,
        w: box[0] + 5,
        h: line_height,
        **bg_color,
        action: o.destination
      }
      
      options << option
      args.state.options << option unless o.destination.nil?

      labels << {
        x: args.state.display_margin_x,
        y: y_position,
        text: opt_text,
        vertical_alignment_enum: 0,
        **opt_color
      }

    end

    args.outputs.solids << args.state.options
  end

  restart_text = " < Begin again"

  restart_label = {
    x: args.state.display_margin_x,
    y: args.state.display_margin_y,
    text: restart_text,
    r: 255, g: 255, b: 255,
    vertical_alignment_enum: 0
  }

  box = args.gtk.calcstringbox(restart_text)

  restart_option = {
    x: restart_label.x,
    y: restart_label.y - 2,
    w: calcstringwidth(restart_text) + 5, h: line_height,
    action: "reset_game"
  }

  labels << restart_label
  options << restart_option
  args.state.options << restart_option

  args.outputs.solids << options
  args.outputs.labels << labels
  args.outputs.lines << lines
end

def fetch_story args
  story_text = args.gtk.read_file STORY_FILE
  
  if story_text.nil?
    raise "The file #{STORY_FILE} failed to load. Please check it."
  end

  parse_story args, story_text
end

def parse_story args, story_text
  story = { content: [] }
  current_heading_number = -1
  temp_description = ''
  flush_description = false

  story_text.each_line.with_index do |l, i|
    l.strip!
    if l.start_with? '<'
      story[:content][current_heading_number][:commands] << new_command(args, l)
    elsif l.start_with? '##'
      # found heading
      current_heading_number += 1
      story[:content] << new_heading(args, l)
      flush_description = true
    elsif l.start_with? '#'
      # found title
      story[:title] = l[2..l.length]
    elsif l.start_with? '['
      # plutz "# found link"
      story[:content][current_heading_number][:choices] << new_choice(l)
    else
      # found description
      temp_description += "\n" + l
    end

    if flush_description || i == story_text.size - 1 # eof
      story[:content][current_heading_number - 1][:description] = new_description(args, temp_description)
      temp_description = ''
      flush_description = false
    end
  end

  story[:content][current_heading_number][:description] = new_description(args, temp_description)
  
  story
end

def new_command args, line
  line.delete!('<>')
  line.strip!
  line.split(' ').join(' args, ')
end

def new_heading args, line
  line.delete_prefix!('##').strip!
  heading, id = line.split('{')
  heading.strip!

  if id.nil? && heading
    raise "The heading \"#{heading}\" must be followed by an id. Example:
## The Bottom Of the Ocean {#bottom_of_ocean}"
  end

  id.chomp!('}').strip!
  {
    heading: heading,
    id: id,
    choices: [],
    description: [],
    commands: []
  }
end

def new_description args, para
  carve args, para.strip
end

def new_choice line
  choice, destination = line.strip.split(']')
  if choice.nil?
    raise "No choice was found. Line is #{line}"
  end
  unless destination.nil?
    destination.delete!('()').strip!
  end
  choice.delete!('[').strip!
  
  {
    choice: choice,
    destination: destination
  }
end

def reset_game args
  args.state.reset_at_end_of_tick = true
end

def calcstringwidth str
  $gtk.calcstringbox(str)[0]
end

#####################
# CUSTOM FUNCTIONS
#####################

def inventory_add args, item
  args.state.death_story.inventory << item
end

def inventory_remove args, item
  args.state.death_story.inventory.delete(item)
end

def inventory_has? args, item
  args.state.death_story.inventory.include? item
end

def money_add args, amount
  args.state.death_story.money += amount
end

def money_remove args, amount
  args.state.death_story.money -= amount
end

def money_amount args, amount
  args.state.death_story.money
end