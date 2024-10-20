require_relative 'parse_action_block'
require_relative 'parse_blank'
require_relative 'parse_blockquote'
require_relative 'parse_c_comment'
require_relative 'parse_code_block'
require_relative 'parse_code_fence'
require_relative 'parse_conditional'
require_relative 'parse_callout'
require_relative 'parse_heading'
require_relative 'parse_html_comment'
require_relative 'parse_image'
require_relative 'parse_paragraph'
require_relative 'parse_preformatted_line'
require_relative 'parse_rule'
require_relative 'parse_title'
require_relative 'parse_trigger'

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
        @escapable = make_escapable_list
        story_lines = story_file.lines
        line_no = -1
        @increment_line_no = true

        while (line = story_lines.shift)
          line_no += 1 if @increment_line_no
          @increment_line_no = true
          # puts "#{line_no + 1}: #{line.strip}" unless line.strip.empty?

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
          result = parse_image2(escaped, context, story, line_no)
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

          # ### PARSE CALLOUT
          result = parse_callout(escaped, line, context, story, line_no, story_lines)
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

          # PARAGRAPH
          parse_paragraph2(escaped, context, story, line_no)

          # MEANINGFUL BLANK LINE
          result = parse_blank(line, context, story, line_no)
          next if result
        end

        story
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
          return unless (idx = haystack.index(needle, offset))

          backcheck = haystack[offset...idx].reverse
          reps = char_reps(backcheck, '\\')
          return idx unless reps.odd?

          offset = idx + 1
        end
      end

      def l_split(line, delimiter)
        return unless (idx = line.index(delimiter))

        [line[0...idx], line[idx + delimiter.length...line.length]]
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
          content: [],
          parse_actions: []
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

      def make_style_marks
        [
          { symbol: :bold_italic, mark: "***" },
          { symbol: :bold_italic, mark: "___" },
          { symbol: :bold, mark: "**" },
          { symbol: :bold, mark: "__" },
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
          '~' # code block
        ]
      end

      # ==================================================
      # COMMON PARSER METHODS
      # --------------------------------------------------

      # deletes all elements in context that exist in close
      # mutates the context array
      # this will remove ALL matching elments
      def close_context(context, close = [])
        context.reject! { |c| close.include? c }
      end

      # adds all elements in close to context
      # mutates the context array
      # does not prevent duplicate values
      def open_context(context, open = [])
        context.concat(open)
      end

      # get_last_element_type
      # discover the type of the element that was most recently
      # pushed to the chunk content array
      # return
      #   symbol `type`
      #   nil if the type is not found
      def last_element_type(story)
        last_element(story)[:type]
      end

      # get_last_element
      # get the element that was most recently
      # pushed to the story array
      # TODO: Does this need to change to be like last_content?
      def last_element(story)
        last_element = story&.chunks&.[](-1)&.content&.[](-1)
        sub_element = last_element&.content&.[](-1)
        return sub_element if sub_element

        last_element
      end

      # returns the most recently added contents array
      # which could be the contents attached to the
      # currently open chunk, or could be the contents
      # of the most recently added element
      def last_content(story, context)
        last = story&.chunks&.[](-1)&.content
        sub_content = last&.[](-1)&.content

        if !context.include?(:callout) &&
           !context.include?(:blockquote)

          last
        else
          sub_content
        end
      end

      # add a string to the front of the line array
      # prevents line number count from incrementing
      # so line number reporting is not affected
      def unshift_to_line_array(line_array, string)
        line_array.unshift(string)
        @increment_line_no = false
      end

      # splits a string (haystack) around a string (needle)
      # returns an array with two strings
      # left and right of the split
      # left or right may be empty if the split begins or ends a line
      # returns nil if needle does not exist in haystack
      def split_at_first_unescaped_instance(haystack, needle)
        return unless haystack.include?(needle)

        first_match = find_first_non_escaping_instance(haystack, needle)
        return unless first_match

        [
          haystack[0...first_match],
          haystack[first_match + needle.length..]
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
        arr.each { |chr| str = escape_char(str, chr) }
        str
      end

      # unescapes all instances of characters in array that exist in str
      def unescape(str, arr)
        arr.each { |chr| str = unescape_char(str, chr) }
        str
      end

      # given a string str and string delimiters left and right
      # returns an array containing
      # [0] the content of the string to the left of the left delimiter + the content
      # of the string to the right of the right delimiter
      # [1] the content of the string between the left and right delimiters
      # If either or both delimiters are not found, [0] will be an empty string and [1]
      # will contain the original str
      def pull_out(left, right, str)
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
      def left_of_string(str, delimiter)
        return unless (index = str.index(delimiter))

        str.slice(0, index)
      end

      # given a string str and a string delimiter
      # returns the portion of str following the delimiter
      # returns nil if the delimiter is not found
      def right_of_string(str, delimiter)
        return unless (index = str.index(delimiter))

        index += delimiter.length
        str.slice(index, str.length)
      end
    end
  end
end

$gtk.reset
$story = nil
