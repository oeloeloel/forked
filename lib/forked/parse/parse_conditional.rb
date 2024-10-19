module Forked
  # Forked story file parser
  class Parser
    class << self
      # parse condition block opening, closing, code section, segments

      def parse_condition_block2(_escaped, line, context, story, _line_no, story_lines)
        return unless context_safe?(context, [:code_block, :action_block])

        match_start = '<:'
        match_separator = '::'
        match_end = ':>'

        # check for and handle an opening condition
        # if open condition is found on line AND NOTHING ELSE, return true
        # if open condition is found and there is a left string, return result ([left, right])
        # if open condition is found and text follows, return right
        # if open condition is not found, return is nil
        result = parse_opening_condition(line, match_start, context, story, story_lines)
        if result.is_a?(Array) # condition was found but text comes first
          return result[0]
        elsif result.is_a?(String) # condition was found, with more on line, continue
          line = result
        elsif result == true # condition found, nothing else on line, we're done
          return result
        end

        return unless context.include? :condition_block

        result = parse_opening_segment(line, match_separator, context, story_lines)
        case result
        when TrueClass
          return result
        when String
          line = result
        when Array
          line = result[0]
          # don't return or condition doesn't get processed
        end

        # check for and handle a closing condition
        result = parse_closing_condition(line, match_end, context, story, story_lines)
        case result
        when Array # content before close, continue with result[0]
          line = result[0]
        when String # if interpolation is happening, string will be the inter tag and we can stop
          return result if result == "«««INTER»»»"

          line = result
        when TrueClass # processed, finished
          return result
        when NilClass
          # didn't find a closing condition, continue to parse for condition code
        end

        if context.include?(:condition_code_block)
          result = parse_condition_code(line, context, story)
          case result
          when TrueClass
            return result
          end
        end

        line
      end

      # when we are inside the code block
      # add lines to the chunk's conditions array at the last element
      # this condition is not applied until the condition code block is complete
      def parse_condition_code(line, context, story)
        return unless context.include?(:condition_code_block)
        return if line.strip.empty?

        # add the line to the chunk's conditions
        story[:chunks][-1][:conditions][-1] += line

        # stop processing this line
        return true
      end

      # detects and handles opening condition block
      # handles text before and after opening condition block
      # opens contexts
      # returns array [left, match_start + right] if text is found before match_start
      # returns string if match_start is found with text from right
      # returns true if match_start is found with no other text
      # returns nil if match_start is not found
      def parse_opening_condition(line, match_start, context, story, story_lines)
        # return false if match does not exist or if context is wrong
        return if !line.include?(match_start) ||
                  !context_safe?(context, [:condition])

        # check for opening condition block
        result = split_at_first_unescaped_instance(line, match_start)

        # return false if match does not exist (escaped at this point)
        return unless result

        # if match is preceded by text
        if !result[0].strip.empty?
          # unshift match start + right text to lines array (if right text is not blank)
          unshift_to_line_array(story_lines, "<: #{result[1]}") # unless result[1].strip.empty?

          # return array [left of match, match + right of match]
          return result
        end

        # open contexts
        context << :condition_block
        context << :condition_code_block

        # create empty chunk condition for filling later
        story[:chunks][-1][:conditions] << ''

        # if match is followed, return string right of match
        # if match is not followed, we're done, return true

        result[1].strip.empty? ? true : result[1]
      end

      # parse_closing_condition
      # detects and handles condition closing (match_end)
      #   handles text before match end (code or segment)
      #   handles text after match end (paragraph)
      #   closes contexts
      # returns:
      #   nil if match not found
      #   true if match found with nothing else on line
      #   string (right text) if text after match
      #   array [left text, match_end + right text] if text before match
      def parse_closing_condition(line, match_end, context, _story, story_lines)
        # return nil if line does not include match or context is not correct
        return if !line.include?(match_end) || !context_safe?(context, [], [:condition_block])

        # check for closing condition block
        result = split_at_first_unescaped_instance(line, match_end)
        # return nil if match_end is not found
        return unless result

        # if match is preceded by text (code or segment)
        if !result[0].strip.empty?
          # unshift the right into the lines array
          # and fix the line number to accomodate the change

          # unshift match start + right text to lines array (if right text is not blank)
          unshift_to_line_array(story_lines, ":> #{result[1]}")

          # return array [left of match, match + right of match]
          return result
        end

        # if anything follows match_end, process it on the next loop
        unshift_to_line_array(story_lines, result[1]) unless result[1].strip.empty?

        # if condition block is open
        # return the interpolation mark
        if context.include?(:condition_code_block)
          close_context(
            context, [
              :condition_block,
              :condition_code_block,
              :condition_segment
            ]
          )
          return '«««INTER»»»'
        end

        # close all condition block contexts
        close_context(context, [
          :condition_block,
          :condition_code_block,
          :condition_segment
        ])

        # why are we clearing this now? TODO
        @condition_segment_count = nil

        # this line is spent, return true
        return true
      end

      def parse_opening_segment(line, match_separator, context, story_lines)
        # check segment opening
        if line.include?(match_separator) &&
           (context.include?(:condition_block) ||
           context.include?(:condition_segment))

          result = split_at_first_unescaped_instance(line, match_separator)
          # the split was made and
          # there is content to the left of the split
          if result
            if !result[0].strip.empty?
              # there's something before the segment (code?)
              line = result[0]
              # # unshift match_separator + right text to lines array (if right text is not blank)
              unshift_to_line_array(story_lines, ":: #{result[1]}") #unless result[1].strip.empty?
              return result[0] if context.include?(:condition_segment)

              return result
            elsif context.include?(:condition_code_block)
              context.delete(:condition_code_block)
              context << :condition_segment
              @condition_segment_count = 0

              unless result[1].strip.empty?
                unshift_to_line_array(story_lines, "#{result[1]}")
              end
              return true
            elsif context.include?(:condition_segment)
              @condition_segment_count += 1
              unless result[1].strip.empty?
                unshift_to_line_array(story_lines, "#{result[1]}")
              end
              return true
            else
              line = result[1]
            end
          end

          line
        end
      end
    end
  end
end
