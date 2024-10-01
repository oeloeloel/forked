module Forked
  # Forked story file parser
  class Parser
    class << self
      # draws a horizontal line
      def parse_rule(line, context, story, line_no)

        return unless line.strip.start_with?('---')

        prohibited_contexts = [:title, :code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        story[:chunks][-1][:content] << make_rule_hash

        # this content is conditional? add the condition to the current element
        if context.include?(:condition_block)  || context.include?(:condition_block)
          condition = story[:chunks][-1][:conditions][-1]
          story[:chunks][-1][:content][-1][:condition] = condition
        end

        true
      end

      def make_rule_hash
        {
          type: :rule,
          weight: 1
        }
      end
    end
  end
end