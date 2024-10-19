module Forked
  # Forked story file parser
  class Parser
    class << self
      # strip comments from line (comments begin with //)
      def parse_c_comment(line, context)
        return unless line.include?('//')

        prohibited_contexts = [:code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('//')
          return true
        elsif line.include?(' //')
          index = line.index(' //')
          return line[0...index]
        end

        nil
      end
    end
  end
end
