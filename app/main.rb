$gtk.reset

STORY_FILE = 'app/death-story.md'

def tick args
  defaults args unless args.state.defaults_set

  # calc args
  render args
  input args

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
  args.state.option_padding_x = 10
  args.state.option_padding_y = 2

  args.state.story = fetch_story args

  args.state.defaults_set = true

  args.state.root_chunk = args.state.story[:chunks][0]
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

  args.state.options.each do |option|
    next if option.action.empty?

    if option.intersect_rect? args.inputs.mouse.point
      follow args, option if args.inputs.click
      option.merge!(r: 255, g: 0, b: 0)
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
        evaluate(args, option.action.to_s)
        return
      end
    end
  end

  args.state.current_chunk =
    if option
      args.state.story.chunks.select { |k| k[:id] == option.action }[0]
    else
      args.state.root_chunk
    end
  args.state.current_lines = args.state.current_chunk[:lines]
  args.state.options = []
  args.state.current_heading = args.state.current_chunk[:heading] || ''

 
  unless args.state.current_chunk.actions.empty?
    args.state.current_chunk.actions.each do |a|
      putz "about to evaluate: #{a}"
      evaluate args, a
    end
  end
  if args.state.current_lines.empty?
    raise "No lines were found in the current story chunk. Current chunk is #{args.state.current_chunk}" 
  end
end

def navigate chunk_id

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

def render args
  line_height = args.state.line_height
  y_position = args.state.display_margin_y.from_top - line_height

  args.state.options = []
  options = []

  primitives = []

  heading = args.state.current_heading
  heading = args.state.title if heading.empty?

  primitives << {
    x: 20, y: y_position,
    text: heading,
    vertical_alignment_enum: 0
  }.label!

  primitives << {
    x: args.state.display_margin_x,
    y: y_position,
    w: args.state.display_w,
    h: 0
  }.line!

  if args.state.current_lines.empty?
    raise "No lines available. Cannot map it."
  end

  args.state.current_lines.each do |line|

    unless line.condition.empty?
      next unless evaluate args, line.condition
    end

    if !line.action.empty? &&
      line.trigger.empty?
      # TODO: find a way to make this run one time
        # action, argument = line.action.split
        evaluate args, line.action
        next
    end

    # putz line if money
    y_position -= line_height

    text = line.text
    text_color = { r: 0, g: 0, b: 0 }
    box_color = { r: 0, g: 0, b: 0 }
    unless line.trigger.empty?

      y_position -= args.state.line_height * 0.5
      opt_text = line.trigger
      box = args.gtk.calcstringbox opt_text
      box_color = { r: 200, g: 200, b: 200 } if line.action.empty?
      args.state.options << {
        x: args.state.display_margin_x,
        y: y_position - args.state.option_padding_y - line_height,
        w: box[0] + args.state.option_padding_x * 2,
        h: line_height + args.state.option_padding_y * 2,
        **box_color,
        action: line.action
      }.solid!

      text = opt_text
      text_color = { r: 255, g: 255, b: 255 } unless line.action.empty?
      
      primitives << {
        x: args.state.display_margin_x + args.state.option_padding_x,
        y: y_position - line_height,
        text: text,
        vertical_alignment_enum: 0,
        **text_color
      }.label!
    else
      primitives << (carve args, line.text).map do |item|
        {
          x: args.state.display_margin_x,
          y: y_position -= args.state.line_height,
          text: item,
          vertical_alignment_enum: 0,
          **text_color
        }.label!

      end
    end
  end

  # args.state.options += options



  # raise "end"
=begin
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
=end
  restart_text = " < Begin again"

  restart_label = {
    x: args.state.display_margin_x,
    y: args.state.display_margin_y,
    text: restart_text,
    r: 255, g: 255, b: 255,
    vertical_alignment_enum: 0
  }.label!

  box = args.gtk.calcstringbox(restart_text)

  restart_option = {
    x: restart_label.x,
    y: restart_label.y - 2,
    w: calcstringwidth(restart_text) + 5, h: line_height,
    action: "reset_game args"
  }.solid!

  primitives << restart_label
  args.state.options << restart_option


  money_label = {
    x: args.state.display_margin_x + args.state.display_w,
    y: args.state.display_margin_y,
    text: "$#{add_commas_to_number args.state.death_story.money}",
    alignment_enum: 2,
    vertical_alignment_enum: 0,
  }.label!

  primitives << money_label



  args.outputs.primitives << [args.state.options, primitives]
