module Forked
  class Parser
    class << self

      # trigger set wraps triggers
      # only valid triggers, spaces and backslashes are allowed in a trigger set
      # anything else should be ignored
      def parse_trigger_set(escaped, line, context, story, line_no, story_lines)
        prohibited_contexts = [:code_block, :trigger_action, :condition_block]
        return unless context_safe?(context, prohibited_contexts)

        # quick exit
        return unless escaped.strip.start_with?('[') || context.include?(:trigger_set)

        match_start = '['
        match_end   = ']'

        # # putz "line #{line_no + 1} #{line}"

        # is a trigger set opening? (Or is it just a button opening?)
        # if line contains `](`, there is a button on this line AND
        # if the line (with spaces removed) does not start with a `[[` PAIR, this just a button
        return if escaped.include?('](') && !escaped.delete(' ').start_with?('[[')

        result = parse_opening_trigger_set(line, match_start, context)
        # putz "opening result: #{[result]}"
        # putz "OPEN THE SET!" if result

        result = parse_closing_trigger_set(line, match_end, context)
        # putz "closing result: #{[result]}"
        # putz "CLOSE THE SET!" if result

        
      end

      def parse_opening_trigger_set(line, match_start, context)
        # putz "==== parse_opening_trigger_set #{context}"
        return if context.include?(:trigger_set)

        # remove leading space and initial `[` from line
        result = split_at_first_unescaped_instance(line, match_start)
        # putz result

        # return false if match does not exist (at this point, this is not really needed)
        return unless result

        # open context
        context << :trigger_set

        # if match is followed, return string right of match
        # if match is not followed, we're done, return true
        return result[1].strip.empty? ? true : result[1]
      end

      def parse_closing_trigger_set(line, match_end, context)
        # putz "==== parse closing trigger set #{context}"
        # return nil if line does not include match or context is not correct
        return if !line.include?(match_end) || !context_safe?(context, [], [:trigger_set])

        # check for closing set
        result = split_at_first_unescaped_instance(line, match_end)
        # return nil if match_end is not found
        return unless result

        # putz "CLOSING TRIGGER SET #{result}"
        context.delete(:trigger_set)
        # # if match is preceded by text (code or segment)
        # if !result[0].strip.empty?
        #   # unshift the right into the lines array
        #   # and fix the line number to accomodate the change

        #   # unshift match start + right text to lines array (if right text is not blank)
        #   unshift_to_line_array(story_lines, ":> #{result[1]}") #unless result[1].strip.empty?
        
        #   # return array [left of match, match + right of match]
        #   return result

        return true
      end
    end
  end
end