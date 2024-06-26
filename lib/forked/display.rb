$gtk.reset

module Forked
  # Display class
  class Display
    attr_gtk

    def initialize(theme = nil)
      # set the current theme if passed
      @theme = theme
    end

    def tick
      defaults unless data.defaults_set
      input
      render
    end

    # stores object data in state
    def data
      args.state.forked.display ||= args.state.new_entity('forked display')
    end

    def defaults
      data.style = config_defaults # display defaults
      data.options = []             # current options (buttons) in chunk
      apply_theme(@theme)           # set the current theme

      # get input defaults (from input.rb)
      data.keyboard_input_defaults = Forked.keyboard_input_defaults
      data.controller_input_defaults = Forked.controller_input_defaults

      data.selected_option = -1 # set the current selection to no selection
      data.mouse_cursor = :arrow # set the default cursor

      data.defaults_set = true # and don't come back
    end

    ########
    # THEMES
    ########

    def apply_theme(theme)
      data.style = config_defaults
      return unless theme

      theme.each do |k, v|
        next unless data.style[k]

        data.style[k].merge!(v)
      end

      # TODO: this line might not be needed (seems like it's there 
      # to ensure the current selection is highlighted after navigation)
      highlight_selected_option
    end

    #######################
    # PLAYER INPUT HANDLING
    #######################

    ### GET INPUT

    def input
      update_selection
      return if data.options.nil? || data.options.empty?

      activate_selected_option if check_keyboard_activation_end || check_controller_activation_end || check_mouse_activation_end
    end

    ### UPDATE SELECTION

    def update_selection(navigated = nil)
      return if data.options.nil? || data.options.empty? 
      
      inp = inputs.last_active

      # check whether input is selecting a button
      select = check_button_selected

      # did we come here from a navigation command?
      # deselect the buttons (the selection is not valid)
      # and return the cursor to arrow
      # otherwise, maintain the same selection (we just executed some code)
      if navigated
        data.selected_option = -1 
        next_cursor = :arrow
      end

      # check whether input is activating a button
      activating = true if data.selected_option != -1 && check_activation_start

      # check whether input is deactivating a button
      deactivating = data.selected_option != -1 && check_activation_end

      # button is deactivating? (e.g. key/controller/mouse released)
      # revert to selection highlighting
      if deactivating
        highlight_selected_option if data.selected_option >= 0
      end



      # check whether input is deactivating a button
      clicked = true if data.selected_option != -1 && check_activation_end

      if select
        unhighlight_selected_option if data.selected_option >= 0
        data.selected_option = select
        highlight_selected_option if data.selected_option >= 0
        if inputs.last_active == :mouse
          if data.selected_option >= 0
            # try to change to the hand cursor
            next_cursor = :hand
          else
            # try to change to the arrow cursor
            next_cursor = :arrow
          end
        end
      end

      # player clicked the button
      if activating
        highlight_active_option
      end

      # playe
      if select != -1 && check_activation
        highlight_active_option
      end

      # set the cursor when it has changed
      if next_cursor && next_cursor != data.mouse_cursor
        gtk.set_system_cursor(next_cursor)
        data.mouse_cursor = next_cursor
      end
    end

    ### CHECKS

    def check_button_selected
      case inputs.last_active
      when :keyboard
        get_keyboard_selection
      when :controller
        get_controller_selection
      when :mouse
        get_mouse_selection
      end
    end

    def check_activation_start
      case inputs.last_active
      when :keyboard
        check_keyboard_activation_start
      when :controller
        check_controller_activation_start
      when :mouse
        check_mouse_activation_start
      end 
    end

    def check_activation
      case inputs.last_active
        when :keyboard
        check_keyboard_activation
      when :controller
        check_controller_activation
      when :mouse
        check_mouse_activation
      end
    end

    def check_activation_end
      case inputs.last_active
      when :keyboard
        check_keyboard_activation_end
      when :controller
        check_controller_activation_end
      when :mouse
        check_mouse_activation_end
      end 
    end

    def check_keyboard_activation_start
      kd = inputs.keyboard.key_down
      data.keyboard_input_defaults[:activate].any? { |k| kd.send(k) } 
    end

    def check_keyboard_activation
      kh = inputs.keyboard.key_held
      data.keyboard_input_defaults[:activate].any? { |k| kh.send(k) } 
    end

    def check_keyboard_activation_end
      ku = inputs.keyboard.key_up
      data.keyboard_input_defaults[:activate].any? { |k| ku.send(k) } 
    end
  

    def check_controller_activation_start
      c1 = inputs.controller_one

      if c1.connected
        data.controller_input_defaults[:activate].any? { |k| c1.key_down.send(k) }
      end 
    end

    def check_controller_activation
      c1 = inputs.controller_one

      if c1.connected
        data.controller_input_defaults[:activate].any? { |k| c1.key_held.send(k) }
      end 
    end

    def check_controller_activation_end
      c1 = inputs.controller_one

      if c1.connected
        data.controller_input_defaults[:activate].any? { |k| c1.key_up.send(k) }
      end 
    end


    def check_mouse_activation_start
      inputs.mouse.down
    end


    def check_mouse_activation
      inputs.mouse.held
    end

    def check_mouse_activation_end
      inputs.mouse.up
    end


    ### GET PLAYER SELECTION

    def get_mouse_selection
      rollover = -1 
      data.options.each_with_index do |option, idx|
        next if option.action.empty? 

        if option.intersect_rect?(inputs.mouse.point)
          rollover = idx
          break
        end
      end

      rollover if rollover != data.selected_option
    end


    def get_keyboard_selection
      kd = inputs.keyboard.key_down

      if data.keyboard_input_defaults[:next].any? { |k| kd.send(k) }
        return relative_to_absolute_selection(1)
      elsif data.keyboard_input_defaults[:prev].any? { |k| kd.send(k) } 
        return relative_to_absolute_selection(-1)
      end

      nil
    end

    def get_controller_selection
      c1 = inputs.controller_one

      if c1.connected
        if data.controller_input_defaults[:next].any? { |k| c1.key_down.send(k) } 
          return relative_to_absolute_selection(1)
        elsif data.controller_input_defaults[:prev].any? { |k| c1.key_down.send(k) }
          return relative_to_absolute_selection(-1)
        end
      end 

      nil
    end

    ### DISPLAY SELECTION CHANGES

    def highlight_selected_option
      return unless data.options && data.selected_option && data.selected_option >= 0
      opt = data.options[data.selected_option]
      return unless opt
      opt.merge!(data.style.selected_button_box)
    end

    def unhighlight_selected_option
      return unless data.selected_option >= 0

      if data.selected_option >= data.options.count
        return 
      end
      data.options[data.selected_option].merge!(data.style.button_box)
    end

    def highlight_active_option
      return unless data.options && data.selected_option && data.selected_option >= 0
      opt = data.options[data.selected_option]
      return unless opt
      opt.merge!(data.style.active_button_box)
    end

    ### PERFORM OPTION

        def activate_selected_option
      return unless data.selected_option >= 0

      $story.follow(args, data.options[data.selected_option])

    end

    ### HELPER

    def relative_to_absolute_selection(index)

      sel_opt = data.selected_option
      if data.selected_option < 0 || data.selected_option.nil?
        sel_opt = index.positive? ? data.options.size - 1 : 0
      end
      sel_opt += index
      sel_opt = sel_opt.clamp_wrap(0, data.options.size - 1)
    end

    ################
    # UPDATE DISPLAY
    ################


    def update(content, navigated)
      update_selection(navigated)

      data.primitives = []
      data.options = []

      y_pos = data.style.display.margin_top.from_top
      next_y_pos = y_pos

      content.each_with_index do |item, i|
        previous_element_type = content[i - 1][:type] 
        @last_element_type = content[i - 1][:type]  
        @last_printed_element_type ||= :none

        case item[:type]
        when :heading
          next_y_pos = display_heading(y_pos, item, previous_element_type)
        when :rule
          next_y_pos = display_rule(y_pos, item, previous_element_type)
        when :paragraph
          next_y_pos = display_paragraph(y_pos, item)
        when :code_block
          next_y_pos = display_code_block(y_pos, item, previous_element_type)
        when :blockquote
          next_y_pos = display_blockquote(y_pos, item,  previous_element_type, content, i)
        when :button
          next_y_pos = display_button(y_pos, item, content, i)
          highlight_selected_option
        when :image
          next_y_pos = display_image(y_pos, item)
        when :blank
        else
        end

        if !(next_y_pos - y_pos).zero? || item[:type] == :blank
          @last_printed_element_type = item[:type]
        end
        y_pos = next_y_pos
      end
    end

    #######################
    # DISPLAY ELEMENT TYPES
    #######################

    ### BUTTON

    def display_button(y_pos, item, content, i)

      button = data.style.button  
      display = data.style.display
      button_box = data.style.button_box
      disabled_button_box = data.style.disabled_button_box
      
      # previous element is also a button? use spacing_between instead of spacing_after
      if @last_printed_element_type == :button
        y_pos += button.spacing_after * button.size_px
        y_pos -= button.spacing_between * button.size_px
      end

      button.size_px = args.gtk.calcstringbox('X', button.size_enum, button.font)[1]

      text_w, button.size_px = args.gtk.calcstringbox(item.text, button.size_enum, button.font)
      text_w = text_w.to_i
      button_h = (button.size_px + button_box.padding_top + button_box.padding_bottom)


      if !item.action.empty?
        option = {
          x: display.margin_left,
          y: (y_pos - button_h).to_i,
          w: text_w + button_box.padding_left + button_box.padding_right,
          h: (button.size_px + button_box.padding_top + button_box.padding_bottom),
          action: item.action
        }.sprite!(button_box)
        y_pos -= button_box.padding_top

        data.primitives << option
        data.options << option unless data.options.include? option
      else
        data.primitives << {
          x: display.margin_left,
          y: (y_pos - button_h).to_i,
          w: text_w + button_box.padding_left + button_box.padding_right,
          h: (button.size_px + button_box.padding_top + button_box.padding_bottom).to_i,

        }.sprite!(disabled_button_box)

        y_pos -= button_box.padding_top
      end

      data.primitives << {
        x: display.margin_left + button_box.padding_left,
        y: y_pos.to_i,
        text: item.text,
      }.label!(button)

      y_pos -= button.size_px + button_box.padding_bottom
      y_pos -= button.size_px * button.spacing_after
    end

    ### PARAGRAPH

    def display_paragraph(y_pos, item)
      paragraph = data.style.paragraph
      display = data.style.display
      paragraph.size_px = args.gtk.calcstringbox('X', paragraph.size_enum, paragraph.font)[1]

      x_pos = 0
      new_y_pos = y_pos

      if @last_printed_element_type == :paragraph
        # paragraph follows paragraph, so undo the added 'spacing after'
        new_y_pos += paragraph.size_px * paragraph.spacing_after
        # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= paragraph.size_px * paragraph.spacing_between
      end
      
      args.state.forked.forked_display_last_element_empty = false

      empty_paragraph = true # until proven false
      item.atoms.each_with_index do |atom, i|
        # when we're at the end of the paragraph and no atoms have had any text
        # mark it as empty so we know not to remove added 'spacing after'
        empty_paragraph = false if atom[:text].strip != ''
        if i == item.atoms.size - 1 && empty_paragraph
          args.state.forked.forked_display_last_element_empty = true
          # previous element was a paragraph? remove the between spacing
          new_y_pos += paragraph.size_px * paragraph.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          new_y_pos -= paragraph.size_px * paragraph.spacing_after
        end

        font_style = get_font_style(atom.styles)
        default_space_w = args.gtk.calcstringbox(' ', font_style.size_enum, paragraph.font)[0]
        words = split_preserve_one_space(atom.text)
        line_frag = ''
        until words.empty?
          word = words[0] 

          new_frag = line_frag + word
          new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.size_enum, font_style.font)[0]
          if new_x_pos > display.w
            loc = { x: x_pos.to_i + display.margin_left, y: new_y_pos.to_i }
            lab = loc.merge(make_paragraph_label(line_frag, font_style))
            data.primitives << lab
            line_frag = ''
            x_pos = 0

            # line space after soft wrap
            new_y_pos -= paragraph.size_px * paragraph.line_spacing
            
          else
            ### CHANGED
            line_frag = new_frag #+ ' '
            words.shift
          end

          next unless words.empty?
          loc = { x: x_pos.to_i + display.margin_left, y: new_y_pos.to_i }
          lab = loc.merge(make_paragraph_label(line_frag, font_style))
          data.primitives << lab
          x_pos = new_x_pos #+ default_space_w
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = 0

            # line space after hard wrap
            new_y_pos -= paragraph.size_px * paragraph.line_spacing
          end

          # we made it this far and this is the last atom? add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= paragraph.size_px * paragraph.line_spacing
            new_y_pos -= paragraph.size_px * paragraph.spacing_after
          end
        end

        # this is the last atom and it's empty but the paragraph is not empty?
        # (interpolation will do this), apply paragraph spacing now because
        # we won't get there otherwise
        if  atom[:text] == '' &&
            !empty_paragraph &&
            i == item.atoms.size - 1
          new_y_pos -= paragraph.size_px * paragraph.line_spacing
          new_y_pos -= paragraph.size_px * paragraph.spacing_after
        end
      end

      # return the y_pos for the next element
      empty_paragraph ? y_pos : new_y_pos
    end

    ### HEADING

    def display_heading(y_pos, item, previous_element_type)
      heading = data.style.heading
      display = data.style.display
      heading.size_px = args.gtk.calcstringbox('X', heading.size_enum, heading.font)[1]

      data.primitives << {
        x: display.margin_left,
        y: y_pos.to_i,
        text: item.text,
      }.label!(heading)

      y_pos -= heading.size_px * heading.spacing_after
    end

    ### RULE

    def display_rule(y_pos, item, previous_element_type)
      rule = data.style.rule
      display = data.style.display
      weight = rule.weight
      weight = item.weight if item.weight
      
      data.primitives << {
        x: display.margin_left,
        y: y_pos.to_i,
        w: display.w,
        h: weight
      }.sprite!(rule)

      y_pos -= rule.spacing_after
    end

    def display_image(y_pos, item)
      image = data.style.image
      display = data.style.display

      # I don't know why path doesn't work *as is*
      # It's a string, and it doesn't have any odd
      # characters in it
      # But putting it into a _new_ string makes it work
      path = "#{item[:path]}"
      merger = {}
      if path.end_with?('}') && path.include?('{')
        path, remnant = Forked::Parser.pull_out('{', '}', path)
        merger = eval ('{' + remnant + '}')
      end

      h = merger.h || 80
      w = merger.w || 80

      im = {
        x: display.margin_left,
        y: y_pos.to_i - h,
        w: 80,
        h: h,
        path: path,
      }.sprite!(image)

      data.primitives << im.merge(merger)

      y_pos -= (h + image.spacing_after)
    end

    ### CODE BLOCK

    def display_code_block(y_pos, item, previous_element_type)
      code_block = data.style.code_block
      display = data.style.display
      code_block_box = data.style.code_block_box

      text_array = wrap_lines_code_block(
        item.text, code_block.font, code_block.size_enum,
        display.w - (code_block_box.padding_left + code_block_box.padding_right)
      )
      code_block.size_px = args.gtk.calcstringbox('X', code_block.size_enum, code_block.font)[1]

      box_height = text_array.count * (code_block.size_px * code_block.line_spacing) +
                  code_block_box.padding_top + code_block_box.padding_bottom

      temp_y_pos = y_pos

      data.primitives << {
        x: display.margin_left,
        y: (temp_y_pos - box_height).to_i,
        w: display.w,
        h: box_height.to_i,
      }.sprite!(code_block_box)

      temp_y_pos -= code_block_box.padding_top
      data.primitives << text_array.map do |line|

        label = {
          x: display.margin_left + code_block_box.padding_left,
          y: temp_y_pos.to_i,
          text: line,
        }.label!(code_block)

        temp_y_pos -= code_block.size_px * code_block.line_spacing

        label
      end

      y_pos -= box_height
      y_pos -= code_block.size_px * code_block.spacing_after
    end

    ### BLOCKQUOTE

    def display_blockquote(y_pos, item, previous_element_type, content, i)
      return if item[:text].empty?

      blockquote = data.style.blockquote
      display = data.style.display
      blockquote_box = data.style.blockquote_box

      # when previous element is also a blockquote, use spacing_between instead of spacing_after
      if content[i - 1][:type] == :blockquote
        y_pos += blockquote.spacing_after * blockquote.size_px
        y_pos -= blockquote.spacing_between * blockquote.size_px
      end

      text_array = wrap_lines(item.text, blockquote.font, blockquote.size_enum, display.w - (blockquote_box.padding_left + blockquote_box.padding_right))

      blockquote.size_px = args.gtk.calcstringbox('X', blockquote.size_enum, blockquote.font)[1]

      box_height = text_array.count * (blockquote.size_px * blockquote.line_spacing) +
      blockquote_box.padding_top + blockquote_box.padding_bottom
      box_height = box_height.greater(blockquote_box[:min_height])

      data.primitives << {
        x: display.margin_left,
        y: (y_pos - box_height).to_i,
        w: display.w,
        h: box_height,
      }.sprite!(blockquote_box)

      temp_y_pos = y_pos - blockquote_box.padding_top

      data.primitives << text_array.map do |line|
        label = {
          x: display.margin_left + blockquote_box.padding_left,
          y: temp_y_pos.to_i,
          text: line,
        }.label!(blockquote)

        temp_y_pos -= blockquote.size_px * blockquote.line_spacing

        label
      end

      y_pos -= box_height
      y_pos -= blockquote.size_px * blockquote.spacing_after

    end

    ################
    # STYLE HANDLING
    ################

    def get_font_style styles
      if styles.include?(:bold) && styles.include?(:italic)
        data.style.bold_italic
      elsif styles.include? :bold_italic
        data.style.bold_italic
      elsif styles.include? :bold
        data.style.bold
      elsif styles.include? :italic
        data.style.italic
      elsif styles.include? :code
        data.style.code
      else
        data.style.paragraph
      end
    end

    ############
    # PRIMITIVES
    ############

    # make a one line label in the specified style
    def make_paragraph_label text, font_style
      {
        text: text,
      }.label!(data.display.paragraph).merge!(font_style)
    end

    ###############
    # TEXT HANDLING
    ###############

    def wrap_lines_code_block str, font, size_px, width
      wrapped_text = []
      str.lines.map do |l|
        l += ' ' # <== It's a hack :)
        fixed_width_line = ''
        frag = ''
        sp = 0 # index of first space
        while sp
          sp = l.index(' ')
          if sp
            if sp.zero?
              # space is the first character?
              # check width of line so far (fixed_width_line + frag)
              test_w = args.gtk.calcstringbox(fixed_width_line + frag, size_px, font)[0]
              # we're still inside the boundary?
              if test_w < width
                # add the current fragment to the line
                fixed_width_line += frag
                # add the current character (a space) to the line
                frag = ' '
              else # the next frag will push us over the line so soft wrap
                wrapped_text << fixed_width_line

                # empty the line and add the non-fitting frag to it
                fixed_width_line = frag.delete_prefix!(' ')
                # empty the frag but add a space
                frag = ' '
              end # end test_w < width

              # empty frag and add a space

              # All hell will break loose if this line is removed
              # removes the found space, whether or not if goes in the
              # current soft line
              l.delete_prefix!(' ')

            else # space is not the first character. Add the previous word to frag
              ret = l.slice!(0, sp)
              frag += ret
            end
          else # there are no more spaces left in this line
            # add the remnant to frag
            frag += l
            # at the end of the line so add it to fwl
            fixed_width_line += frag
            # and add that to the wrapped text array
            wrapped_text << fixed_width_line
          end
        end
      end

      wrapped_text
    end

    def wrap_lines_code_block_slow str, font, size_px, width
      wrapped_text = []
      str.lines.map do |l|
        fixed_width_line = ''

        c = 0
        frag = ''
        while c < l.length

          if l.chars[c] == ' '
            # check w of frag + fixed_width_line
            test_w = args.gtk.calcstringbox(fixed_width_line + frag, size_px, font)[0]
            # if it fits display w

            if test_w < width
              # add frag to line
              fixed_width_line += frag
              # empty frag and add the matched space
              frag = ' '
            else # the line is too long to add the frag
              # add the line to the wrapped text array

              wrapped_text << fixed_width_line
              # empty the line and add the non-fitting frag to it
              fixed_width_line = frag
              # empty the frag
              frag = ' '
            end
          else # any character that is not a space
            # add char to frag
            frag += l.chars[c]
          end

          # we got to the end of the line
          if c == l.length - 1
            fixed_width_line += frag
            wrapped_text << fixed_width_line
          end
          c += 1
        end
      end

      # TODO: Small wrinkle with this code: a word can happily sit at the end of a line
      # but when another word is added after, the word will shift to the next line.
      # This might be due to the word having a space added to the width calculation?
      wrapped_text
    end

    def wrap_lines str, font, size_px, width
      wrapped_text = []
      str.lines.map do |l|
        fixed_width_line = ''

        words = l.strip.split(" ")

        until words.empty?
          line_next = fixed_width_line + words[0]
          if args.gtk.calcstringbox(line_next, size_px, font)[0] < width
            fixed_width_line = line_next + ' '
            words.shift
          else
            wrapped_text << fixed_width_line
            fixed_width_line = ''
          end

          if words.empty?
            wrapped_text << fixed_width_line
          end
        end # until
      end

      wrapped_text
    end

    ## split string (str) on space
    ## preserve a maximum of one consecutive space
    def split_preserve_one_space(str)
      arr = []
      while str.length > 0
        if idx = str.index(' ')
          capture = str[0...idx + 1]
          # prevent runs of spaces
          unless capture == ' ' && arr[-1]&.end_with?(" ")
            arr << capture
          end
          str = str [idx + 1..-1]
        else
          # the string does not or no longer contains a space
          arr << str
          str = ''
        end
      end # while
      arr
    end

    ## split string (str) on space
    ## preserve spaces
    def split_preserve_space(str)
      arr = []
      while str.length > 0
        idx = str.index(' ')
        if idx
          cap = str[0...idx + 1] 
          arr << cap
          str = str [idx + 1..-1]
        else
          arr << str
          str = ''
        end
      end # while
      arr
    end

    ########
    # RENDER
    ########

    def render
      outputs.background_color = data.style.display.background_color.values
      args.outputs.primitives << data.primitives
    end
  end
