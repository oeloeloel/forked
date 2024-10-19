module Forked
  # Forked story file parser
  class Parser
    class << self
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

            if context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
              story[:chunks][-1][:content][-1][:condition_segment] = @condition_segment_count
            end

            ### identify and catch chunk id action (return)
            # if action.end_with?(')')
            if action.include?(')')
              action.delete_prefix!('(')
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

      def make_trigger_hash
        {
          type: :button,
          text: '',
          action: ''
        }
      end
    end
  end
end
