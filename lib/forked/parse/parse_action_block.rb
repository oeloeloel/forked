module Forked
  # Forked story file parser
  class Parser
    class << self
      def parse_action_block(escaped, line, context, story, line_no)
        prohibited_contexts = [:code_block, :trigger_action, :condition_block]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)
        return unless escaped.start_with?('::') ||
          context.include?(:action_block)

        if escaped.start_with? '::'
          # capture single line action
          if line.strip.start_with?(':: ') && line.strip.end_with?(' ::') && line.length > 3
            line.strip!
            line.delete_prefix!(':: ')
            line.delete_suffix!(' ::')
            line.strip!
            if story[:chunks][-1]
              story[:chunks][-1][:actions] << line
            else # different behaviour for code that comes between the title and the first chunk
              story[:actions] ||= []
              story[:actions] << line
            end
            return true
          end

          # capture action block end/start (close/open context)
          if context.include?(:action_block)
            context.delete(:action_block)
          elsif story[:chunks][-1] 
            context << (:action_block)
            story[:chunks][-1][:actions] << ''
          else # different behaviour for code that comes before the first chunk
            context << (:action_block)
          end

          return true

        # capture action block content
        elsif context.include?(:action_block)
          if story[:chunks][-1] 
            destination = story[:chunks][-1][:actions][-1]
            
            if destination.nil?
              raise "FORKED: An action block is open but no action exists in the current chunk.\n"\
                    "Check for an unterminated action block (::) around or before line #{line_no + 1}."
            end
            story[:chunks][-1][:actions][-1] += line
          else # different behaviour for code that comes before the first chunk
            story[:actions] ||= []
            story[:actions] << line
          end
          return true
        end
      end
    end
  end
end