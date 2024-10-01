module Forked
  # Display class
  class Display
    ### BLOCKQUOTE

    def display_blockquote(y_pos, item)
      display = data.style.display
      blockquote = data.style.blockquote
      blockquote_box = data.style.blockquote_box

      next_y_pos = y_pos - blockquote_box.padding_top
      labels = []

      item.content.each do |para|
        result = display_blockquote_paragraph(next_y_pos, para)
        @last_printed_element_type = :blockquote_paragraph
        next_y_pos = result[0]
        labels << result[1]
      end

      next_y_pos += blockquote.size_px * blockquote.spacing_after

      next_y_pos -= blockquote_box.padding_bottom
      box_height = y_pos - next_y_pos

      rect = {
        x: display.margin_left + blockquote_box.margin_left,
        y: next_y_pos.to_i,
        w: display.w - blockquote_box.margin_left - blockquote_box.margin_right,
        h: box_height,
        path: :solid,
        a: 25,
        r: blockquote_box.r,
        g: blockquote_box.g,
        b: blockquote_box.b,
      }

      bg = Effed.rounded_panel(rect: rect)
      data.primitives << [bg, labels]

      next_y_pos -= blockquote_box.margin_bottom

      next_y_pos
    end

    def display_blockquote_paragraph(y_pos, item)
      blockquote = data.style.blockquote
      blockquote_box = data.style.blockquote_box
      display = data.style.display
      blockquote.size_px = args.gtk.calcstringbox('X', blockquote.size_enum, blockquote.font)[1]
      output_labels = []

      left_margin = blockquote_box.margin_left + blockquote_box.padding_left
      w = display.w - blockquote_box.margin_right - blockquote_box.padding_right

      x_pos = left_margin
      new_y_pos = y_pos

      if @last_printed_element_type == :blockquote_paragraph
        # paragraph follows paragraph, so undo the added 'spacing after'
        new_y_pos += blockquote.size_px * blockquote.spacing_after
        # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= blockquote.size_px * blockquote.spacing_between
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
          new_y_pos += blockquote.size_px * blockquote.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          new_y_pos -= blockquote.size_px * blockquote.spacing_after
        end

        font_style = get_blockquote_font_style(atom.styles)
        font_style.size_px = args.gtk.calcstringbox('X', font_style.size_enum, font_style.font)[1]

        # default_space_w = args.gtk.calcstringbox(' ', font_style.size_enum, paragraph.font)[0]
        words = split_preserve_one_space(atom.text)
        line_frag = ''
        until words.empty?
          word = words[0]

          new_frag = line_frag + word
          new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.size_enum, font_style.font)[0]
          if new_x_pos > w
            loc = { x: x_pos.to_i + display.margin_left, y: new_y_pos.to_i }
            lab = loc.merge(make_blockquote_label(line_frag, font_style))
            output_labels << lab
            line_frag = ''
            x_pos = left_margin

            # line space after soft wrap
            new_y_pos -= blockquote.size_px * blockquote.line_spacing
          else
            ### CHANGED
            line_frag = new_frag # + ' '
            words.shift
          end

          next unless words.empty?

          loc = { x: x_pos.to_i + display.margin_left, y: new_y_pos.to_i }
          lab = loc.merge(make_blockquote_label(line_frag, font_style))
          output_labels << lab
          x_pos = new_x_pos # + default_space_w
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = left_margin

            # line space after hard wrap
            new_y_pos -= blockquote.size_px * blockquote.line_spacing
          end

          # we made it this far and this is the last atom? add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= blockquote.size_px * blockquote.line_spacing
            new_y_pos -= blockquote.size_px * blockquote.spacing_after
          end
        end

        # this is the last atom and it's empty but the paragraph is not empty?
        # (interpolation will do this), apply paragraph spacing now because
        # we won't get there otherwise
        if  atom[:text] == '' &&
            !empty_paragraph &&
            i == item.atoms.size - 1
          new_y_pos -= blockquote.size_px * blockquote.line_spacing
          new_y_pos -= blockquote.size_px * blockquote.spacing_after
        end
      end

      # return the y_pos for the next element
      y = empty_paragraph ? y_pos : new_y_pos
      [y, output_labels]
    end

    # make a one line label in the specified style
    def make_blockquote_label(text, font_style)
      {
        text: text
      }.label!(data.style.blockquote).merge!(font_style)
    end

    def get_blockquote_font_style(styles)
      if styles.include?(:bold) && styles.include?(:italic)
        data.style.blockquote_bold_italic
      elsif styles.include? :bold_italic
        data.style.blockquote_bold_italic
      elsif styles.include? :bold
        data.style.blockquote_bold
      elsif styles.include? :italic
        data.style.blockquote_italic
      elsif styles.include? :code
        data.style.blockquote_code
      else
        data.style.blockquote
      end
    end


    def display_blockquote_old_2(y_pos, item)
      display = data.style.display
      blockquote = data.style.blockquote
      blockquote_box = data.style.blockquote_box
      blockquote.size_px = args.gtk.calcstringbox('X', blockquote.size_enum, blockquote.font)[1]
      blockquote_labels = []

      x_pos = 0
      new_y_pos = y_pos

      # if @last_printed_element_type == :blockquote
      #   # blockquote follows blockquote, so undo the added 'spacing after'
      #   new_y_pos += blockquote.size_px * blockquote.spacing_after
      #   # blockquote follows blockquote, so add 'spacing between'
      #   new_y_pos -= blockquote.size_px * blockquote.spacing_between
      # end

      args.state.forked.forked_display_last_element_empty = false

      empty_blockquote = true # until proven false
      item.atoms.each_with_index do |atom, i|
        # when we're at the end of the blockquote and no atoms have had any text
        # mark it as empty so we know not to remove added 'spacing after'
        empty_blockquote = false if atom[:text].strip != ''
        if i == item.atoms.size - 1 && empty_blockquote
          args.state.forked.forked_display_last_element_empty = true
          # previous element was a blockquote? remove the between spacing
          new_y_pos += blockquote.size_px * blockquote.spacing_between
          # add 'spacing after'. Next element might not be a blockquote.
          new_y_pos -= blockquote.size_px * blockquote.spacing_after
        end

        font_style = get_font_style(atom.styles)
        # default_space_w = args.gtk.calcstringbox(' ', font_style.size_enum, blockquote.font)[0]
        words = split_preserve_one_space(atom.text)
        line_frag = ''
        until words.empty?
          word = words[0]

          new_frag = line_frag + word
          new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.size_enum, font_style.font)[0]
          if new_x_pos > display.w
            loc = {
              x: x_pos.to_i + display.margin_left + blockquote_box.padding_left,
              y: new_y_pos.to_i - blockquote_box.padding_top
            }
            lab = loc.merge(make_blockquote_label(line_frag, font_style))
            blockquote_labels << lab
            line_frag = ''
            x_pos = 0

            # line space after soft wrap
            new_y_pos -= blockquote.size_px * blockquote.line_spacing

          else
            ### CHANGED
            line_frag = new_frag # + ' '
            words.shift
          end

          next unless words.empty?

          loc = {
            x: x_pos.to_i + display.margin_left + blockquote_box.padding_left,
            y: new_y_pos.to_i - blockquote_box.padding_top
          }
          lab = loc.merge(make_blockquote_label(line_frag, font_style))
          blockquote_labels << lab
          x_pos = new_x_pos # + default_space_w
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = 0

            # line space after hard wrap
            new_y_pos -= blockquote.size_px * blockquote.line_spacing
          end


          # we made it this far and this is the last atom? add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= blockquote.size_px * blockquote.line_spacing
            new_y_pos -= blockquote.size_px * blockquote.spacing_after
          end
        end

        # this is the last atom and it's empty but the blockquote is not empty?
        # (interpolation will do this), apply blockquote spacing now because
        # we won't get there otherwise
        if  atom[:text] == '' &&
            !empty_blockquote &&
            i == item.atoms.size - 1
          new_y_pos -= blockquote.size_px * blockquote.line_spacing
          new_y_pos -= blockquote.size_px * blockquote.spacing_after
        end
      end


      # box_height = blockquote_labels.count * (blockquote.size_px * blockquote.line_spacing) +
      #              blockquote_box.padding_top + blockquote_box.padding_bottom
      # box_height = box_height.greater(blockquote_box[:min_height])

      box_height = y_pos -
                   new_y_pos +
                   blockquote_box.padding_top +
                   blockquote_box.padding_bottom -
                   (blockquote.size_px * blockquote.spacing_after)

      data.primitives << {
        x: display.margin_left,
        y: y_pos - box_height,
        w: display.w,
        h: box_height,
        path: :solid,
        r: blockquote_box.r,
        g: blockquote_box.g,
        b: blockquote_box.b
      }

      # new_y_pos += blockquote_box.margin_bottom
      new_y_pos -= blockquote_box.margin_bottom

      data.primitives << {
        x: display.margin_left,
        y: new_y_pos,
        w: display.w,
        h: 1,
        path: :solid,
        r: 255,
        g: 0,
        b: 0
      }

      data.primitives << blockquote_labels

      # return the y_pos for the next element
      empty_blockquote ? y_pos : new_y_pos
    end

    def display_blockquote_old(y_pos, item, _previous_element_type, content, i)
      return if item[:text].empty?

      blockquote = data.style.blockquote
      display = data.style.display
      blockquote_box = data.style.blockquote_box

      # when previous element is also a blockquote, use spacing_between instead of spacing_after
      if content[i - 1][:type] == :blockquote
        y_pos += blockquote.spacing_after * blockquote.size_px
        y_pos -= blockquote.spacing_between * blockquote.size_px
      end

      text_array = wrap_lines(
        item.text, blockquote.font, blockquote.size_enum,
        display.w - (blockquote_box.padding_left + blockquote_box.padding_right)
      )

      blockquote.size_px = args.gtk.calcstringbox('X', blockquote.size_enum, blockquote.font)[1]

      box_height = text_array.count * (blockquote.size_px * blockquote.line_spacing) +
                   blockquote_box.padding_top + blockquote_box.padding_bottom
      box_height = box_height.greater(blockquote_box[:min_height])

      rect = {
        x: display.margin_left, 
        y: y_pos - box_height.to_i, 
        w: display.w, h: box_height,
        r: blockquote_box.r,
        g: blockquote_box.g,
        b: blockquote_box.b
      }
      bg = Effed.rounded_panel(rect: rect)
      data.primitives << bg

      temp_y_pos = y_pos - blockquote_box.padding_top

      data.primitives << text_array.map do |line|
        label = {
          x: display.margin_left + blockquote_box.padding_left,
          y: temp_y_pos.to_i,
          text: line
        }.label!(blockquote)

        temp_y_pos -= blockquote.size_px * blockquote.line_spacing

        label
      end

      y_pos -= box_height
      y_pos - blockquote.size_px * blockquote.spacing_after
    end
  end
end