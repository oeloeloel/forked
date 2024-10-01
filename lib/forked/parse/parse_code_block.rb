module Forked
  # Forked story file parser
  class Parser
    class << self
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

      def make_code_block_hash
        {
          type: :code_block,
          text: ''
        }
      end
    end
  end
end