end

def fetch_story args
  story_text = args.gtk.read_file STORY_FILE
  
  if story_text.nil?
    raise "The file #{STORY_FILE} failed to load. Please check it."
  end

  parse_story args, story_text
end

STORY_TEMPLATE = {
  title: "", # name of the story (mandatory)
  chunks: [] # sections of the story (mandatory)
}

CHUNK_TEMPLATE = {
  heading: "", # the display name of the chunk (optional)
  id: "", # the id of the chunk used for navigation (mandatory)
  lines: [] # each line in the chunk (mandatory)
}

LINE_TEMPLATE = {
    text: "", # paragraph text (optional)
    condition: "", # condition to display this line (optional)
    trigger: "", # trigger to perform the action (button or blank) (optional)
    action: "" # action to perform (id or method_name argument) (optional)
}

def parse_story_3 args, story_text
  raise "The story file is empty." if story_text.empty?

  story = STORY_TEMPLATE.dup

  chunk_number = 0
  story_text.each_line do |line|
    story.title = process_title line if story.title.empty?

  end
end

def process_title line
  unless line && line.class == String
    raise "Found an unexpected item while looking for the title. #{line}"
  end

  if  !line.strip.start_with?('##') &&
      line.strip.start_with?('#')
    line.delete_prefix!('#').strip!
  end
end
    


def parse_story args, story_text
  story = STORY_TEMPLATE.dup

  # strip out comments
  # remove blank lines
  # remove whitespace from start and end of lines
  story_text = clean_text(story_text)

  # locate and divide all story chunks by heading
  story_text_chunks = separate_chunk_text(story_text)

  story[:title] = make_title story_text_chunks
  raise "This story has no title." unless story[:title]

  # parse each story chunk
  chunks = []
  story_text_chunks.each do |chunk_text|
    chunk = CHUNK_TEMPLATE.dup

     # extract and store heading
    chunk[:heading], chunk[:id] = make_heading chunk_text

    # divide remaining node content to items and process
    # from top to bottom.
    chunk_lines = process_multiline_conditions chunk_text

    lines = []
    chunk_actions = []
    chunk_lines.each do |line_text|
      line = LINE_TEMPLATE.dup
      process_line line, line_text
      
      # actions without triggers will be promoted to the chunk level
      if line.action.filled? && line.trigger.empty?
        chunk_actions << line.action
        next
      end

      lines << line
    end

    chunk[:lines] = lines
    chunk[:actions] = chunk_actions

    chunks << chunk
  end
  story[:chunks] = chunks
  args.state.story = story
end

def parse_story_v1 args, story_text
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
# PARSING
#####################
def clean_text str
  new_str = ''
  str.each_line do |l|
    # remove comments from text
    new_l = r_clobber('//', l)
    # ignore blank lines
    next if l.strip.size.zero?
    # remove whitespace
    new_str += new_l.strip + "\n"
  end
  new_str
end

def separate_chunk_text str
  chunks = []
  chunk_str = ''
  str.each_line do |l|
    if l.start_with? '##'
      chunks << chunk_str unless chunk_str.size.zero?
      chunk_str = l
    elsif l.start_with? '#'
      chunks.unshift l
    else
      chunk_str += l
    end
  end
  chunks << chunk_str
  chunks
end

def process_line line, line_text
  line_text.strip!

  # first process and remove conditions and lonely code calls
  # money = line_text.include? 'money_add'
  if line_text.start_with? '<%'
    line_text = pull_out('<', '>', line_text)[1]
    line_text, command = pull_out('%', '%', line_text)
    line_text.strip!
    # putz command if money
    if line_text.empty?
      # this is an action, not a condition
      line[:action] = command
      # this line is finished
      # putz line
      return line
    else
      # this is a condition, not an action
      line[:condition] = command
      # continue to allow the rest of the line to be processed
      putz line
    end
  end

  # process line (or remaining line)

  if line_text.include? ']('
    # this line is an option
    line_text, line[:trigger] = pull_out('[', ']', line_text)
    line_text, line[:action] = pull_out('(', ')', line_text)
  else
    # this line is plain old text
    line[:text] = line_text
  end

  line
end

def make_title chunks
  title = nil
  chunks.each do |chunk|
    if (!chunk.start_with? '##') &&
      (chunk.start_with? '#')
      title = chunk.delete_prefix('#').strip
      chunks.delete(chunk)
      break
    end
  end

  title
end

