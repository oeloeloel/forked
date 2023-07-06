$gtk.reset
$story = nil

module Forked
  class Story
    attr_gtk

    def tick
      defaults unless args.state.forked.defaults_set

      @display ||= Display.new(THEME)
      @display.args = args
      @display.tick

      present args 
    return
      input args

      if args.inputs.keyboard.key_down.backspace ||
        args.state.forked.reset_at_end_of_tick
        args.gtk.reset_next_tick
      end
    end

    def defaults
      story_text = fetch_story args
      # putz story_text
      args.state.forked.story = Parser.parse(story_text)

      args.state.forked.root_chunk = args.state.forked.story[:chunks][0]
      putz args.state.forked.story[:chunks][0]
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
          # putz "not root chunk"
          args.state.forked.story.chunks.select { |k| k[:id] == option.action }[0]
        else
          # putz "root chunk"
          args.state.forked.root_chunk
        end
# putz args.state.forked.root_chunk
      # args.state.forked.current_lines = args.state.forked.current_chunk[:lines]
      args.state.forked.current_lines = args.state.forked.current_chunk[:content]
      args.state.forked.options = []
      args.state.forked.current_heading = args.state.forked.current_chunk[:heading] || ''
# putz args.state.forked.story
      # unless args.state.forked.current_chunk.actions.empty?
      #   args.state.forked.current_chunk.actions.each do |a|
      #     evaluate args, a
      #   end
      # end

      if args.state.forked.current_lines.empty?
        raise "No lines were found in the current story chunk. Current chunk is #{args.state.current_chunk}" 
      end
    end

    def present args
      # display_format = []

      # display_format << {
      #   type: :heading,
      #   text: args.state.forked.current_heading 
      # }

      # display_format << {
      #   type: :rule
      # }

      # args.state.forked.current_lines.each do |line|
        # putz line
# if false
#         # button contains trigger, action
      #   if line.trigger.filled?
      #     display_format << {
      #       type: :button,
      #       text: line.trigger,
      #       action: line.action
      #     }
      #   else
      #     # this is text
      #     display_format << {
      #       type: :paragraph,
      #       atoms: [
      #         {
      #           text: line.text,
      #           styles: []
      #         }
      #       ]
      #     }
      #   end
      # end

      # putz args.state.story.
      # @display.update(display_format)
      @display.update(args.state.forked.current_lines) 
    end

    def fetch_story args
      story_text = args.gtk.read_file STORY_FILE
      
      if story_text.nil?
        raise "The file #{STORY_FILE} failed to load. Please check it."
      end

      return story_text

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
      @display.apply_theme(theme)
    end
  end
end

class String
  def filled?
    !self.empty?
  end
end