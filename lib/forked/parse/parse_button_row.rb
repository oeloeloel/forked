module Forked
  # forked parser
  class Parser
    class << self

      ##########
      # button_row
      # =========
      # example: button_row
      # <? button_row ??
      # [Button 1](#)
      # [Button 2](#)
      # [Button 3](#)
      # ?>

      # should display as a row of buttons, evenly spaced and centered.
      # If the button row exceeds the display area, it should wrap onto a new row.
      # All rows should be centered

      # Anything other than button stuff is ignored

      # parse button_row block opening, closing, code section, segments
      def parse_button_row(_escaped, line, context, story, _line_no, story_lines)
        # "==== def parse_button_row(_escaped, line, context, story, _line_no, story_lines)"
        return unless context_safe?(context, %i[code_block action_block])

        match_end = '?>'
        return unless context.include? :button_row

        # check for and handle a closing
        result = parse_closing_button_row(line, match_end, context, story, story_lines)
        return true if result == true

        result = parse_contained_trigger(line, context, story, _line_no)
        story[:chunks][-1][:content][-1][:content] << result if result.is_a?(Hash) && result[:type] == :button
        return true
      end

      def parse_contained_trigger(line, context, story, line_no)
        prohibited_contexts = %i[code_block action_block condition_code_block]
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
            # if this content is conditional, add the condition to the current element

            if context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
              story[:chunks][-1][:content][-1][:condition_segment] = @condition_segment_count
            end

            ### identify and catch chunk id action (return)
            if action.include?(')')
              action.delete_prefix!('(')
              action = action[0...action.rindex(')')]

              if action.start_with?('#') || action.strip.empty?
                # capture simple navigation
                trg.action = action
                return trg
              elsif action.start_with?(': ') && action.end_with?(' :')
                # capture single line trigger action
                action.delete_prefix!(': ')
                action.delete_suffix!(' :')
                # a kludge that identifies a Ruby trigger action from a normal action
                # so actions that begin with '#' are not mistaken for navigational actions
                action = '@@@@' + action
                trg.action = action
                return trg
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
        elsif context.include?(:trigger_action)
          if story[:chunks][-1][:content][-1].action.empty?
            # a kludge that identifies a Ruby trigger action from a normal action
            # so actions that begin with '#' are not mistaken for navigational actions
            line = '@@@@' + line
          end
          story[:chunks][-1][:content][-1].action += line
          return true
        end
      end


      # parse_closing_button_row
      # detects and handles button_row closing (match_end)
      #   handles text before match end (code or segment)
      #   handles text after match end (paragraph)
      #   closes contexts
      # returns:
      #   nil if match not found
      #   true if match found with nothing else on line
      #   string (right text) if text after match
      #   array [left text, match_end + right text] if text before match
      def parse_closing_button_row(line, match_end, context, _story, story_lines)
        # return nil if line does not include match or context is not correct
        return if !line.include?(match_end) || !context_safe?(context, [], [:button_row])

        # check for closing button_row block
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
        if context.include?(:button_row_code_block)
          close_context(
            context,
            %i[
              button_row
              button_row_code_block
              button_row_segment
              paragraph
            ]
          )
          return '«««INTER»»»'
        end

        # close all button_row block contexts
        close_context(
          context,
          %i[
            button_row
            button_row_code_block
            button_row_segment
            paragraph
          ]
        )

        # why are we clearing this now? TODO
        @button_row_segment_count = nil

        # this line is spent, return true
        true
      end

      def make_button_row_hash
        {
          type: :button_row,
          content: []
        }
      end
    end
  end
end