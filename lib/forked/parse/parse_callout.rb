module Forked
  # forked parser
  class Parser
    class << self

      ##########
      # CALLOUT
      # =========
      # example: callout
      # Text only
      # <? callout ?? An important message! ?>

      # Image and text:
      # <? callout ??
      #   ![](sprites/biohazard.png)
      #   An important message!
      # ?>

      # Text and image:
      # <? callout ??
      #   ![](sprites/biohazard.png)
      #   An important message!
      # ?>

      # Image must be at start or end of content
      # Images that are not at the start or end will be ignored
      # Only one image is supported, other images will be ignored
      # Only image and text (with inline styles) are supported
      # Embedding other elements within callouts may have unpredictable results


      # parse callout block opening, closing, code section, segments
      def parse_callout(_escaped, line, context, story, _line_no, story_lines)
        return unless context_safe?(context, %i[code_block action_block])

        match_start = '<?'
        match_separator = '??'
        match_end = '?>'

        # check for and handle an opening
        # if open is found on line AND NOTHING ELSE, return true
        # if open is found and there is a left string, return result ([left, right])
        # if open is found and text follows, return right
        # if open is not found, return is nil
        result = parse_opening_callout(line, match_start, context, story, story_lines)
  
        case result
        when Array # opening was found but text comes first
          return result[0]
        when String # open was found, with more on line, continue
          line = result
        when true # open found, nothing else on line, we're done
          return result
        end

        return unless context.include? :callout

        result = parse_opening_callout_segment(line, match_separator, context, story_lines)
        case result
        when TrueClass
          return result
        when String
          line = result
        when Array
          line = result[0]
          # don't return or block doesn't get processed
        end

        # check for and handle a closing
        result = parse_closing_callout(line, match_end, context, story, story_lines)
        case result
        when Array # content before close, continue with result[0]
          line = result[0]
        when String # if interpolation is happening, string will be the inter tag and we can stop
          return result if result == "«««INTER»»»"

          line = result
        when TrueClass # processed, finished
          return result
        when NilClass
          # didn't find a closing, continue to parse for code
        end

        if context.include?(:callout_code_block)
          result = parse_callout_code(line, context, story)
          case result
          when TrueClass
            return result
          end
        end

        line
      end

      # when we are inside the code block
      # add lines to the chunk's cond_itions array at the last element
      # this code is not applied until the code block is complete
      def parse_callout_code(line, context, story)
        return unless context.include?(:callout_code_block)
        return if line.strip.empty?

        # add the line to the chunk's cond_itions
        story[:chunks][-1][:parse_actions][-1] += line

        last_element(story).type = line.strip.to_sym

        # stop processing this line
        true
      end

      # detects and handles opening block
      # handles text before and after opening block
      # opens contexts
      # returns array [left, match_start + right] if text is found before match_start
      # returns string if match_start is found with text from right
      # returns true if match_start is found with no other text
      # returns nil if match_start is not found
      def parse_opening_callout(line, match_start, context, story, story_lines)
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

      # parse_closing_callout
      # detects and handles callout closing (match_end)
      #   handles text before match end (code or segment)
      #   handles text after match end (paragraph)
      #   closes contexts
      # returns:
      #   nil if match not found
      #   true if match found with nothing else on line
      #   string (right text) if text after match
      #   array [left text, match_end + right text] if text before match
      def parse_closing_callout(line, match_end, context, _story, story_lines)
        # return nil if line does not include match or context is not correct
        return if !line.include?(match_end) || !context_safe?(context, [], [:callout])

        # check for closing callout block
        result = split_at_first_unescaped_instance(line, match_end)
        # return nil if match_end is not found
        return unless result

        # if match is preceded by text (code or segment)
        unless result[0].strip.empty?
          # unshift the right into the lines array
          # and fix the line number to accomodate the change

          # unshift match start + right text to lines array (if right text is not blank)
          unshift_to_line_array(story_lines, "#{match_end} #{result[1]}") # unless result[1].strip.empty?

          # return array [left of match, match + right of match]
          return result
        end

        # if anything follows match_end, process it on the next loop
        unshift_to_line_array(story_lines, result[1]) unless result[1].strip.empty?

        # if block is open
        # return the interpolation mark
        if context.include?(:callout_code_block)
          close_context(
            context,
            %i[
              callout
              callout_code_block
              callout_segment
              paragraph
            ]
          )
          return '«««INTER»»»'
        end

        # close all callout block contexts
        close_context(
          context,
          %i[
            callout
            callout_code_block
            callout_segment
            paragraph
          ]
        )

        # why are we clearing this now? TODO
        @callout_segment_count = nil

        # this line is spent, return true
        true
      end

      def parse_opening_callout_segment(line, match_separator, context, story_lines)
        # check segment opening

        if line.include?(match_separator) &&
           (context.include?(:callout) ||
           context.include?(:callout_segment))

          result = split_at_first_unescaped_instance(line, match_separator)
          # the split was made and
          # there is content to the left of the split
          if result
            if !result[0].strip.empty?
              # there's something before the segment (code?)
              line = result[0]
              # # unshift match_separator + right text to lines array (if right text is not blank)
              unshift_to_line_array(story_lines, "#{match_separator} #{result[1]}") # unless result[1].strip.empty?
              return result[0] if context.include?(:callout_segment)

              return result
            elsif context.include?(:callout_code_block)
              context.delete(:callout_code_block)
              context << :callout_segment
              @callout_segment_count = 0
              unshift_to_line_array(story_lines, result[1].to_s) unless result[1].strip.empty?
              return true
            elsif context.include?(:callout_segment)
              @callout_segment_count += 1
              unshift_to_line_array(story_lines, result[1].to_s) unless result[1].strip.empty?
              return true
            else
              line = result[1]
            end
          end

          line
        end
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

        return last_element
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

      def make_callout_hash
        {
          type: :callout,
          content: []
        }
      end
    end
  end
end
