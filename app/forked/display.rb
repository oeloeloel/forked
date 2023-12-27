$gtk.reset

module Forked
  # Display class
  class Display
    attr_gtk

    def initialize(theme = nil)
      @theme = theme
    end

    def tick
      defaults unless data.defaults_set
      input
      render
    end

    def data
      args.state.forked.display ||= args.state.new_entity('forked display')
    end

    def defaults
      data.config = config_defaults
      data.options = []
      data.defaults_set = true
      apply_theme(@theme)
    end

    def apply_theme(theme)
      data.config = config_defaults
      return unless theme

      theme.each do |k, v|
        data.config[k].merge!(v)
      end
    end

    def input
      return if data.options.nil? || data.options.empty?

      data.options.each do |option|
        next if option.action.empty?

        if option.intersect_rect?(inputs.mouse.point)
          args.gtk.set_system_cursor(:hand)
          option.merge!(data.config.rollover_button_box)

          $story.follow(args, option) if args.inputs.mouse.up
        else
          option.merge!(data.config.button_box)
        end
      end
    end

    def update(content)
      data.primitives = []
      data.options = []

      display = data.config.display
      paragraph = data.config.paragraph
      heading = data.config.heading
      rule = data.config.rule
      code_block = data.config.code_block
      code_block_box = data.config.code_block_box
      blockquote = data.config.blockquote
      blockquote_box = data.config.blockquote_box
      # blockquote_image = data.config.blockquote_image # For later
      button = data.config.button
      button_box = data.config.button_box
      inactive_button_box = data.config.inactive_button_box

      # background solid for display area, not very useful

      # data.primitives << {
      #   x: display.margin_left,
      #   y: display.margin_bottom,
      #   w: display.w,
      #   h: display.h,
      #   **display.background_color
      # }.sprite!
      y_pos = display.margin_top.from_top

      content.each_with_index do |item, i|
        previous_element_type = content[i - 1][:type] 

        case item[:type]
        when :heading
          y_pos = display_heading(y_pos, item, previous_element_type)
        when :rule
          y_pos = display_rule(y_pos, item, previous_element_type)
        when :paragraph
          y_pos = display_paragraph(y_pos, item, previous_element_type)
        when :code_block
          y_pos = display_code_block(y_pos, item, previous_element_type)
        when :blockquote
          y_pos = display_blockquote(y_pos, item,  previous_element_type, content, i)
        when :button
          y_pos = display_button(y_pos, item, previous_element_type, content, i)
        end
      end
    end

      def display_button(y_pos, item, previous_element_type, content, i)
        button = data.config.button  
        display = data.config.display
        button_box = data.config.button_box
      inactive_button_box = data.config.inactive_button_box
        
        # if previous element is also a button, use spacing_between instead of spacing_after
          if content[i - 1].type == :button
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
              y: y_pos - button_h,
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
              y: y_pos - button_h,
              w: text_w + button_box.padding_left + button_box.padding_right,
              h: (button.size_px + button_box.padding_top + button_box.padding_bottom),

            }.sprite!(inactive_button_box)

            y_pos -= button_box.padding_top
          end

          data.primitives << {
            x: display.margin_left + button_box.padding_left,
            y: y_pos,
            text: item.text,
          }.label!(button)

          y_pos -= button.size_px + button_box.padding_bottom
          y_pos -= button.size_px * button.spacing_after
        end

    def display_paragraph(y_pos, item, previous_element_type)
      paragraph = data.config.paragraph
      display = data.config.display
      paragraph.size_px = args.gtk.calcstringbox('X', paragraph.size_enum, paragraph.font)[1]

      x_pos = 0
      new_y_pos = y_pos

      if previous_element_type == :paragraph
        # paragraph follows paragraph, so undo the added 'spacing after'
        new_y_pos += paragraph.size_px * paragraph.spacing_after
        # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= paragraph.size_px * paragraph.spacing_between
      end
      
      args.state.forked.forked_display_last_element_empty = false

      empty_paragraph = true
      item.atoms.each_with_index do |atom, i|

        # if we're at the end of the paragraph and no atoms have had any text
        # mark it as empty so we know not to remove added 'spacing after'
        empty_paragraph = false if atom[:text] != ''
        if i == item.atoms.size - 1 && empty_paragraph
          args.state.forked.forked_display_last_element_empty = true
          # if previous element was a paragraph, remove the between spacing
          new_y_pos += paragraph.size_px * paragraph.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          new_y_pos -= paragraph.size_px * paragraph.spacing_after
        end

        font_style = get_font_style(atom.styles)
        default_space_w = args.gtk.calcstringbox(' ', font_style.size_enum, paragraph.font)[0]
        words = atom.text.split(' ')
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
            line_frag = new_frag + ' '
            words.shift
          end

          next unless words.empty?

          loc = { x: x_pos.to_i + display.margin_left, y: new_y_pos.to_i }
          lab = loc.merge(make_paragraph_label(line_frag, font_style))
          data.primitives << lab
          x_pos = new_x_pos + default_space_w
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = 0

            # line space after hard wrap
            new_y_pos -= paragraph.size_px * paragraph.line_spacing
          end

          # if we made it this far and this is the last atom, add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= paragraph.size_px * paragraph.line_spacing
            new_y_pos -= paragraph.size_px * paragraph.spacing_after
          end
        end

        # if this is the last atom and it's empty but the paragraph is not empty
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

    def display_heading(y_pos, item, previous_element_type)
      heading = data.config.heading
      display = data.config.display
      heading.size_px = args.gtk.calcstringbox('X', heading.size_enum, heading.font)[1]

      data.primitives << {
        x: display.margin_left,
        y: y_pos,
        text: item.text,
      }.label!(heading)

      y_pos -= heading.size_px * heading.spacing_after
    end

    def display_rule(y_pos, item, previous_element_type)
      rule = data.config.rule
      display = data.config.display
      weight = rule.weight
      weight = item.weight if item.weight
      
      data.primitives << {
        x: display.margin_left,
        y: y_pos,
        w: display.w,
        h: weight
      }.sprite!(rule)

      y_pos -= rule.spacing_after
    end

    def display_code_block(y_pos, item, previous_element_type)
      code_block = data.config.code_block
      display = data.config.display
      code_block_box = data.config.code_block_box

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
        y: temp_y_pos - box_height,
        w: display.w,
        h: box_height,
      }.sprite!(code_block_box)

      temp_y_pos -= code_block_box.padding_top
      data.primitives << text_array.map do |line|

        label = {
          x: display.margin_left + code_block_box.padding_left,
          y: temp_y_pos,
          text: line,
        }.label!(code_block)

        temp_y_pos -= code_block.size_px * code_block.line_spacing

        label
      end

      y_pos -= box_height
      y_pos -= code_block.size_px * code_block.spacing_after
    end

    def display_blockquote(y_pos, item, previous_element_type, content, i)
      next if item[:text].empty?

      blockquote = data.config.blockquote
      display = data.config.display
      blockquote_box = data.config.blockquote_box

      # if previous element is also a blockquote, use spacing_between instead of spacing_after
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
        y: y_pos - box_height,
        w: display.w,
        h: box_height,
      }.sprite!(blockquote_box)

      temp_y_pos = y_pos - blockquote_box.padding_top

      data.primitives << text_array.map do |line|
        label = {
          x: display.margin_left + blockquote_box.padding_left,
          y: temp_y_pos,
          text: line,
        }.label!(blockquote)

        temp_y_pos -= blockquote.size_px * blockquote.line_spacing

        label
      end

      y_pos -= box_height
      y_pos -= blockquote.size_px * blockquote.spacing_after

    end

    def get_font_style styles
      if styles.include?(:bold) && styles.include?(:italic)
        data.config.bold_italic
      elsif styles.include? :bold
        data.config.bold
      elsif styles.include? :italic
        data.config.italic
      elsif styles.include? :code
        data.config.code
      else
        data.config.paragraph
      end
    end

    # make a one line label in the specified style
    def make_paragraph_label text, font_style
      {
        text: text,
      }.label!(data.display.paragraph).merge!(font_style)
    end

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
              # if space is the first character
              # check width of line so far (fixed_width_line + frag)
              test_w = args.gtk.calcstringbox(fixed_width_line + frag, size_px, font)[0]
              # if we're still inside the boundary
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
              end

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
        end
      end

      wrapped_text
    end

    def render
      outputs.background_color = data.config.display.background_color.values
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