def make_heading chunk_text
  heading_line = chunk_text.lines[0].strip
  heading_line.delete_prefix!('##').strip
  chunk_text.slice!(0, chunk_text.lines[0].size)

  pull_out('{', '}', heading_line)
end

def process_multiline_conditions chunk
  in_condition = false
  method_name = nil
  lines = []
  chunk.each_line do |line|
    line.strip!
    if line.start_with? '<'
      # found the start of a multiline
      if line.include? '>'
        # this is a single line condition
        lines << line
      else
        # this is a multi line condtion
        in_condition = true
        method_name = find_method_name line
        line += '>'
        lines << line
      end
    elsif in_condition
      # a multiline is not finished
      if line.include? '>'
        # the multiline ends here
        in_condition = false
        line = "<(#{method_name}) " + line
        lines << line
      else
        # the middle of a multiline
        line = "<(#{method_name}) #{line}>"
        lines << line
      end
    else
      # this line is not in a multiline
      lines << line
    end
  end
  lines
end

def find_method_name str
  read_between('(', ')', str)
end

#####################
# EXECUTION
#####################

def evaluate(args, command)
  # begin
    # stop command if command.include? "!inv"
    putz "Evaluating: #{command}"
    eval command
    
  # rescue
  #   raise "Could not execute command: #{command}"
  # end
end

#####################
# STRING HANDLING
#####################

def r_clobber match, str
  index = str.index(match)
  return str unless index

  str.slice!(index..str.length)
  str
end

def read_between left, right, str
  left_index = str.index(left)
  right_index = str.index(right)
  
  return unless left_index && right_index

  pulled = str.slice(left_index + left.size..right_index - 1)
  pulled.strip
end

def pull_out left, right, str
  left_index = str.index(left)
  # if str.include? '%'
  #   putz [left_index, str[left_index + 1, str.length],]
  # end
  temp_str = str
  putz temp_str
  right_index = str.index(right)
  
  return unless left_index && right_index

  pulled = str.slice!(left_index + left.size..right_index - 1)
  str.sub!(left + right, '')

  [str.strip, pulled.strip]
end

def add_commas_to_number num
  num.to_s.reverse.each_char.map.with_index do |c, i|
    c += ',' if i % 3 == 2 && i < num.to_s.length - 1
    c
  end.join.reverse
end

class String
  def filled?
    !self.empty?
  end
end

#####################
# NUMBER HELPERS
#####################

class Numeric
  def min other
    self < other ? self : other
  end

  def max other
    self > other ? self : other
  end

  def less_than other
    self < other
  end

  def greater_than other
    self > other
  end
end



#####################
# CUSTOM FUNCTIONS
#####################

def inventory_add item
  $args.state.death_story.inventory << item unless $args.state.death_story.inventory.include? item
end

def inventory_remove item
  $args.state.death_story.inventory.delete(item)
end

def inventory_has? item
  $args.state.death_story.inventory.include? item
end

def inventory_list
  $args.state.death_story.inventory
end

def money_add amount
  $args.state.death_story.money += amount
end

def money_remove amount
  ($args.state.death_story.money -= amount).max 0
end

def money_amount
  $args.state.death_story.money
end

def has_money?
  $args.state.death_story.money.positive?
end

def airport_wait_add
  $args.state.airport_wait += 1
end

def airport_wait_num num
  $args.state.airport_wait == num
end

def airport_wait_num_less_than num
  $args.state.airport_wait < num
end

def airport_wait_num_greater_than num
  $args.state.airport_wait > num
end

def airport_wait_reset
  $args.state.airport_wait = 0
end

def cause_of_death_set str
  $args.state.death_story.cause_of_death = str
end

def cause_of_death_get str
  $args.state.death_story.cause_of_death
end

def gamble param
  case param
  when "reset"
    $args.state.placed_bet = false
    $args.state.color_choice = "none"
    $args.state.won = false
  when "red"
    $args.state.placed_bet = true
    $args.state.won = $args.state.color_choice != "red"
    $args.state.color_choice = "red"
  when "black"
    $args.state.placed_bet = true
    $args.state.won = $args.state.color_choice != "black"
    $args.state.color_choice = "black"
  end

  if $args.state.won
    $args.state.winning_color = $args.state.color_choice
    $args.state.death_story.money *= 2
  elsif $args.state.placed_bet
    $args.state.winning_color = $args.state.color_choice == "red" ? "black" : "red"
    $args.state.death_story.money = 0
  end
end