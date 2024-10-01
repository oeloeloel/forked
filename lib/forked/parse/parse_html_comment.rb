module Forked
  # Forked story file parser
  class Parser
    class << self
      def parse_html_comment(line, context, line_no)
        prohibited_contexts = [:code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return line unless context_safe?(context, prohibited_contexts, mandatory_contexts) 

        left_mark = '<!--'
        right_mark = '-->'

        # catch inline or single line html comment

        if line.include?(left_mark) && line.include?(right_mark)
          line = (pull_out(left_mark, right_mark, line))[0]
          return line unless line.empty?

          return nil
        end

        # start html comment (return non-comment part of line)
        if line.include?(left_mark)
          context << (:comment)
          line = left_of_string(line, left_mark)
          return nil if line.strip.empty?
        end

        # end html comment (return non-comment part of line)
        if line.include?(right_mark) && context.include?(:comment)
          context.delete(:comment)
          line = right_of_string(line, right_mark)
          return nil if line.strip.empty?
        end

        # while comment is open
        if context.include?(:comment)
          return nil
        end

        line
      end
    end
  end
end