end

  # reference for display format
  #   [
  #     {
  #       type: :heading,
  #       text: "Non eram nescius",
  #     },
  #     {
  #       type: :rule
  #     },
  #     {
  #       type: :paragraph,
  #       atoms: [
  #         {
  #           text: "Non eram nescius,",
  #           styles: []
  #         },
  #         {
  #           text: "Brute, cum, quae summis ingeniis",
  #           styles: [:italic]
  #         },
  #         {
  #           text: " exquisitaque doctrina philosophi Graeco sermone tractavissent, ea",
  #           styles: []
  #         },
  #         {
  #           text: " Latinis litteris mandaremus,",
  #           styles: [:bold]
  #         },
  #         {
  #           text: "fore ut hic noster labor in varias reprehensiones incurreret. nam quibusdam, et iis quidem non admodum indoctis,",
  #           styles: []
  #         },
  #         {
  #           text: " totum hoc displicet",
  #           styles: [:bold, :italic]
  #         },
  #         {
  #           text: " philosophari. quidam autem non tam id",
  #           styles: []
  #         },
  #         {
  #           text: " reprehendunt",
  #           styles: [:code]
  #         },
  #         {
  #           text: "si remissius agatur sed.",
  #           styles: []
  #         },
  #        ]
  #     },
  #     {
  #     type: :code_block,
  #     text: "def default_code_block # defaults for code block text
  #   {
  #     font: 'fonts/roboto_mono/static/robotomono-regular.ttf',
  #     size_px: 22,
  #     line_spacing: 0.85,
  #     r: 76, g: 51, b: 127,
  #     spacing_after: 0.7, # 1.0 is line_height.
  #   }
  # end",
  #     },
  #     {
  #     type: :blockquote,
  #     text: "Contra quos omnis dicendum breviter existimo. Quamquam philosophiae quidem vituperatoribus satis responsum est eo libro, quo a nobis philosophia defensa et collaudata est, cum esset accusata et vituperata ab Hortensio.",
  #     },
  #     {
  #     type: :button,
  #     text: "Contra quos omnis",
  #     action: "puz'This button was clicked'"
  #     },
  #   ]
