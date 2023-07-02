$gtk.reset
$story = nil

module Forked
  class Story
    attr_gtk

    def tick
      defaults unless args.state.forked.defaults_set
      present args
      input args

      if args.inputs.keyboard.key_down.backspace ||
        args.state.forked.reset_at_end_of_tick
        args.gtk.reset_next_tick
      end
    end

    def defaults
      state.display = DISPLAY.dup

      args.state.forked.story = fetch_story args

      args.state.forked.defaults_set = true

      args.state.forked.root_chunk = args.state.forked.story[:chunks][0]
      args.state.forked.title = args.state.forked.story[:title]

      follow args
      args.state.forked.defaults_set = true
    end

    def input args
      return unless args.state.forked.options
      return if args.state.forked.options.empty?

      args.state.forked.options.each do |option|
        next if option.action.empty?

        if option.intersect_rect? args.inputs.mouse.point
          follow args, option if args.inputs.mouse.up
          option.merge!(state.display[:button_rollover_color])
        end
      end
    end

    def follow args, option = nil
      if option && option.action && !option.action.start_with?("#")
        evaluate(args, option.action.to_s)
        return
      end

      args.state.forked.current_chunk =
        if option
          args.state.forked.story.chunks.select { |k| k[:id] == option.action }[0]
        else
          args.state.forked.root_chunk
        end

      args.state.forked.current_lines = args.state.forked.current_chunk[:lines]
      args.state.forked.options = []
      args.state.forked.current_heading = args.state.forked.current_chunk[:heading] || ''

      unless args.state.forked.current_chunk.actions.empty?
        args.state.forked.current_chunk.actions.each do |a|
          evaluate args, a
        end
      end

      if args.state.forked.current_lines.empty?
        raise "No lines were found in the current story chunk. Current chunk is #{args.state.current_chunk}" 
      end
    end

    def carve args, paragraphs, font, line_width
      paragraphs = paragraphs.split("\n")
      lines = []

      paragraphs.each do |para|
        words = para.split(' ')
        line = ''

        until words.empty?
          new_line = line + words[0]

          if args.gtk.calcstringbox(new_line, 0, font)[0] > line_width
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

    def present args
      outputs.background_color = state.display[:background_color]

      line_height = state.display[:line_height]
      y_position = state.display[:margin_top].from_top - line_height

      args.state.forked.options = []
      options = []

      primitives = []

      heading = args.state.forked.current_heading
      heading = args.state.forked.title if heading.empty?

      heading_w = args.gtk.calcstringbox(heading, 0, state.display[:heading_font])[0]
      primitives << {
        x: state.display[:margin_left], y: y_position,
        text: heading,
        vertical_alignment_enum: 0,
        font: state.display[:heading_font],
        size_enum: state.display[:heading_font_size_enum],
        **state.display[:heading_text_color]
      }.label!

      primitives << {
        x: state.display[:margin_left],
        y: y_position - line_height * 0.5,
        w: state.display[:w],
        h: 2,
        **state.display[:horizontal_line_color]
      }.solid!

      if args.state.forked.current_lines.empty?
        raise "No lines available. Cannot map it."
      end

      y_position -= line_height

      args.state.forked.current_lines.each do |line|

        unless line.condition.empty?
          next unless evaluate args, line.condition
        end

        if !line.action.empty? &&
          line.trigger.empty?
            evaluate args, line.action
            next
        end

        # y_position -= line_height * 0.2 # state.display[:paragraph_spacing]

        text = line.text
        text_color = state.display[:text_color]
        box_color = state.display[:button_color]
        unless line.trigger.empty?

          y_position -= state.display[:line_height] * 0.5
          opt_text = line.trigger
          box = args.gtk.calcstringbox opt_text, 0, state.display[:button_font]

          box_color = state.display[:button_disabled_color] if line.action.empty?
          args.state.forked.options << {
            x: state.display[:margin_left],
            y: y_position - state.display[:button_padding_bottom] - line_height,
            w: box[0] + state.display[:button_padding_left] * 2,
            h: line_height + state.display[:button_padding_bottom] * 2,
            **box_color,
            action: line.action
          }.solid!

          text = opt_text
          text_color = state.display[:button_text_color] unless line.action.empty?
          
          primitives << {
            x: state.display[:margin_left] + state.display[:button_padding_left],
            y: y_position - line_height,
            text: text,
            vertical_alignment_enum: 0,
            **text_color,
            font: state.display[:button_font]
          }.label!

          y_position -= line_height
        else
          font = state.display[:font_regular]
          indent = 0
          display_w = state.display[:w]
          
          if line.text_format == 'code'
            font = state.display[:code_font]
            indent = 20
            display_w -= indent * 2
            text_color = state.display[:code_text_color]

            # primitives << {
            #   x: state.display[:margin_left],
            #   y: y_position - line_height * (2 * state.display[:paragraph_spacing]),
            #   y: y_position - line_height - (line_height * state.display[:paragraph_spacing]) * 2,
            #   w: state.display[:w],
            #   h: line_height + line_height * (2 * state.display[:paragraph_spacing]),
            #   **state.display[:code_background_color],
            #   a: 100,
            # }.solid!

            # y_position -= line_height * state.display[:paragraph_spacing]

          end

          primitives << (carve args, line.text, font, display_w).map do |item|
            {
              x: state.display[:margin_left] + indent,
              y: y_position -= state.display[:line_height],
              text: item,
              vertical_alignment_enum: 0,
              **text_color,
              font: font
            }.label!
          end

          # y_position -= line_height * state.display[:paragraph_spacing] if line.text_format == 'code'
          y_position -= line_height * state.display[:paragraph_spacing]
        end
      end

      args.outputs.primitives << [args.state.forked.options, primitives]
 
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
        format: "",
        condition: "", # condition to display this line (optional)
        trigger: "", # trigger to perform the action (button or blank) (optional)
        action: "" # action to perform (id or method_name argument) (optional)
    }

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
      args.state.forked.story = story
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

      state.forked.parser_context ||= []
      state.forked.code_string ||= ''

      line_text.strip!

      ### IGNORE FORMATTING IN LINE
      # if the line starts with a %, don't process it. 
      # Display it as it is. MUST be at start of line.
      if line_text.start_with? '%'
        line_text.delete_prefix!('%').strip!
        line[:text] = line_text
        return line
      end

      ### BLOCKS GROUP TOGETHER TEXT AND ALLOW CONDITIONAL TEXT
      # Multiple lines/paragraphs can be wrapped in <> symbols to
      # Be treated as a unit.
      # Blocked lines (even if on a single line) can be used to 
      # Conditionally display text.
      
      

      ### FORMATTED AS CODE (not executable)
      # Non executable code can be displayed by
      # wrapping it with three tildes ~ on either side.
  
      if line_text.start_with?('~~~') && line_text.end_with?('~~~')
        line_text = pull_out '~~~', '~~~', line_text
        line[:text] = line_text[1]
        line[:text_format] = "code"
        return line
      end

      # ### CHUNK ACTIONS, single line.
      # if line_text.start_with?('```') && line_text.end_with?('```')
      #   line_text = pull_out('```', '```', line_text)[1]
      #   evaluate args, line_text
      #   return
      # end

      ### CHUNK ACTIONS multiline.
      # Actions surrounded with three backticks on either
      # side will be evaluated one time, whenever the chunk
      # is displayed.
      
      
      if line_text.start_with?('```')
        # opening backticks found, remove them
        line_text.delete_prefix!('```').strip!
        # code block is open
        state.forked.parser_context |= [:code]
        # empty the code string
        state.forked.code_string = ''
      end
      
      if state.forked.parser_context.include? :code
        # code block is open
        if line_text.end_with?('```')
          # found the closing backticks, delete them
          line_text.delete_suffix!('```').strip!
          # code block is closed
          state.forked.parser_context.delete(:code)
          # add this line to the code string
          state.forked.code_string += line_text
          # update the story with the code string
          line[:action] = state.forked.code_string
        else
          # code block is open and not ending
          # add the line to the code string
          state.forked.code_string += line_text + "\n"
        end
        return
      end
      
      # first process and remove conditions and lonely code calls
      # money = line_text.include? 'money_add'
      if line_text.start_with? '<```'
        line_text = pull_out('<', '>', line_text)[1]
        line_text, command = pull_out('```', '```', line_text)
        line_text.strip!
        if line_text.empty?
          # this is an action, not a condition
          line[:action] = command
          # this line is finished
          return line
        else
          # this is a condition, not an action
          line[:condition] = command
          # continue to allow the rest of the line to be processed
        end
      end

      # process line (or remaining line)

      if line_text.include? ']('
        # this line is an option
        line_text, line[:trigger] = pull_out('[', ']', line_text)
        # line_text, line[:action] = pull_out('(', ')', line_text)
        line_text, action = pull_out('(', ')', line_text)
        if action.start_with?('```') && action.end_with?('```')
            nothing, action = pull_out('```', '```', action)
        end
        line[:action] = action
      
      else
        # this line is plain old text
        line[:text] = line_text
      end

      line
    end

    def process_line1 line, line_text
      line_text.strip!

      # first process and remove conditions and lonely code calls
      # money = line_text.include? 'money_add'
      if line_text.start_with? '<%'
        line_text = pull_out('<', '>', line_text)[1]
        line_text, command = pull_out('%', '%', line_text)
        line_text.strip!
        if line_text.empty?
          # this is an action, not a condition
          line[:action] = command
          # this line is finished
          return line
        else
          # this is a condition, not an action
          line[:condition] = command
          # continue to allow the rest of the line to be processed
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
          # "found the start of a multiline"
          if line.include? '>'
            # "this is a single line condition"
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
            line = "<```#{method_name}``` " + line
            lines << line
          else
            # the middle of a multiline
            line = "<```#{method_name}``` #{line}>"
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
      read_between('```', '```', str)
    end

    #####################
    # EXECUTION
    #####################

    def evaluate(args, command)
      putz "Evaluating: #{command}"
      eval command
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

      if left_index
        right_index = str.index(right, left.length)
      end
      
      return unless left_index && right_index

      pulled = str.slice(left_index + left.size..right_index - 1)
      pulled.strip
    end

    def pull_out left, right, str
      left_index = str.index(left)

      if left_index
        right_index = str.index(right, left.length)
      end
      
      return unless left_index && right_index
      
      pulled = str.slice!(left_index + left.size..right_index - 1)
      str.sub!(left + right, '')
      
      [str.strip, pulled.strip]
    end

    def change_theme theme
      state.display = DISPLAY.dup.merge(theme)
    end
  end
end

class String
  def filled?
    !self.empty?
  end
end