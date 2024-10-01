module Forked
  # Forked story file parser
  class Parser
    class << self
      # The title is required. No content can come before it.
      # The Title line starts with a single #
      def parse_title(line, context, story, _line_no)

        prohibited_contexts = []
        mandatory_contexts = [:title]
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('#') && !line.strip.start_with?('##')
          line.strip!
          line.delete_prefix!('#').strip!
        elsif !line.strip.empty?
          raise "FORKED: CONTENT BEFORE TITLE.

The first line of the story file is expected to be the title.
Please add a title to the top of the Story File. Example:

`# The Name of this Story`
"
        end
        story[:title] = unescape(line, @escapable)
        context.delete(:title) # title is found
        context << :heading # second element must be a heading
        true
      end
    end
  end
end