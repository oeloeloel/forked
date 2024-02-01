
module Forked
  class << self

    ### =================
    ### Export Story JSON
    ### =================

    def export_story_as_json
      $__ll_json_move_fast_and_break_things = true
      putz "called export_story_as_json"
      $gtk.write_json("story.json", $args.state.forked.story, extensions: true)
    end

    def import_story_from_json
      # Needed to stop dragonjson from soiling the bed
      $__ll_json_move_fast_and_break_things = true

      imp = $gtk.read_file('app/story.json')
      LevisLibs::JSON.parse(imp, symbolize_keys: true, extensions: true)
    end

    ### =================
    ### Export Spellcheck
    ### =================

    # call this from the console
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

        # check for end of condition block
        if context.include?(:condition_block)
          if l.strip.end_with?(':>')
            # cloce condition block AND conditon block condition
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
        if l.strip.start_with?('~~~') # opening code block
          context << :code_block
          next
        elsif l.strip.start_with?('<:') && # opening condition block
          context << :condition_block
          context << :condition_block_condition
          next
        elsif l.strip.start_with?("::") &&  # opening action block
              !context.include?(:condition_block)
              context << :action_block
          next
        elsif l.strip.start_with?('[') && # opening multi-line button
              l.include?('](') &&
              !l.strip.end_with?(')')
          context << :button_code_block
          l = l.split('](')[0] + "]\n"
        end

        # remove rules
        next if l.strip.start_with?('---') # ingnore horizontal rule

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

        # return line with line number prepended
        "#{i + 1}: #{l}"
      end.join
    end

    def save_spellcheck_file(file, path)
      $gtk.write_file(path, file)
    end

    ### =======
    ### Methods
    ### =======
  
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