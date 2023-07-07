
module Forked
  class Parser
    DEFAULT_TITLE = "A Forked Story"

    class << self

      def parse(story_file)
        raise "The story file is missing." if story_file.nil?
        raise "The story file is empty." if story_file.empty?

        # Empty story
        story = {
          title: DEFAULT_TITLE,
          chunks: [
            ]
        }

        content = [] # where we stick the results
        actions = [] # bucket for any code found along the way
        chunk_actions = [] # track any actions that operate at the chunk level

        context = [:title] # if we're in the middle of something
        # begins with title so we can have a nice error message if the user doesn't provide one.

        # Elements understood by the parser:
        # [x] :blockquote (physical div)
        # :block (logical div)
        # CANCELLED :action (single line code)
        # :action_block (multiline code)
        # :code (present with code format < 1 line)
        # [x] :code_block (present code style, multiline)
        # :bold (inline strong style)
        # :italic (inline emphasis style)
        # :bold italic (inline strong + emphasis style)
        # [x] :trigger text (button display text)
        # [x] :trigger action (button action)
        # [x] :title (story title)
        # [x] :heading text (chunk heading)
        # [x] :chunk_id (chunk identifier)
        # :paragraph (plain text)
        # [x] preserved line (do not parse line and present as text)
        # [x] comments (stripped and ignored)

        # Example output format
        # {
        #   title: title,
        #   chunks: {
        #     chunk_id: "#id"
        #     content: [
        #       {
        #         type: :heading,
        #         text: "heading"
        #       },
        #       {
        #         type: rule,
        #       },
        #       {
        #         type: paragraph,
        #         atoms: [
        #           {
        #             text: "abc",
        #             styles: []
        #           }
        #         ]
        #       }
        #     ]
        #   }
        # }
        
        story_file.each_line.with_index do |line, line_no|
          # putz "# #{line_no}: #{line.strip}" 

          ### PRESERVE LINE (^%) and stop parsing it
          result = parse_preserve_line(line, context)
          if result
            story[:chunks][-1][:content] << {
                type: :paragraph,
                atoms: [
                  {
                    text: result,
                    styles: []
                  }
                ]
              }
              next
          end

          ### STRIP COMMENT (//) and continue parsing line
            result = parse_comment(line, context)
            line = result if result

          ### TITLE
          result = parse_title(line, context)
          if result 
            story[:title] = result
            context.delete(:title) # title is found
            context << :heading  # second element must be a heading
            # no further processing on this line
            next
          end

          ### BLOCKQUOTE
          result = parse_blockquote(line)
      
          if result && !result.empty?
            context << :blockquote
            story[:chunks][-1][:content] << {
              type: :blockquote,
              text: result,
            }
            next
          end

          ### HEADING LINE

          # unless (context.intersection([:code_block])).any?
            result = parse_heading(line, context)
            if result
              heading, chunk_id = result
              putz result
              if heading.empty? && chunk_id.nil?
                raise "Forked: Expected heading and/or ID on line #{line_no + 1}."
              end

              heading = story.title if heading.empty?

              story[:chunks] << {
                id: chunk_id,
                actions: [],
                content: [
                  {
                    type: :heading,
                    text: heading
                  },
                  {
                    # TODO: This should be in the story file
                    # or the display and not here.
                    type: :rule
                  }
                ]
              }

              # context.delete(:heading)

              next
            end
          # end

          if context.include?(:heading) && !line.strip.empty?
            # we were looking for a heading and didn't find one
            raise "FORKED: CONTENT BEFORE FIRST HEADING.

Forked expects to find a heading before finding any content. 
Please add a heading line after the title and before any other content. Example:

