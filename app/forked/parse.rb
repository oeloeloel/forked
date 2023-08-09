module Forked
  # parses the story file
  class Parser
    DEFAULT_TITLE = 'A Forked Story'.freeze

    class << self
      def parse(story_file)
        raise 'FORKED: The story file is missing.' if story_file.nil?
        raise 'FORKED: The story file is empty.' if story_file.empty?

        # Empty story
        story = make_story_hash

        context = [:title] # if we're in the middle of something

        # Elements understood by the parser:
        # [x] :blockquote (physical div)
        # [x] :condition block (logical div)
        # [x] :action_block (multiline code)
        # [x] :code_block (present code style, multiline)
        # [x] :trigger text (button display text)
        # [x] :trigger action (button action)
        # [x] :title (story title)
        # [x] :heading text (chunk heading)
        # [x] :chunk_id (chunk identifier)
        # [x] :paragraph (plain text)
        # [x] preserved line (do not parse line and present as text)
        # [x] comments (stripped and ignored)
        # [x] :rule (horizontal rule)
        # :action (single line code)
        # :code (present with code format < 1 line)
        # :bold (inline strong style)
        # :italic (inline emphasis style)
        # :bold italic (inline strong + emphasis style)

        story_file.each_line.with_index do |line, line_no|
          # "#{line_no}: #{line.strip}"

          ### PRESERVE LINE (^$$) and stop parsing it
          result = parse_preserve_line(line, context, story, line_no)
          next if result

          ### STRIP COMMENT (//) and continue parsing line
          result = parse_comment(line, context)
          line = result if result

          ### TITLE
          result = parse_title(line, context, story, line_no)
          next if result

          # Forked wants the first non-blank, non comment line of
          # the story file to be the title. The exception was
          # removed here to allow for different behaviour here
          # (possible secret title page behaviour)

          ### BLOCKQUOTE
          result = parse_blockquote(line, context, story, line_no)
          next if result

          ### HEADING LINE
          result = parse_heading(line, context, story, line_no)
          next if result

          # Forked wants the first non blank line after the title
          # to be a heading and will throw a wobbly if it isn't
          if context.include?(:heading) && !line.strip.empty?
            raise "FORKED: CONTENT BEFORE FIRST HEADING.

Forked expects to find a heading before finding any content.
Please add a heading line after the title and before any other content. Example:

`## The First Chapter {#start}`
"
          end

          ### RULE
          result = parse_rule(line, context, story, line_no)
          next if result

          ### TRIGGER

          result = parse_trigger(line, context, story, line_no)
          next if result

          ### CONDITION BLOCK
          # Condition block can start mid-line so it needs to
          # come after blockquote, which always starts at the
          # beginning of a line

          result = parse_condition_block(line, context, story, line_no)
          next if result

          ### CODE BLOCK
          result = parse_code_block(line, context, story, line_no)
          next if result

          ### ACTION BLOCK
          result = parse_action_block(line, context, story, line_no)
          next if result

          # PARAGRAPH
          parse_paragraph(line, context, story,  line_no)

          # line.each_char.with_index do |char, char_no|
            # parse inline elements
          # end
        end

        story
      end

      # check to see if it is safe to proceed based on
      # context rules
      def context_safe?(context, prohibited, mandatory)
        context_prohibited = array_intersect?(context, prohibited)
        context_mandatory = mandatory.empty? ||  array_intersect?(context, mandatory)

        context_mandatory && !context_prohibited
      end

      # true if arr1 and arr2 contain any overlapping elements
      def array_intersect?(arr1, arr2)
        arr1.intersection(arr2).any?
      end

      # draws a horizontal line
      def parse_rule(line, context, story, line_no)
        return unless line.strip.start_with?('---')

        prohibited_contexts = [:title, :code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        story[:chunks][-1][:content] << make_rule_hash

        # if this content is conditional, add the condition to the current element
        if context.include?(:condition_block)
          condition = story[:chunks][-1][:conditions][-1]
          story[:chunks][-1][:content][-1][:condition] = condition
        end

        true
      end

      # Force a line to display as plain, unformatted text, ignoring any further markup
      # Used for troubleshooting, not part of the specification
      def parse_preserve_line(line, context, story, _line_no)
        return unless line.strip.start_with?('$$')

        prohibited_contexts = [:title, :code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        line.delete_prefix!('$$')

        story[:chunks][-1][:content] << {
          type: :paragraph,
          atoms: [
            {
              text: line,
              styles: []
            }
          ]
        }

        true
      end

      def parse_paragraph(line, context, story, line_no)
        prohibited_contexts = [:title, :codeblock, :heading]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # at this point, we've been through all the other possible
        # elements so we know it's OK to process paragraphs now.

        line.strip!
        if line.empty?
          context.delete(:paragraph) if context.include?(:paragraph)
        else

          # check to see if the paragraph context is closed
          ## OR! the previous element is anything other than paragraph
          ### (it may have changed and we don't want to append to some other element)
          if !context.include?(:paragraph) || story[:chunks][-1][:content][-1][:type] != :paragraph
            # if there is no open paragraph or the previous element it not a paragraph
            # create a new empty paragraph (paragraph may have been interrupted?)
            context << (:paragraph)
            para = make_paragraph_hash
            para[:atoms] << make_atom_hash
            story[:chunks][-1][:content] << para
          end

          # if the previous atom was a condition, add a new empty atom.

          cond = story[:chunks][-1][:content][-1][:atoms][-1][:condition]

          if cond&.class == String
            atm = make_atom_hash
            atm[:text] = line + ' '
            story[:chunks][-1][:content][-1][:atoms] << atm
          else
            
            # deal with newlines
            if line.strip[-1] == '\\'
              line = line.delete_suffix('\\') + "\n"
            else
              line += ' '
            end

            # if the atom ends with a newline, start a new atom
            # the newline is a result of a backslash hard wrap
            prev = story[:chunks][-1][:content][-1][:atoms][-1][:text]
            if prev && prev[-1] == "\n"
              atm = make_atom_hash
              atm[:text] = line
              story[:chunks][-1][:content][-1][:atoms] << atm
            else
              # otherwise, append to the current atom
              story[:chunks][-1][:content][-1][:atoms][-1][:text] << line
            end

            # if this content is conditional, add the condition to the current atom
            if context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:atoms][-1][:condition] = condition
            end
          end
        end
      end

      # strip comments from line (comments begin with //)
      def parse_comment(line, context)
        return unless line.include?('//')

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('//')
          return ''
        elsif line.include?(' //')
          index = line.index(' //')
          return line[0...index]
        end

        nil
      end

      def parse_blockquote(line, context, story, _line_no)
        prohibited_contexts = [:code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # blockquotes must begin the line with >
        # The blockquote will continue until there
        # is a line that does not begin with >
        if line.strip.start_with?('>')

          line.delete_prefix!('>')

          unless line.empty?
            blq = make_blockquote_hash
            blq[:text] = line
            story[:chunks][-1][:content] << blq
          end

          # if this content is conditional, add the condition to the current element
          if context.include?(:condition_block)
            condition = story[:chunks][-1][:conditions][-1]
            story[:chunks][-1][:content][-1][:condition] = condition
          end

          return true
        end
      end


      # Code blocks format code for display
      # They begin with three ticks ``` on a blank line
      # and end with three ticks on a blank line
      def parse_code_block(line, context, story, line_no)
        if line.include?('~~~') & !line.include?('\~~~')
          if context.include?(:code_block)
            context.delete(:code_block)
          else
            context << (:code_block)
            story[:chunks][-1][:content] << make_code_block_hash

            # if this content is conditional, add the condition to the current element
            if context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
            end

          end
          true
        elsif context.include?(:code_block)
          # if the line contains escaped fencing, strip the backslash and present it as-is
          line.delete_prefix!('\\') if line.strip.start_with?('\~~~')
          story[:chunks][-1][:content][-1].text += line
          true
        end
      end

      # Code blocks format code for display
      # They begin with three ticks ``` on a blank line
      # and end with three ticks on a blank line
      def parse_code_block_old_1(line, context, story, line_no)
        if line.include?('```') & !line.include?('\```')
          if context.include?(:code_block)
            context.delete(:code_block)
          else
            context << (:code_block)
            story[:chunks][-1][:content] << make_code_block_hash
          end
          true
        elsif context.include?(:code_block)
          # if the line contains escaped fencing, strip the backslash and present it as-is
          line.delete_prefix!('\\') if line.strip.start_with?('\```')
          story[:chunks][-1][:content][-1].text += line
          true
        end
      end

      # action blocks contain executable code
      # They begin with three backticks ``` on a blank line
      # and end with three carets on a blank line
      def parse_action_block(line, context, story, line_no)
        prohibited_contexts = [:code_block, :trigger_action, :condition_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.include? '```'
          if context.include?(:action_block)
            context.delete(:action_block)
          else
            context << (:action_block)
            story[:chunks][-1][:actions] << ''
          end
          true
        elsif context.include?(:action_block)
          destination = story[:chunks][-1][:actions][-1]
          if destination.nil?
            raise "FORKED: An action block is open but no action exists in the current chunk.\n"\
                  "Check for an unterminated action block (```) around or before line #{line_no + 1}."
          end
          story[:chunks][-1][:actions][-1] += line
          true
        end
      end


      # action blocks contain executable code
      # They begin with three carets ^^^ on a blank line
      # and end with three carets on a blank line
      def parse_action_block_old_1(line, context, story)
        prohibited_contexts = [:code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.include? '^^^'
          if context.include?(:action_block)
            context.delete(:action_block)
          else
            context << (:action_block)
            story[:chunks][-1][:actions] << ''
          end
          true
        elsif context.include?(:action_block)
          story[:chunks][-1][:actions][-1] += line
          true
        end
      end

          # condition blocks allow for conditional text
      # CURRENTLY
      # They begin with a left angle bracket followed by 3 carets <^^^
      # and end with 3 carets followed by a right angle bracket ^^^>
      # The current functionality is to conditionally include text
      # returned from the block as a string
      def parse_condition_block(line, context, story, line_no)
        # problem: condition block appends to paragraph.
        # If there is no paragraph context open, it breaks.
        # If no paragraph context is open,
        # get out and let the paragraph (or other element)
        # code take over.

        # paragraph (or other element) must be responsible for
        # the condition being applied to the element/atom.

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # opening condition block context and condition code context
        if line.strip.end_with?('<%```')
          context << :condition_block
          context << :condition_code_block
          story[:chunks][-1][:conditions] << ''
          return true
        end

        # closing both condition code context and condition block context
        if line.strip.start_with?('```%>')
          context.delete(:condition_block)
          context.delete(:condition_code_block)
          if story[:chunks][-1][:content][-1].type == :paragraph
            atm = make_atom_hash
            atm[:condition] = story[:chunks][-1][:conditions][-1] 
            story[:chunks][-1][:content][-1][:atoms] << atm
            story[:chunks][-1][:content][-1][:atoms]
          else
            context << (:paragraph)
            para = make_paragraph_hash
            atm = make_atom_hash
            atm[:condition] = story[:chunks][-1][:conditions][-1]
            para[:atoms] << atm 
            story[:chunks][-1][:content] << para
          end
          return true
        end

        # NOTE: The above code appends an atom to the previous paragraph
        # if it is the last added element, or creates a new paragraph for the atom.
        # The atom contains only a condition and if the result of the condition
        # is a string, Forked will add the string to the atom text at runtime.

        # If the condition contains content between the closing code fence
        # and the closing condition, that doesn't happen. The following code runs
        # instead.

        # This is important because it's not decided if Forked should display a
        # returned string AND the following conditional content. Right now,
        # it won't do both but only because that's how it happens to be.

        # closing only condition code block context
        if line.strip == '```' && context.include?(:condition_code_block)
          context.delete(:condition_code_block)
          return true
        end

        # closing only condition block context
        if line.strip == '%>'
          context.delete(:condition_block)
          return true
        end

        # capture contents of condition code block
        if context.include?(:condition_code_block)
          story[:chunks][-1][:conditions][-1] += line
          return true
        end

        # nil return allows conditional content to be handled by other parsers
      end

      # The title is required. No content can come before it.
      # The Title line starts with a single #
      def parse_title(line, context, story, _line_no)
        prohibited_contexts = []
        mandatory_contexts = [:title]
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('#') && !line.strip.start_with?('##')
          line.strip.delete_prefix('#').strip
        elsif !line.strip.empty?
          raise "FORKED: CONTENT BEFORE TITLE.

The first line of the story file is expected to be the title.
Please add a title to the top of the Story File. Example:

`# The Name of this Story`
"
        end

        story[:title] = line
        context.delete(:title) # title is found
        context << :heading # second element must be a heading
      end

      # The heading line starts a new chunk
      # The heading line begins with a double #
      def parse_heading(line, context, story, line_no)
        return unless line.strip.start_with?('##') && !line.strip.start_with?('###')

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        context.delete(:heading)

        line.strip!
        line.delete_prefix!('##').strip!

        if line.include?('{') && line.include?('}')
          line = pull_out('{', '}', line)
        else
          line = [line]
        end

        # line
        heading, chunk_id = line
            if heading.empty? && chunk_id.nil?
              raise "Forked: Expected heading and/or ID on line #{line_no + 1}."
            end

            heading = story.title.delete_prefix("#").strip if heading.empty?
            
            chk = make_chunk_hash
            chk[:id] = chunk_id

            hdg = make_heading_hash
            hdg[:text] = heading

            rul = make_rule_hash
            rul[:weight] = 3

            chk[:content] << hdg
            chk[:content] << rul

            story[:chunks] << chk
            true
      end

            # triggers are represented as buttons that perform actions
      # [Trigger Text](Trigger Action)
      # Trigger action may be chunk id or an action block
      def parse_trigger(line, context, story, line_no)
        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # identify trigger and catch text (keep parsing)
        if line.strip.start_with?('[') && line.include?('](')
          line = line.strip.delete_prefix!('[')
          line.split(']', 2).then do |trigger, action|
            trigger.strip!
            action.strip!
            trg = make_trigger_hash
            trg[:text] = trigger
            story[:chunks][-1][:content] << trg

            # if this content is conditional, add the condition to the current element

            if context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
            end

            ### identify and catch chunk id action (return)
            if action.end_with?(')')
              action.delete_prefix!('(')
              action.delete_suffix!(')')

              if action.start_with?('#') || action.strip.empty?
                story[:chunks][-1][:content][-1].action = action
                return true
              else
                raise("UNCLEAR TRIGGER ACTION in line #{line_no + 1}")
              end

            # identify action block and open context (keep parsing)
            elsif action.end_with?('(```')
              context << :trigger_action
            end
          end
 

        # identfy action block close and close context, if open (return)
        elsif line.strip.start_with?('```)') && context.include?(:trigger_action)
          context.delete(:trigger_action)
          return true

        # if context is open, add line to trigger action (return)
        elsif context.include?(:trigger_action)
          story[:chunks][-1][:content][-1].action += line
          return true
        end
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

      def make_paragraph_hash
        {
          type: :paragraph,
          atoms: []
        }
      end

      def make_atom_hash
        {
          text: '',
          styles: [],
          condition: [],
        }
      end

      def make_blockquote_hash
        {
          type: :blockquote,
          text: '',
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
    end
  end
end

$gtk.reset
$story = nil
