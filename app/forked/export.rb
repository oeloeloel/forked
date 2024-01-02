
module Forked
  class << self
    def export_spell_check
      story_text = fetch_story
      story_text = clean_text_for_spellcheck(story_text)
      save_spellcheck_file(story_text, "spellcheck.txt")
    end

    def fetch_story
      story_text = $gtk.read_file STORY_FILE

      if story_text.nil?
        raise "The file #{STORY_FILE} failed to load. Please check the filename and path."
      end

      story_text
    end

    def clean_text_for_spellcheck(story_text)
      context = []
      temp = story_text.lines.map_with_index do |l, i|
        # omit empty lines
        next if l.strip.empty?

        # putz "#{i + 1} #{context} #{l}" if i > 3000 && i < 3050

        if context.include?(:condition_block)
          if l.strip.end_with?(':>')
            context.delete(:condition_block) 
            context.delete(:condition_block_condition)
            next
          end
        end

        # ignore/close block contexts
        if context.include?(:code_block)
          context.delete(:code_block) if l.strip.start_with?('~~~')
          next
        elsif context.include?(:condition_block_condition)
          context.delete(:condition_block_condition) if l.strip.start_with?('::')
          next
        elsif context.include?(:button_code_block)
          context.delete(:button_code_block) if l.strip.end_with?(':)')
          next
        elsif context.include?(:action_block)
          context.delete(:action_block) if l.strip.start_with?('::')
          next
        end



        # catch block contexts opening
        if l.strip.start_with?('~~~')
          context << :code_block
          next
        elsif l.strip.start_with?('<:') &&
          context << :condition_block
          context << :condition_block_condition
          next
        elsif l.strip.start_with?("::") && !context.include?(:condition_block)
          context << :action_block
          next
        elsif l.strip.start_with?('[') &&
              l.include?('](') &&
              !l.strip.end_with?(')')
          context << :button_code_block
          l = l.split('](')[0] + "]\n"
        end

        # remove rules
        next if l.strip.start_with?('---')

        # remove chunk ids from chunk headings
        if l.strip.start_with?('##')
          pulled = pull_out('{', '}', l)
          if pulled
            l = pulled[0] 
          end
        end

        # remove targets from single line actions
        if  l.strip.start_with?('[') &&
            l.strip.end_with?(')') &&
            l.include?('](')

          l = l.split('](')[0] + "]\n"
        end

        "#{i + 1}: #{l}"
      end.join
    end

    def save_spellcheck_file(file, path)
      $gtk.write_file(path, file)
    end
  
    def pull_out left, right, str
      left_index = str.index(left)

      if left_index
        right_index = str.index(right, left.length)
      end
      return unless left_index && right_index

      pulled = str.slice!(left_index + left.size..right_index - 1)
      str.sub!(left + right, '')
      [str.strip + "\n", pulled.strip]
    end
  end
end