`## The First Chapter {#start}`
"
          end

          ### TRIGGER

          unless (context & [:code_block]).any?
             if (result = parse_trigger(line))
              text, action = result
              story[:chunks][-1][:content] << {
                type: :button,
                text: text,
                action: action || ''
              }
              next
            end
          end

          ### CODE BLOCK
          result = parse_code_block(line, context, story)
          next if result

          ### ACTION BLOCK
          result = parse_action_block(line, context, story)
          next if result

          # PARAGRAPH
          unless context.intersection([:title]).any?
            if (result = parse_paragraph(line))
              unless result.empty?
                story[:chunks][-1][:content] << {
                  type: :paragraph,
                  atoms: [
                    text: result[0],
                    styles: []
                  ]
                }#
              end
            end
          end

          line.each_char.with_index do |char, char_no|
            # # "char #{char_no}: #{char}" if line_no == 0
          end

          # need to go character by character from start of line.
          
          # > at start of line
          # context is blockquote
          # unless context block
          # unless context code
          # unless any context?
          # unless context format

          # ` at start of line
          # context is short code chunk action
          # unless context is blockquote
          # unless context is long code
          # unless context is code format

          # ``` at start of line
          # context is long code chunk action
          # unless context is blockquote
          # unless context is short code
          # unless contect code format

          # <` at any point in line
          # context is block
          # context is short code
          # unless context is blockquote
          # unless context is short code
          # unless context is long code
          # unless context is short code format
          # unless context is long code format


        #   ### ACTIONS (` and ```)
        #   result = parse_action(line)

        #   ### BLOCK CONTEXT (< | >)
        #   result = parse_block(line)
        #   ### TITLE (^#)
        #   result = parse_title(line)

        #   if result && content[:title].nil?
        #     content[:title] = result
        #   end



        end
        putz "Context: #{context}"
        story
      end

      # check to see if it is safe to proceed based on
      # context rules
      def context_safe?(context, prohibited, mandatory)
        context_prohibited = array_intersect?(context, prohibited)
        context_mandatory = mandatory.empty? ||  array_intersect?(context, mandatory) 

        # putz "context_prohibited #{context_prohibited}"
        # putz "context_mandatory  #{context_mandatory}"

        context_mandatory && !context_prohibited
      end

      # true if arr1 and arr2 contain any overlapping elements
      def array_intersect?(arr1, arr2)
        arr1.intersection(arr2).any?
      end

      # Force a line to display as plain, unformatted text, ignoring any further markup
      # Used for troubleshooting, not part of the specification
      def parse_preserve_line(line, context)
        return unless line.strip.start_with?('%')

        prohibited_contexts = [:title]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)
        
        line.delete_prefix('%')
      end

      def parse_paragraph(line)
        line.strip!

        line.split('\n')
      end

      # strip comments from line (comments begin with //)
      def parse_comment(line, context)
        return unless line.include?('//')

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.include?(' //')
          index = line.index(' //')
          return line[0...index]
        elsif line.strip.start_with?('//')
          return ''
        end

        nil
      end

      def parse_blockquote(line)
        # blockquotes must begin the line with >
        # The blockquote will continue until there
        # is a line that does not begin with >
        if line.strip.start_with?('>')

          line.delete_prefix!('>')
          return line
        end
      end

      # Code blocks format code for display
      # They begin with three ticks ``` on a blank line
      # and end with three ticks on a blank line
      def parse_code_block(line, context, story)
        if line.include? '```'
          if context.include?(:code_block)
            context.delete(:code_block)
          else
            context << (:code_block)
            story[:chunks][-1][:content] << {
              type: :code_block,
              text: ''
            }
          end
          true
        elsif context.include?(:code_block)
          story[:chunks][-1][:content][-1].text += line
          true
        end
      end

      # Code blocks format code for display
      # They begin with three ticks ``` on a blank line
      # and end with three ticks on a blank line
      def parse_action_block(line, context, story)
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

      # def parse_action(line)
      #   # actions are surrounded with ` ` for one line code
      #   # or with ``` ``` for multiline code

      #   # if we meet an opening ``` with no closure in the same line,
      #   # open a context and keep reading lines until the ``` appears.

      #   # if no ``` appears by the end of the chunk, terminate it or
      #   # raise an error.

      #   # DON'T catch it if:
      #   # line starts with %
      #   # escaped (\```)
      #   # Inside a code formatted block (~~~)

      #   if line.include?('```')
      #     # # line
      #   end

      # end

      def parse_block(line)
        # blocks start with <
        # blocks are divided with |
        # blocks end with >
        
        # anything in these lines an any line between uses the same action
        # so it has to be applied everywhere

      end

      # The title is required. No content can come before it.
      # The Title line starts with a single #
      def parse_title(line, context)
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
      end

      # The heading line starts a new chunk
      # The heading line begins with a double #
      def parse_heading(line, context)
        return unless line.strip.start_with?('##') && !line.strip.start_with?('###')

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        context.delete(:heading)
        # raise "CONTEXT ERROR. Context should be empty but context is #{context}" unless context.empty?

        line.strip!
        line.delete_prefix!('##').strip!

        if line.include?('{') && line.include?('}')
          line = pull_out('{', '}', line)
        else
          line = [line]
        end

        line
      end

      def parse_trigger(line)
        # triggers are in two parts
        # [trigger_text](trigger_action)
        # Triggers can have empty actions
        # Triggers can have empty text
        # Triggers can't have empty both

        if line.strip.start_with?('[') && line.strip.end_with?(')') && line.include?('](')
          line.strip!
          line.delete_prefix!('[')
          line.delete_suffix!(')')
          line.strip!
          line = line.split('](')
        end
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