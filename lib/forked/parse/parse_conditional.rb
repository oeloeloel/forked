module Forked
  class Parser
    class << self

      # parse condition block opening, closing, code section, segments

      def parse_condition_block2(escaped, line, context, story, line_no, story_lines)
        return unless context_safe?(context, [:code_block, :action_block])


        # putz "=== parse_condition_block2(escaped, line, context, story, line_no, story_lines)"
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
        else
          # condition was not found on line
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

        return line
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

        return result[1].strip.empty? ? true : result[1]
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
      def parse_closing_condition(line, match_end, context, story, story_lines)
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
          unshift_to_line_array(story_lines, ":> #{result[1]}") #unless result[1].strip.empty?

          # return array [left of match, match + right of match]
          return result
        end

        # if anything follows match_end, process it on the next loop
        unshift_to_line_array(story_lines, result[1]) unless result[1].strip.empty?

        # if condition block is open
        # return the interpolation mark
        if context.include?(:condition_code_block)
          close_context(context, [
          :condition_block, 
          :condition_code_block, 
          :condition_segment
        ]) 
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

      # ==================================================
      # COMMON PARSER METHODS
      # --------------------------------------------------
      
      # deletes all elements in context that exist in close
      # mutates the context array
      # this will remove ALL matching elments 
      def close_context(context, close = [])
        context.reject! {  |c| close.include? c}
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
      def get_last_element_type(story)
        get_last_element(story)[:type]
      end

      # get_last_element
      # get the element that was most recently
      # pushed to the chunk content array
      # return
      #   element
      #   nil if the element is not found
      def get_last_element(story)
        last_chunk = story&.chunks&.[](-1)

        story[:chunks][-1][:content][-1]
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
          haystack[first_match + needle.length..-1]
        ]
      end
      # --------------------------------------------------

      # ==================================================
      # REPLACING THIS OLD CODE
      # --------------------------------------------------
      
      # condition blocks allow for conditional text
      # NEW SYNTAX
      # They begin with a left angle bracket followed by a colon
      # and end with a colon followed by a right angle bracket
      # The current functionality is to conditionally include text
      # returned from the block as a string
      def parse_condition_block(escaped, line, context, story, line_no, story_lines)

        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        # todo: detect and split *inline* condition into multi-line

        # detect and split single line condition into multi-line
        # result = expand_single_line_condition(escaped, line, context, story, line_no, story_lines)
        # if result
        #   line = story_lines.shift 
        #   escaped = escape(line, @escapable)
        # end

        # DETECT OPENING CONDITION BLOCK
        # opening condition block context and condition code context
        if line.strip.end_with?('<:')
          # open condition block context
          context << :condition_block
          # open condition code block context
          context << :condition_code_block
          # add a new condition to the chunk
          story[:chunks][-1][:conditions] << ''
          # stop processing this line (ignore any following text)
          return true
        end

        # closing both condition code context and condition block context
        if line.strip.start_with?(':>')
          # if the last element is a paragraph and
          # if the paragraph context is open, add to it
          # only for interpolation
          if  story[:chunks][-1][:content][-1].type == :paragraph && 
              context.include?(:paragraph) &&
              context.include?(:condition_code_block)
              # most recent element is a paragraph and the paragraph context is open
              # FIXME: this is creating a bogus extra entry.
              # It's supposed to be able to continue a paragraph but it's
              # getting triggered for new paragraphs in addition to the
              # correct code.

              atm = make_atom_hash
              atm[:condition] = story[:chunks][-1][:conditions][-1]
              # story[:chunks][-1][:content][-1][:atoms] << atm

              # story[:chunks][-1][:content][-1][:atoms]
              if context.include?(:condition_code_block)
   
              context.delete(:condition_block)
              context.delete(:condition_code_block)
              return :interpolation
            end
          elsif context.include?(:condition_code_block)
            context.delete(:condition_block)
            context.delete(:condition_code_block)
            return :interpolation
          end

          # close conditon block and condition code block contexts
          context.delete(:condition_block)
          context.delete(:condition_code_block)
          context.delete(:condition_segment)
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
        if line.strip == '::'
          if context.include? :condition_code_block
            context.delete(:condition_code_block)
            context << (:condition_segment)
            @condition_segment_count = 0
            return true
          elsif context.include? :condition_segment
            @condition_segment_count += 1
          return true
          end
        end

        # capture contents of condition code block
        if context.include?(:condition_code_block)
          story[:chunks][-1][:conditions][-1] += line
          return true
        end

        # nil return allows conditional content to be handled by other parsers
      end

      def expand_single_line_condition(escaped, line, context, story, line_no, story_lines)
        if escaped.strip.start_with?('<: ') && escaped.strip.end_with?(' :>')
          line.strip!
          line.delete_prefix!('<:').delete_suffix!(':>')
          line.strip!
          return if line.empty?
          
          arr = ['<:']
          line_split = line.split(' :: ')
          line_split.each_with_index do |seg, i|
            next_element = i < line_split.size - 1 ? "::\n" : ":>\n"
            arr += [seg + "\n", next_element]
          end

          story_lines.insert(0, *arr)

          return true
        end
      end
    end
  end
end