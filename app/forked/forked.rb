$gtk.reset
# $story = nil

module Forked

  # manages the story data
  class Story
    attr_gtk

    def tick
      defaults unless args.state.forked.defaults_set
      # navigated is passed to display to determine whether to reset
      # the keyboard selection during an update
      # set to false every tick and set to true if navigation happens later
      args.state.forked.navigated = false 

      # process player input (mouse, keyboard, controller)
      check_input

      # create and feed the display object
      @display ||= Display.new(THEME)
      @display.args = args
      @display.tick

      # make the display hash and send it to the display object
      present args

      # create the Author object. Author mode provides tools for the developer.
      @author ||= Author.new(self)
      @author.args = args
      @author.tick
    end

    def defaults
      @refresh = true
      @hashed_display = 0
      if STORY_FILE.end_with?('.json')
        args.state.forked.story = Forked.import_story_from_json
      else
        story_text = fetch_story args
        args.state.forked.story = Parser.parse(story_text)
      end

      args.state.forked.root_chunk = args.state.forked.story[:chunks][0]
      args.state.forked.title = args.state.forked.story[:title]

      # args.state.forked.navigated = false
      follow args
      
      args.state.forked.defaults_set = true

      navigate(0)
    end

    ## input for Forked
    def check_input
      # toggle author mode
      if  args.inputs.keyboard.key_held.f &&
          args.inputs.keyboard.key_down.u
        args.state.forked.author_mode = !args.state.forked.author_mode
        puts "Forked Author Mode is " + (args.state.forked.author_mode ? "on" : "off")
      end
    end

    ### Chunk content

    def heading
      args.state.forked.current_chunk[:content][0][:text]
    end

    def heading_set new_heading
      args.state.forked.current_chunk[:content][0][:text] = new_heading
    end

    ### Navigation

    def get_current_chunk_idx
      args.state.forked.story.chunks.find_index { |c| c == state.forked.current_chunk }
    end

    def find_chunk_index_from_id(chunk_id)
      args.state.forked.story.chunks.index { |i| i[:id] == chunk_id }
    end

    # accepts chunk ID, finds the chunk index and calls navigate()
    def navigate_id(chunk_id)
      idx = find_chunk_index_from_id(chunk_id)
      if idx.nil?
        raise "FORKED: TARGET NOT FOUND.\n"\
        "Cannot navigate to the specified chunk.\n"\
        "Attempted to navigate to: #{chunk_id}"
      end 
      navigate(idx)
    end

    # accepts an int relative to the current chunk index and calls navigate()
    def navigate_relative(relative_idx)
      next_index = (get_current_chunk_idx + relative_idx).clamp(0, args.state.forked.story.chunks.size - 1)
      navigate(next_index)
    end

    # navigates to the chunk with the provided index number
    def navigate(idx)
      if idx.nil?
        raise "FORKED: TARGET NOT FOUND. "\
        "Cannot navigate to the specified chunk."
      end 

      target = args.state.forked.story.chunks[idx]

      if target.nil?
        raise "FORKED: TARGET NOT FOUND. "\
        "Cannot navigate to the specified chunk."
      end

      history_add(idx)

      # set the current chunk
      state.forked.current_chunk = target
      # update the current heading
      @heading = args.state.forked.current_chunk[:content][0][:text]
      args.state.forked.current_heading = @heading || '' 
      # set the current content
      args.state.forked.current_lines = args.state.forked.current_chunk[:content]
      # clear the options array
      args.state.forked.options = []

      args.state.forked.navigated = true

      process_new_chunk
    end

    # Jump to a specified label
    def jump param = nil
      if param.is_a?(Integer)
        navigate_relative(param)
      elsif param.is_a?(String)
        # TODO: Check that label exists
        navigate_id(param)
      elsif param.is_a?(NilClass)
        raise "`jump` must be given a parameter."
      end
    end

    def history_get
      state.forked.forked_history.map do |h|
        [
          h,
          state.forked.story.chunks[h][:id],
          args.state.forked.story.chunks[h][:content].find {|c| c.type == :heading }.text
        ]
      end
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

    ### Actions

    def process_action(args, action)
      if action.class == String
        if action == '#'
          navigate_relative(1)
        elsif action.start_with?('#')
          navigate_id(action)
        else
          eval_action = action.delete_prefix('@@@@')
          evaluate(args, eval_action.to_s)
          return
        end
      else
        raise "Forked: Unexpected action value. Expecting String or Integer. #{action.to_s}"
      end
    end

    def process_new_chunk
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

    def follow(args, option = nil)
      if option&.action
        process_action(args, option.action) 
      end
    end

    ### DEPRECATED
    def fall
      puts "`fall` is deprecated. Please use `jump(1)` instead."
      navigate_relative(1)
    end

    ### DEPRECATED
    def rise
      puts "`rise` is deprecated. Please use `jump(-1)` instead."
      navigate_relative(-1)
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

      new_hash = display_lines.hash
      if @hashed_display == new_hash && !@refresh
        return
      else 
        @display.update(display_lines, args.state.forked.navigated)
        @hashed_display = new_hash
        @refresh = false
      end
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
      puts "Evaluating: #{command}" if args.state.forked.forked_show_eval
      eval(command)
    end

    def change_theme theme
      @display.apply_theme(theme)
      @refresh = true
    end

    #################
    # Commands
    #################

    ### BAG (player inventory)

    # adds an item to the player inventory
    def bag_add item
      bag << item unless bag_has? item
    end

    # removes an item from the player inventory
    def bag_remove item
      bag.delete item
    end

    # returns true if the player inventory includes item
    def bag_has? item
      bag.include? item
    end

    # the player inventory
    def bag
      $args.state.forked_bag ||= []
    end

    # empties the player inventory
    def bag_clear
      $args.state.forked_bag = []
    end

    def bag_sentence
      return "nothing" unless $args.state.forked_bag

      return "nothing" if $args.state.forked_bag.empty?

      str = ""
      $args.state.forked_bag.each_with_index do |item, i|
        str += item
        if i < $args.state.forked_bag.count - 1
          str += ", "
        else
          str += "."
        end
      end
      str
    end

    ### Background
    # Sets the background image to a 1280x720 png file (run from a condition)
    def background_image(path)
      $args.outputs.sprites << {
        x: 0,
        y: 0,
        w: 1280,
        h: 720,
        path: path
      }
    end

    ### Counters

    def counter
      $args.state.forked_counter ||= {}
    end

    def counter_up name, value = 1
      counter[name] += value
    end

    def counter_down name, value = 1
      counter[name] -= value
    end

    def counter_add name, value = 0
      counter[name] = value
    end

    def counter_remove name
      counter.delete(name)
    end

    def counter_check name
      counter[name]
    end

    def counter_clear
      $args.state.forked_counter = {}
    end

    ### Memos
    # stores information that can be checked later
    def memo
      $args.state.forked_memo ||= {}
    end

    # adds a memo
    def memo_add name, value
      memo[name] = value
    end

    # deletes a memo
    def memo_remove name
      memo.delete(name)
    end

    # clears all memos
    def memo_clear
      $args.state.forked_memo = {}
    end

    # returns true if a memo exists
    def memo_exists? name
      memo[name] != nil
    end

    # returns the value of a memo
    def memo_check name
      memo[name]
    end

    ### Wallet
    # Keeps track of the player's finances (gold coins, dollars, anything you like)
    def wallet
      args.state.forked_wallet ||= 0
    end

    # adds money to the wallet
    def wallet_plus num
      wallet = wallet + num
    end

    # removes money from the wallet
    def wallet_minus num
      wallet = wallet - num
    end

    # removes all money from the wallet
    def wallet_clear
      wallet = 0
    end

    ### Timers
    # lets you create timers
    def timer
      args.state.forked_timer ||= {}
    end

    # creates a new, named timer with the provided duration
    def timer_add name, duration
      timer[name] = {
        start_time: $args.tick_count,
        duration: duration
      }
    end

    # removes a named timer
    def timer_remove name
      timer.delete(name)
    end

    # checks how much time is left for a timer (will be negative when duration is up)
    def timer_check name
      timer[name][:duration] - ($args.tick_count - timer[name][:start_time])
    end

    # returns true if the named timer is complete
    def timer_done? name
      timer_check(name) <= 0
    end

    # returns timer value as seconds, minimum 0
    def timer_seconds(name)
      timer_check(name).idiv(60).greater(0)
    end

    ### Dice Roll
    def roll dice
      result = 0
      num_dice, num_sides = dice.split('d', 2)
      num_dice.to_i.times { result += rand(num_sides.to_i) + 1 }
      result
    end

  end
end
