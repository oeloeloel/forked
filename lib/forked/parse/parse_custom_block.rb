module Forked
  # Display class
  class Parser
    class << self
      def parse_custom_block(escaped, line, context, story, line_no, story_lines)
        return if line.strip.empty?
        return unless context_safe?(context, %i[condition_code_block code_block action_block])

        # is there an opening custom block? Get its name and add it to the custom blocks list
        element_name = parse_custom_block_opening(escaped, line, context, story, line_no, story_lines)
        # if the element name is matched, we're done here and can return true (consume line)
        return true if element_name

        # if no custom blocks have been detected yet, @custom_blocks will be empty, we can return nil
        return unless @custom_blocks.size > 0

        # loop through all custom blocks and send to parser
        @custom_blocks.each do |name|
          method_name = get_custom_parser_name(name)
          result = method(method_name).call(escaped, line, context, story, line_no, story_lines)
          return true if result == true # if true is returned, return true to parse
        end

        nil
      end

      def parse_custom_block_opening(escaped, line, context, story, line_no, story_lines)
        # puts "==== def parse_custom_block_opening(escaped, line, context, story, line_no, story_lines)"

        element_name = register_custom_element(line)
        return unless element_name

        # open context
        # context << :callout
        context << (element_name.to_sym)

        # create empty parse_actions for filling later
        story[:chunks][-1][:parse_actions] << ''

        # create empty container for filling later
        story[:chunks][-1][:content] << make_custom_block_hash(element_name.to_sym)

        # if match is followed, return string right of match
        # if match is not followed, we're done, return true
        # result[1].strip.empty? ? true : result[1]
        return element_name
      end

      def get_custom_parser_name(element_name)
        "parse_#{element_name}".to_sym
      end

      def get_custom_element_name(line)
        match_1 = '<?'
        match_2 = '??'

        (detect_and_strip_prefix_suffix(line.strip, match_1, match_2))&.strip 
      end

      def custom_block_list
        @custom_blocks
      end

      def register_custom_element(line)
        @custom_blocks ||= []
        element_name = get_custom_element_name(line)
        if element_name
          method_name = get_custom_parser_name(element_name)
          unless Parser.methods.include?(method_name)
            raise "Method Name `#{method_name}` does not exist."
          end
          @custom_blocks |= [element_name.to_sym]
        end
        element_name
      end

      def detect_and_strip_prefix_suffix(line, match_start, match_end)
        return if !line || line.empty?

        line.strip!
        line = detect_and_strip_prefix(line, match_start)
        return if !line || line.empty?

        line = detect_and_strip_suffix(line, match_end)
        return if !line || line.empty?

        line
      end

      def detect_and_strip_prefix(line, match_start)
        if line.start_with?(match_start)
          return line.delete_prefix(match_start)
        end
      end

      def detect_and_strip_suffix(line, match_end)
        if line.end_with?(match_end)
          return line.delete_suffix(match_end)
        end
      end

      # detects and handles opening block
      # handles text before and after opening block
      # opens contexts
      # returns array [left, match_start + right] if text is found before match_start
      # returns string if match_start is found with text from right
      # returns true if match_start is found with no other text
      # returns nil if match_start is not found
      def parse_opening_generic(line, match_start, context, story, story_lines)
        # "==== def parse_opening_generic(line, match_start, context, story, story_lines)"
        # return false if match does not exist or if context is wrong
        return if !line.include?(match_start) ||
                  !context_safe?(context, [:callout])

        # check for opening block
        result = split_at_first_unescaped_instance(line, match_start)

        # return false if match does not exist (escaped at this point)
        return unless result

        # if match is preceded by text
        unless result[0].strip.empty?
          # unshift match start + right text to lines array (if right text is not blank)
          unshift_to_line_array(story_lines, "<: #{result[1]}") # unless result[1].strip.empty?

          # return array [left of match, match + right of match]
          return result
        end

        # open contexts
        context << :callout
        context << :callout_code_block

        # create empty parse_actions for filling later
        story[:chunks][-1][:parse_actions] << ''

        # create empty callout container for filling later

        # last_content(story, context) << make_callout_hash
        story[:chunks][-1][:content] << make_callout_hash

        # if match is followed, return string right of match
        # if match is not followed, we're done, return true
        result[1].strip.empty? ? true : result[1]
      end

      def make_custom_block_hash(element_type)
        {
          type: element_type,
          content: []
        }
      end
    end
  end
end