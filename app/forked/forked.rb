$gtk.reset
# $story = nil

module Forked
  # manages the story data
  class Story
    attr_gtk

    def tick
      defaults unless args.state.forked.defaults_set

      @display ||= Display.new(THEME)
      @display.args = args
      @display.tick

      present args
    end

    def defaults
      story_text = fetch_story args
      args.state.forked.story = Parser.parse(story_text)

      args.state.forked.root_chunk = args.state.forked.story[:chunks][0]
      args.state.forked.title = args.state.forked.story[:title]

      follow args
      args.state.forked.defaults_set = true
    end

    ### Chunk content

    def heading
      args.state.forked.current_chunk[:content][0][:text]
    end

    def heading_set new_heading
      args.state.forked.current_chunk[:content][0][:text] = new_heading
    end

    ### Navigation

    # Jump to a specified label
    def jump label
      # TODO: Check that label exists
      $story.follow $args, { action: label }
    end

    def history_add(target)
      args.state.forked.forked_history ||= [] 
      args.state.forked.forked_history << target
    end

    def history(idx = nil)
      history = args.state.forked.forked_history
      return history unless idx

      history[idx]
    end

    def follow(args, option = nil)
      if option&.action && !option.action.start_with?("#")
        # @@@@ was added to code to prevent it being confused with a #navigational_action.
        # The @@@@ part needs to be removed now.
        # Seems to work but I don't trust it
        option.action.delete_prefix!('@@@@')
        evaluate(args, option.action.to_s)
        return
      end

      args.state.forked.current_chunk =
        if option
          chunk = args.state.forked.story.chunks.select { |k| k[:id] == option.action }[0]
          if chunk.nil?
            raise "FORKED: TARGET NOT FOUND. "\
            "Attempting to navigate to `#{option.action}` but the a chunk_id with that name was not found. "\
            "Please check that the chunk_id exists."
          end
          chunk
        else
          args.state.forked.root_chunk
        end
      
      history_add(args.state.forked.current_chunk[:id])
      @heading = args.state.forked.current_chunk[:content][0][:text] 
      
      args.state.forked.current_lines = args.state.forked.current_chunk[:content]
      args.state.forked.options = []
      args.state.forked.current_heading = args.state.forked.current_chunk[:heading] || ''

      unless args.state.forked.current_chunk.actions.empty?
        args.state.forked.current_chunk.actions.each do |a|
          evaluate args, a
        end
      end
      if args.state.forked.current_lines.nil?
        raise "FORKED Display: The story chunk does not exist.
Check that the chunk_id you are linking to exists and is typed correctly.
Tell Akz to write a better error message."
      end
      if args.state.forked.current_lines.empty?
        raise "No lines were found in the current story chunk. Current chunk is #{args.state.current_chunk}"
      end
    end

    def present(args)
      display_lines = args.state.forked.current_lines.copy

      display_lines.each do |element|

        # deal first with content that contains atoms
        if element[:atoms]

          element[:atoms].each_with_index do |atom, j|
            next unless atom[:condition] &&
                        atom[:condition].class == String &&
                        !atom[:condition].empty?
            result = evaluate(args, atom[:condition])
            if result.class == String
              element[:atoms][j][:text] = "#{result} "
            elsif result.nil? || result == false
              element[:atoms][j][:text] = ''
            end
          end
        else
          # the element does not contain atoms
          next unless element && element[:condition]

          result = evaluate(args, element[:condition])

          if result.nil? || result == false
            element[:type] = :blank
          end
        end
      end

      @display.update(display_lines)
    end

    def fetch_story args
      story_text = args.gtk.read_file STORY_FILE

      if story_text.nil?
        raise "The file #{STORY_FILE} failed to load. Please check the filename and path."
      end

      story_text
    end

    #####################
    # EXECUTION
    #####################

    def evaluate(args, command)
      putz "Evaluating: #{command}" if args.state.forked.forked_show_eval
      eval(command)
    end

    def change_theme theme
      @display.apply_theme(theme)
    end
  end
end
