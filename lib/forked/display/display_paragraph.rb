module Forked
  # Display class
  class Display

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
        font_style.size_px = args.gtk.calcstringbox('X', font_style.size_enum, font_style.font)[1]

        # default_space_w = args.gtk.calcstringbox(' ', font_style.size_enum, paragraph.font)[0]
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
            line_frag = new_frag # + ' '
            words.shift
          end

          next unless words.empty?

          loc = { x: x_pos.to_i + display.margin_left, y: new_y_pos.to_i }
          lab = loc.merge(make_paragraph_label(line_frag, font_style))
          data.primitives << lab
          x_pos = new_x_pos # + default_space_w
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

    # make a one line label in the specified style
    def make_paragraph_label(text, font_style)
      {
        text: text
      }.label!(data.style.paragraph).merge!(font_style)
    end
  end
end