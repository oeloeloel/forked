require_relative 'conditional.rb'
require_relative 'paragraph.rb'
require_relative 'blockquote.rb'

module Forked
  # parses the story file

  class Parser
    DEFAULT_TITLE = 'A Forked Story'.freeze

    class << self
      def parse(story_file)
        raise 'FORKED: The story file is missing.' if story_file.nil?
        raise 'FORKED: The story file is empty.' if story_file.empty?

        # used when parsing inline styles
        @style_marks = make_style_marks

        # Empty story
        story = make_story_hash

        context = [:title] # we're looking for a title and nothing else right now
        style_context = [] # tracking inline styles

        @escapable = make_escapable_list

        story_lines = story_file.lines
        line_no = -1
        @increment_line_no = true

        while(line = story_lines.shift)
          line_no += 1 if @increment_line_no
          @increment_line_no = true
          # puts "#{line_no + 1}: #{line.strip}" unless line.strip.empty?

          sc = escape('\~@@@@@@@@', ['~'])
          escaped = escape(line, @escapable)

          ### PREFORMATTED LINE (^@@) and stop parsing it
          result = parse_preformatted_line(escaped, context, story, line_no)
          next if result

          ### STRIP C COMMENT (//) and continue parsing line
          result = parse_c_comment(escaped, context)
          if result
            next if result == true

            line = result
            escaped = result
          end

          ### HTML COMMENTS (<!-- -->)
          result = parse_html_comment(escaped, context, line_no)
          next unless result

          escaped = result

          ### TITLE
          result = parse_title(escaped, context, story, line_no)
          next if result

          # Forked wants the first non-blank, non comment line of
          # the story file to be the title. The exception was
          # removed here to allow for different behaviour here
          # (possible secret title page behaviour)

          ### BLOCKQUOTE
          result = parse_blockquote(line, context, story, line_no)
          next if result

          ### HEADING LINE
          result = parse_heading(escaped, context, story, line_no)
          next if result

          ### RULE
          result = parse_rule(escaped, context, story, line_no)
          next if result

          ### CODE FENCE
          result = parse_code_fence(escaped, context, story, line_no)
          next if result

          ### TRIGGER
          # currently works for newstyle colon and old-style backtick trigger actions
          result = parse_trigger(escaped, context, story, line_no)
          next if result

          ### IMAGE
          result = parse_image(escaped, context, story, line_no)
          next if result

          ### CONDITION
          result = parse_condition_block2(escaped, line, context, story, line_no, story_lines)
          case result
          when String # line must change, continue processing
            line = result 
            escaped = escape(line, @escapable)
          when TrueClass
            next # finished processing line, go to next line
          when NilClass
            # nothing doing, continue processing line
          else
            raise "Unexpected result parsing condition block: #{result.class}"
          end

          ### CODE BLOCK
          result = parse_code_block(escaped, line, context, story, line_no)
          next if result

          ### ACTION BLOCK
          result = parse_action_block(escaped, line, context, story, line_no)
          next if result

          # PARAGRAPH
          parse_paragraph(escaped, context, story, line_no)

          # MEANINGFUL BLANK LINE
          result = parse_blank(line, context, story, line_no)
          next if result
        end

        story
      end


      # action blocks contain executable code
      # action block markers are a beginning and ending pair of colons ::
      # action block markers can be block level or line level but not inline

      # Block level:
      # ::
      # # block level
      # code()
      # ::

      # Line level:
      # :: code() ::

      # Inline not supported
      # NO! This will display as text :: code() ::

      # Mixing levels not supported
      # :: no!()
      # ::

      # ::
      # no!() ::

      def parse_action_block(escaped, line, context, story, line_no)
        prohibited_contexts = [:code_block, :trigger_action, :condition_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)
        return unless escaped.start_with?('::') ||
          context.include?(:action_block)

        if escaped.start_with? '::'
          # capture single line action
          if line.strip.start_with?(':: ') && line.strip.end_with?(' ::') && line.length > 3
            line.strip!
            line.delete_prefix!(':: ')
            line.delete_suffix!(' ::')
            line.strip!
            if story[:chunks][-1]
              story[:chunks][-1][:actions] << line
            else # different behaviour for code that comes between the title and the first chunk
              story[:actions] ||= []
              story[:actions] << line
            end
            return true
          end

          # capture action block end/start (close/open context)
          if context.include?(:action_block)
            context.delete(:action_block)
          elsif story[:chunks][-1] 
            context << (:action_block)
            story[:chunks][-1][:actions] << ''
          else # different behaviour for code that comes before the first chunk
            context << (:action_block)
          end

          return true

        # capture action block content
        elsif context.include?(:action_block)
          if story[:chunks][-1] 
            destination = story[:chunks][-1][:actions][-1]
            
            if destination.nil?
              raise "FORKED: An action block is open but no action exists in the current chunk.\n"\
                    "Check for an unterminated action block (::) around or before line #{line_no + 1}."
            end
            story[:chunks][-1][:actions][-1] += line
          else # different behaviour for code that comes before the first chunk
            story[:actions] ||= []
            story[:actions] << line
          end
          return true
        end
      end

      # when a line is totally blank, add it as a `:blank` element
      # only add one :blank - runs of blanks are not meaningful
      # display will ignore the blank
      # display will not treat two of the same block level
      # elements as contiguous if they are separated by a blank
      
      def parse_blank(line, context, story, line_no)
        # apply to blank lines and NO CONTEXT IS OPEN

        return if !line.strip.empty? ||
                  !context.empty?
        
        # check last element type
        prev_type = story&.[](:chunks)[-1][:content]&.[](-1)[:type]

        # blank is meaningful after last element? add it
        # for now, blank is only meaningful after button
        
        case prev_type
        when :button 
          story[:chunks][-1][:content] << make_blank_hash if prev_type == :button
        end
      end


      # strip comments from line (comments begin with //)
      def parse_c_comment(line, context)

        return unless line.include?('//')
        prohibited_contexts = [:code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('//')
          return true
        elsif line.include?(' //')
          index = line.index(' //')
          return line[0...index]
        end

        nil
      end

      # Code blocks format code for display
      # They begin with three tildes (~~~) on a blank line
      # and end with three ticks on a blank line
      def parse_code_block(escaped, line, context, story, line_no)
        prohibited_contexts = [:action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)


        if escaped.start_with?('~~~')
          if context.include?(:code_block)
            context.delete(:code_block)
          else
            context << (:code_block)
            story[:chunks][-1][:content] << make_code_block_hash

            # if this content is conditional, add the condition to the current element
            if context.include?(:condition_block) || context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
            end

          end
          true
        elsif context.include?(:code_block)
          # if the line contains escaped fencing, strip the backslash and present it as-is
          story[:chunks][-1][:content][-1].text += line
          true
        end
      end

      def parse_code_fence(line, context, story, line_no)
        return unless line.include?('```') 
        
        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        return true
      end

      # The heading line starts a new chunk
      # The heading line begins with a double #
      def parse_heading(line, context, story, line_no)

        return unless line.strip.start_with?('##') && 
        !line.strip.start_with?('###') &&

        prohibited_contexts = [:code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        context.delete(:heading)
        context.clear

        line.strip!
        line.delete_prefix!('##').strip!

        gfm_slug = make_slug(unescape(line, @escapable)) # GFM style header navigation

        if line.include?('{') && line.include?('}')
          line = pull_out('{', '}', line)
        else
          line = [line]
        end

        heading, chunk_id = line
        if heading.empty? && chunk_id.nil?
          raise "Forked: Expected heading and/or ID on line #{line_no + 1}."
        end

        heading = story.title.delete_prefix("#").strip if heading.empty?
        chk = make_chunk_hash

        chk[:id] = unescape(chunk_id, @escapable) if chunk_id
        chk[:slug] = gfm_slug

        hdg = make_heading_hash
        hdg[:text] = unescape(heading, @escapable)

        rul = make_rule_hash
        rul[:weight] = 3

        chk[:content] << hdg
        chk[:content] << rul

        story[:chunks] << chk
        true
      end

      def parse_html_comment(line, context, line_no)
        prohibited_contexts = [:code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return line unless context_safe?(context, prohibited_contexts, mandatory_contexts) 

        left_mark = '<!--'
        right_mark = '-->'

        # catch inline or single line html comment

        if line.include?(left_mark) && line.include?(right_mark)
          line = (pull_out(left_mark, right_mark, line))[0]
          return line unless line.empty?

          return nil
        end

        # start html comment (return non-comment part of line)
        if line.include?(left_mark)
          context << (:comment)
          line = left_of_string(line, left_mark)
          return nil if line.strip.empty?
        end

        # end html comment (return non-comment part of line)
        if line.include?(right_mark) && context.include?(:comment)
          context.delete(:comment)
          line = right_of_string(line, right_mark)
          return nil if line.strip.empty?
        end

        # while comment is open
        if context.include?(:comment)
          return nil
        end

        line
      end

      def parse_image(line, context, story, line_no)
        prohibited_contexts = [:code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('\![')
          line.delete_prefix!('\\')
          return
        end

        # first identify image, capture alt text and path
        if line.strip.start_with?('![') && 
           line.include?('](') &&
           line.strip.end_with?(')')

          line = line.strip.delete_prefix!('![')

          line.split(']', 2).then do |alt, path|
            alt.strip!
            path.strip!

            # this content is conditional? add the condition to the current element

            if context.include?(:condition_block) || context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
              story[:chunks][-1][:content][-1][:condition_segment] = @condition_segment_count
            end

            ### identify and catch url (return)
            path.delete_prefix!('(')
            path.delete_suffix!(')')
            
            img = make_image_hash
            img[:path] = path
            story[:chunks][-1][:content] << img
          end
        end
      end 

      # Force a line to display as plain, unformatted text, ignoring any further markup
      # Used for troubleshooting, not part of the specification
      def parse_preformatted_line(line, context, story, _line_no)

        return unless line.strip.start_with?('@@')
        
        prohibited_contexts = [:title, :code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        line.delete_prefix!('@@')
        para = make_paragraph_hash
        atm = make_atom_hash
        atm[:text] = unescape(line.chomp, @escapable)
        atm[:styles] << :pre
        para[:atoms] << atm
        story[:chunks][-1][:content] << para

        true
      end

      # draws a horizontal line
      def parse_rule(line, context, story, line_no)

        return unless line.strip.start_with?('---')

        prohibited_contexts = [:title, :code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        story[:chunks][-1][:content] << make_rule_hash

        # this content is conditional? add the condition to the current element
        if context.include?(:condition_block)  || context.include?(:condition_block)
          condition = story[:chunks][-1][:conditions][-1]
          story[:chunks][-1][:content][-1][:condition] = condition
        end

        true
      end

      # The title is required. No content can come before it.
      # The Title line starts with a single #
      def parse_title(line, context, story, _line_no)

        prohibited_contexts = []
        mandatory_contexts = [:title]
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('#') && !line.strip.start_with?('##')
          line.strip!
          line.delete_prefix!('#').strip!
        elsif !line.strip.empty?
          raise "FORKED: CONTENT BEFORE TITLE.

The first line of the story file is expected to be the title.
Please add a title to the top of the Story File. Example:

`# The Name of this Story`
"
        end
        story[:title] = unescape(line, @escapable)
        context.delete(:title) # title is found
        context << :heading # second element must be a heading
        true
      end

      def parse_trigger(line, context, story, line_no)
        prohibited_contexts = [:code_block, :action_block, :condition_code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)
        
        # first identify trigger, capture button text and action
        if line.strip.start_with?('[') && 
           line.include?('](') &&
           !context.include?(:trigger_action)

          line = line.strip.delete_prefix!('[')

          line.split(']', 2).then do |trigger, action|
            trigger.strip!
            action.strip!
            trg = make_trigger_hash
            trg[:text] = trigger
            story[:chunks][-1][:content] << trg

            # if this content is conditional, add the condition to the current element

            if context.include?(:condition_block) || context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
              story[:chunks][-1][:content][-1][:condition_segment] = @condition_segment_count
            end

            ### identify and catch chunk id action (return)
            # if action.end_with?(')')
            if action.include?(')')
              action.delete_prefix!('(')
              # action.delete_suffix!(')')
              action = action[0...action.rindex(')')]

              if action.start_with?('#') || action.strip.empty?
                # capture simple navigation
                story[:chunks][-1][:content][-1].action = action
                return true
              elsif action.start_with?(': ') && action.end_with?(' :')
                # capture single line trigger action
                action.delete_prefix!(': ')
                action.delete_suffix!(' :')
                # a kludge that identifies a Ruby trigger action from a normal action 
                # so actions that begin with '#' are not mistaken for navigational actions
                action = '@@@@' + action
                story[:chunks][-1][:content][-1].action = action
                return true
              else
                # not navigation, not a single line action, not a multiline action
                raise("UNCLEAR TRIGGER ACTION in line #{line_no + 1}")
              end

            # identify action block and open context (keep parsing)
            elsif action.end_with?('(:')
              context << :trigger_action
            end

            return true
          end

        # identfy action block close and close context, if open (return)
        elsif line.strip.start_with?(':)') && context.include?(:trigger_action)
          context.delete(:trigger_action)
          return true

        # if context is open, add line to trigger action (return)
        elsif context.include?(:trigger_action) || context.include?(:trigger_action)
          if story[:chunks][-1][:content][-1].action.size.zero?
            # a kludge that identifies a Ruby trigger action from a normal action 
            # so actions that begin with '#' are not mistaken for navigational actions
            line = '@@@@' + line
          end
          story[:chunks][-1][:content][-1].action += line
          return true
        end
      end 

      # check to see whether it is safe to proceed based on
      # context rules
      def context_safe?(context, prohibited = [], mandatory = [])
        # match at least one prohibited context
        context_prohibited = array_intersect?(context, prohibited) 
        # match all mandatory contexts
        context_mandatory = mandatory.empty? || context.intersection(mandatory) == mandatory.sort
        context_mandatory && !context_prohibited
      end

      # true when arr1 and arr2 contain any overlapping elements
      def array_intersect?(arr1, arr2)
        arr1.intersection(arr2).any?
      end

      # starting from the left of array haystack
      # count the number of contiguous
      # repetitions of char needle
      def char_reps(haystack, needle)
        i = 0
        while i < haystack.length
          return i unless haystack.chars[i] == needle
          i += 1
        end
        i
      end

      def find_first_non_escaping_instance(haystack, needle)
        offset = 0
        while true
          return unless idx = haystack.index(needle, offset)

          backcheck = haystack[offset...idx].reverse
          reps = char_reps(backcheck, '\\')
          return idx unless reps.odd?
          
          offset = idx + 1
        end
      end

      def l_split(line, delimiter)
        return unless idx = line.index(delimiter)
        
        [line[0...idx], line[idx + delimiter.length...line.length]]
      end

      def make_blank_hash
        {
          type: :blank
        } 
      end

      def make_slug(line)
        # make slug for GFM compatibility
        l = line.downcase.gsub(' ', '-')
        slug = ''
        l.chars.each do |c|
          o = c.ord
          if (o >= 97 && o <= 122) || (o >= 48 && o <= 57) || o == 45 || o == 95
           slug += c
          end
        end
        slug
      end

      def make_story_hash
        {
          title: DEFAULT_TITLE,
          chunks: []
        }
      end

      def make_chunk_hash
        {
          id: '',
          actions: [],
          conditions: [],
          content: []
        }
      end

      def make_rule_hash
        {
          type: :rule,
          weight: 1
        }
      end

      def make_atom_hash(text = '', styles = [], condition = [], condition_segment = '')
        {
          text: text,
          styles: styles,
          condition: condition,
          condition_segment: condition_segment
        }
      end

       def make_code_block_hash
        {
          type: :code_block,
          text: ''
        }
      end

      def make_heading_hash
        {
          type: :heading,
          text: ''
        }
      end

      def make_trigger_hash
        {
          type: :button,
          text: '',
          action: ''
        }
      end

      
      def make_image_hash
        {
          type: :image,
          path: ''
        }
      end

      def make_style_marks
        [
          { symbol: :bold_italic, mark: "***" },
          { symbol: :bold_italic, mark: "___" },
          { symbol: :bold, mark: "**" },
          { symbol: :bold, mark: "__"},
          { symbol: :italic, mark: "*" },
          { symbol: :italic, mark: "_" },
          { symbol: :code, mark: "`" }
        ]
      end

      def make_escapable_list
        [
          '\\', # escapes, hard wrap
          '!', # image
          '#', # heading
          '(', # image, trigger
          ')', # image, trigger
          '*', # inline style
          '_', # inline style
          '-', # rule
          '/', # C comment
          ':', # action
          '<', # condition
          '>', # condition
          '@', # pre
          '[', # trigger
          ']', # trigger
          '`', # code span
          '{', # chunk id, custom style
          '}', # chunk id, custom style
          '~', # code block
        ]
      end


      ################
      # STRING HELPERS
      ################

      # ecapes all instances of "\chr" in str
      def escape_char(str, chr)
        str.gsub("\\#{chr}", '\x' + chr.ord.to_s(16))
      end

      # unescapes all instances of char's escape sequence in str
      def unescape_char(str, chr)
        str.gsub('\\x' + chr.ord.to_s(16), chr)
      end

      # escapes all instances of characters in array that exist in str
      def escape(str, arr)
        arr.each { |chr| 
          str = escape_char(str, chr)
        }
        str
      end

      # unescapes all instances of characters in array that exist in str
      def unescape(str, arr)
        arr.each { |chr| str = unescape_char(str, chr)}
        str
      end

      # given a string str and string delimiters left and right
      # returns an array containing
      # [0] the content of the string to the left of the left delimiter + the content of the string to the right of the right delimiter
      # [1] the content of the string between the left and right delimiters
      # If either or both delimiters are not found, [0] will be an empty string and [1] will contain the original str
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

      # given a string str and a string delimiter
      # returns the portion of str preceding the delimiter
      # returns nil if the delimiter is not found
      def left_of_string str, delimiter
        return unless index = str.index(delimiter)

        str.slice(0, index)
      end

      # given a string str and a string delimiter
      # returns the portion of str following the delimiter
      # returns nil if the delimiter is not found
      def right_of_string str, delimiter
        return unless index = str.index(delimiter)

        index += delimiter.length
        str.slice(index, str.length)
      end
    end
  end
end

$gtk.reset
$story = nil
