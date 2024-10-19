module Forked
  # Forked story file parser
  class Parser
    class << self
      # Force a line to display as plain, unformatted text, ignoring any further markup
      # Used for troubleshooting, not part of the specification
      def parse_preformatted_line(line, context, story, _line_no)
        return unless line.strip.start_with?('@@')

        prohibited_contexts = [:title, :code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        line.delete_prefix!('@@')
        para = make_paragraph_hash
        atm = make_atom_hash
        atm[:text] = unescape(line.chomp, @escapable)
        atm[:styles] << :pre
        para[:atoms] << atm
        story[:chunks][-1][:content] << para

        true
      end
    end
  end
end
