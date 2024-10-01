module Forked
  # Forked story file parser
  class Parser
    class << self
      def parse_code_fence(line, context, story, line_no)
        return unless line.include?('```') 
        
        prohibited_contexts = [:code_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        return true
      end
    end
  end
end