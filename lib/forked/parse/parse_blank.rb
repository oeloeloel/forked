module Forked
  # Forked story file parser
  class Parser
    class << self
      # when a line is totally blank, add it as a `:blank` element
      # only add one :blank - runs of blanks are not meaningful
      # display will ignore the blank
      # display will not treat two of the same block level
      # elements as contiguous if they are separated by a blank
      
      def parse_blank(line, context, story, line_no)
        # apply to blank lines and NO CONTEXT IS OPEN

        return if !line.strip.empty? ||
                  !context.empty?
        
        # check last element type
        prev_type = story&.[](:chunks)[-1][:content]&.[](-1)[:type]

        # blank is meaningful after last element? add it
        # for now, blank is only meaningful after button
        
        case prev_type
        when :button 
          story[:chunks][-1][:content] << make_blank_hash if prev_type == :button
        end
      end
      
      def make_blank_hash
        {
          type: :blank
        } 
      end
    end
  end
end