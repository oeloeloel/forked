module Forked
  # Forked story file parser
  class Parser
    class << self
      def parse_image(line, context, story, line_no)
        prohibited_contexts = [:code_block, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        if line.strip.start_with?('\![')
          line.delete_prefix!('\\')
          return
        end

        # first identify image, capture alt text and path
        if line.strip.start_with?('![') && 
           line.include?('](') &&
           line.strip.end_with?(')')

          line = line.strip.delete_prefix!('![')

          line.split(']', 2).then do |alt, path|
            alt.strip!
            path.strip!

            # this content is conditional? add the condition to the current element

            if context.include?(:condition_block) || context.include?(:condition_block)
              condition = story[:chunks][-1][:conditions][-1]
              story[:chunks][-1][:content][-1][:condition] = condition
              story[:chunks][-1][:content][-1][:condition_segment] = @condition_segment_count
            end

            ### identify and catch url (return)
            path.delete_prefix!('(')
            path.delete_suffix!(')')
            
            img = make_image_hash
            img[:path] = path
            story[:chunks][-1][:content] << img
          end
        end
      end 
      
      def make_image_hash
        {
          type: :image,
          path: ''
        }
      end
    end
  end
end