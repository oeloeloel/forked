
module Forked
  class Display
    def display_text(outer_rect, y_pos, item)
      # "==== def display_text(outer_rect, y_pos, item)"
      style = data.style[item.type]

      # putz item.atoms[0].text.start_with?('<!')

      # justified paragraph is hacked in here for now
      # but skip it if the paragraph is a test marker
      if style&.text_align == :justify && !item.atoms[0].text.start_with?('<!')
        return display_justified_text(outer_rect, y_pos, item)
      end

      style.size_px ||= args.gtk.calcstringbox('X', style.size_enum, style.font)[1]
      output_labels = []
      row = []
      space_w = 0

      rect = outer_rect.dup
      right = rect.x + rect.w
      x_pos = rect.x
      new_y_pos = y_pos

      if @last_printed_element_type == item.type
        # paragraph follows paragraph, so undo the added 'spacing after'
        new_y_pos += style.size_px * style.spacing_after
        # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= style.size_px * style.spacing_between
      end
      
      args.state.forked.forked_display_last_element_empty = false
      empty_paragraph = true # until proven false
      new_x_pos = x_pos

      item.atoms.each_with_index do |atom, i|
        # when we're at the end of the paragraph and no atoms have had any text
        # mark it as empty so we know not to remove added 'spacing after'
        empty_paragraph = false if atom[:text].strip != ''
        if i == item.atoms.size - 1 && empty_paragraph
          args.state.forked.forked_display_last_element_empty = true
          # previous element was a paragraph? remove the between spacing
          new_y_pos += style.size_px * style.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          new_y_pos -= style.size_px * style.spacing_after
        end

        font_style = get_font_style(atom.styles)
        space_w, font_style.size_px = args.gtk.calcstringbox('X', font_style.size_enum, font_style.font)

        words = split_preserve_one_space(atom.text)
        line_frag = ''

        until words.empty?
          word = words[0]

          new_frag = line_frag + word
          old_x_pos = new_x_pos
          new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.size_enum, font_style.font)[0]
          if new_x_pos > right
            loc = { x: x_pos.to_i, y: new_y_pos.to_i }
            lab = loc.merge(make_text_label(line_frag.rstrip!, font_style, item))
            row << lab
            align_row(row, old_x_pos - rect.x, rect, style)
            output_labels << row.dup
            row.clear
            line_frag = ''
            x_pos = rect.x

            # line space after soft wrap
            new_y_pos -= style.size_px * style.line_spacing
          else
            line_frag = new_frag
            words.shift
          end

          next unless words.empty?

          loc = { x: x_pos.to_i, y: new_y_pos.to_i }
          lab = loc.merge(make_text_label(line_frag, font_style, item))
          row << lab
          x_pos = new_x_pos
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = rect.x
            align_row(row, old_x_pos - rect.x, rect, style)
            output_labels << row.dup
            row.clear

            # line space after hard wrap
            new_y_pos -= style.size_px * style.line_spacing
          end

          # we made it this far and this is the last atom? add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= style.size_px * style.line_spacing
            new_y_pos -= style.size_px * style.spacing_after
          end
        end

        # this is the last atom and it's empty but the paragraph is not empty?
        # (interpolation will do this), apply paragraph spacing now because
        # we won't get there otherwise
        if  atom[:text] == '' &&
            !empty_paragraph &&
            i == item.atoms.size - 1
          new_y_pos -= style.size_px * style.line_spacing
          new_y_pos -= style.size_px * style.spacing_after
        end
      end

      if row.any?
        row[-1].text.rstrip!
        align_row(row, new_x_pos - rect.x, rect, style)
        output_labels += row
      end

      data.primitives << output_labels

      # return the y_pos for the next element
      y = empty_paragraph ? y_pos : new_y_pos
      [y, output_labels]
    end

    def display_text_replaced_on_jun_11_2025_for_justify_changes(outer_rect, y_pos, item)
      # puts "==== def display_text(outer_rect, y_pos, item)"
      style = data.style[item.type]
      style.size_px ||= args.gtk.calcstringbox('X', style.size_enum, style.font)[1]
      output_labels = []
      row = []
      space_w = 0

      rect = outer_rect.dup
      right = rect.x + rect.w
      x_pos = rect.x
      new_y_pos = y_pos

      if @last_printed_element_type == item.type
        # paragraph follows paragraph, so undo the added 'spacing after'
        new_y_pos += style.size_px * style.spacing_after
        # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= style.size_px * style.spacing_between
      end
      
      args.state.forked.forked_display_last_element_empty = false

      empty_paragraph = true # until proven false

      new_x_pos = x_pos

      item.atoms.each_with_index do |atom, i|
        # when we're at the end of the paragraph and no atoms have had any text
        # mark it as empty so we know not to remove added 'spacing after'
        empty_paragraph = false if atom[:text].strip != ''
        if i == item.atoms.size - 1 && empty_paragraph
          args.state.forked.forked_display_last_element_empty = true
          # previous element was a paragraph? remove the between spacing
          new_y_pos += style.size_px * style.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          new_y_pos -= style.size_px * style.spacing_after
        end

        font_style = get_font_style(atom.styles)
        space_w, font_style.size_px = args.gtk.calcstringbox('X', font_style.size_enum, font_style.font)

        words = split_preserve_one_space(atom.text)
        line_frag = ''

        until words.empty?
          word = words[0]

          new_frag = line_frag + word
          old_x_pos = new_x_pos
          new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.size_enum, font_style.font)[0]
          if new_x_pos > right
            loc = { x: x_pos.to_i, y: new_y_pos.to_i }
            lab = loc.merge(make_text_label(line_frag.rstrip!, font_style, item))
            row << lab
            align_row(row, old_x_pos - rect.x, rect, style)
            output_labels << row.dup
            row.clear
            line_frag = ''
            x_pos = rect.x

            # line space after soft wrap
            new_y_pos -= style.size_px * style.line_spacing
          else
            ### CHANGED
            line_frag = new_frag # + ' '
            words.shift
          end

          next unless words.empty?

          loc = { x: x_pos.to_i, y: new_y_pos.to_i }
          lab = loc.merge(make_text_label(line_frag, font_style, item))
          row << lab
          x_pos = new_x_pos # + default_space_w
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = rect.x
            align_row(row, old_x_pos - rect.x, rect, style)
            output_labels << row.dup
            row.clear

            # line space after hard wrap
            new_y_pos -= style.size_px * style.line_spacing
          end

          # we made it this far and this is the last atom? add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= style.size_px * style.line_spacing
            new_y_pos -= style.size_px * style.spacing_after
          end
        end

        # this is the last atom and it's empty but the paragraph is not empty?
        # (interpolation will do this), apply paragraph spacing now because
        # we won't get there otherwise
        if  atom[:text] == '' &&
            !empty_paragraph &&
            i == item.atoms.size - 1
          new_y_pos -= style.size_px * style.line_spacing
          new_y_pos -= style.size_px * style.spacing_after
        end
      end

      if row.any?
        row[-1].text.rstrip!
        align_row(row, new_x_pos - rect.x, rect, style)
        output_labels += row
      end

      data.primitives << output_labels

      # return the y_pos for the next element
      y = empty_paragraph ? y_pos : new_y_pos
      [y, output_labels]
    end

    def display_text_old(outer_rect, y_pos, item)
      style = data.style[item.type]
      style.size_px ||= args.gtk.calcstringbox('X', style.size_enum, style.font)[1]
      output_labels = []
      row = []
      space_w = 0

      rect = outer_rect.dup
      right = rect.x + rect.w
      x_pos = rect.x
      new_y_pos = y_pos

      if @last_printed_element_type == item.type
        # paragraph follows paragraph, so undo the added 'spacing after'
        new_y_pos += style.size_px * style.spacing_after
        # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= style.size_px * style.spacing_between
      end
      
      args.state.forked.forked_display_last_element_empty = false

      empty_paragraph = true # until proven false

      new_x_pos = x_pos

      item.atoms.each_with_index do |atom, i|
        # when we're at the end of the paragraph and no atoms have had any text
        # mark it as empty so we know not to remove added 'spacing after'
        empty_paragraph = false if atom[:text].strip != ''
        if i == item.atoms.size - 1 && empty_paragraph
          args.state.forked.forked_display_last_element_empty = true
          # previous element was a paragraph? remove the between spacing
          new_y_pos += style.size_px * style.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          new_y_pos -= style.size_px * style.spacing_after
        end

        font_style = get_font_style(atom.styles)
        space_w, font_style.size_px = args.gtk.calcstringbox('X', font_style.size_enum, font_style.font)

        words = split_preserve_one_space(atom.text)
        line_frag = ''

        until words.empty?
          word = words[0]

          new_frag = line_frag + word
          old_x_pos = new_x_pos
          new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.size_enum, font_style.font)[0]
          if new_x_pos > right
            loc = { x: x_pos.to_i, y: new_y_pos.to_i }
            lab = loc.merge(make_text_label(line_frag.rstrip!, font_style, item))
            row << lab
            center_row(row, old_x_pos - rect.x, rect) if style.text_align == :center
            output_labels << row.dup
            row.clear
            line_frag = ''
            x_pos = rect.x

            # line space after soft wrap
            new_y_pos -= style.size_px * style.line_spacing
          else
            ### CHANGED
            line_frag = new_frag # + ' '
            words.shift
          end

          next unless words.empty?

          loc = { x: x_pos.to_i, y: new_y_pos.to_i }
          lab = loc.merge(make_text_label(line_frag, font_style, item))
          row << lab
          x_pos = new_x_pos # + default_space_w
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = rect.x

            center_row(row, new_x_pos - rect.x, rect) if style.text_align == :center
            output_labels << row.dup
            row.clear

            # line space after hard wrap
            new_y_pos -= style.size_px * style.line_spacing
          end

          # we made it this far and this is the last atom? add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= style.size_px * style.line_spacing
            new_y_pos -= style.size_px * style.spacing_after
          end
        end

        # this is the last atom and it's empty but the paragraph is not empty?
        # (interpolation will do this), apply paragraph spacing now because
        # we won't get there otherwise
        if  atom[:text] == '' &&
            !empty_paragraph &&
            i == item.atoms.size - 1
          new_y_pos -= style.size_px * style.line_spacing
          new_y_pos -= style.size_px * style.spacing_after
        end
      end

      if row.any?
        row[-1].text.rstrip!
        center_row(row, new_x_pos - rect.x, rect) if style.text_align == :center
        output_labels += row
      end

      data.primitives << output_labels

      # return the y_pos for the next element
      y = empty_paragraph ? y_pos : new_y_pos
      [y, output_labels]
    end

    def display_justified_text(outer_rect, y_pos, item)
      # "==== def display_justified_text(outer_rect, y_pos, item) | #{Kernel.tick_count}"

      style = data.style[item.type]
      style.size_px ||= args.gtk.calcstringbox('X', style.size_enum, style.font)[1]
      output_labels = []
      row = []
      space_w = 0
      rect = outer_rect.dup
      x_pos = rect.x
      new_y_pos = y_pos

      if @last_printed_element_type == item.type
        # paragraph follows paragraph, so undo the added 'spacing after'
        new_y_pos += style.size_px * style.spacing_after
        # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= style.size_px * style.spacing_between
      end

      args.state.forked.forked_display_last_element_empty = false

      empty_paragraph = true # until proven false
      current_row_w = 0

      item.atoms.each_with_index do |atom, i|
        # "=== item.atoms.each_with_index do |#{atom}, #{i}|"

        # when we're at the end of the paragraph and no atoms have had any text
        # mark it as empty so we know not to remove added 'spacing after'
        empty_paragraph = false if atom[:text].strip != ''

        if i == item.atoms.size - 1 && empty_paragraph
          args.state.forked.forked_display_last_element_empty = true
          # previous element was a paragraph? remove the between spacing
          new_y_pos += style.size_px * style.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          new_y_pos -= style.size_px * style.spacing_after
        end

        font_style = get_font_style(atom.styles)
        space_w, font_style.size_px = args.gtk.calcstringbox(' ', font_style.size_enum, font_style.font)
        words = split_preserve_one_space(atom.text)

        until words.empty?
          word = words.shift
          next if word.empty?

          word_w = gtk.calcstringbox(word, font_style.size_enum, font_style.font)[0]
          next_row_w = current_row_w + word_w - space_w

          if next_row_w > rect.w
            new_y_pos -= style.size_px * style.line_spacing
            final_row_w = current_row_w - space_w
            row_justify(row, final_row_w, rect)
            output_labels << row
            row = []
            current_row_w = 0
            next_row_w = word_w - space_w
          end

          loc = { x: rect.x + current_row_w, y: new_y_pos.to_i }
          lab = loc.merge(make_text_label(word, font_style, item))
          row << lab
          current_row_w = next_row_w + space_w

          next unless words.empty?

          if atom.text[-1] == "\n"
            # hard wrap if there's a newline at the end of the text
            x_pos = rect.x
            current_row_w = 0
            new_y_pos -= style.size_px * style.line_spacing
          end

          # add line and paragraph spacing
          if i == item.atoms.size - 1
            new_y_pos -= style.size_px * style.line_spacing
            new_y_pos -= style.size_px * style.spacing_after
          end
        end

        output_labels << row
      end

      data.primitives << output_labels
      y = empty_paragraph ? y_pos : new_y_pos
      [y, output_labels]
    end

    # make a one line label in the specified style
    def make_text_label(text, font_style, item)
      {
        text: text,
        **data.style.blockquote,
        **font_style,
        a: item.a,
      }.label! #(data.style.blockquote).merge!(font_style)
    end

    def align_row_replaced_Jun_11_2025_for_justify_changes row, row_w, rect, style
      return unless (align = style&.text_align)

      case(align)
      when :left
        # do nothing in this case
      when :right
        row_align_right(row, row_w, rect)
      when :center
        center_row(row, row_w, rect)
      # when :justify
        # row_justify(row, row_w, rect)
      else
        raise "Forked Error: invalid text-align value #{align}"
      end
    end

    def align_row row, row_w, rect, style
      # "==== def align_row row, row_w, rect, style"
      return unless (align = style&.text_align)

      case(align)
      when :left, :justify
        # do nothing in this case
      when :right
        row_align_right(row, row_w, rect)
      when :center
        center_row(row, row_w, rect)
      else
        raise "Forked Error: invalid text-align value #{align}"
      end
    end

    def center_row row, row_w, rect
      rect_mid = rect.w / 2
      row_mid = row_w / 2
      row.each do |r|
        r.x += rect_mid - row_mid
      end
    end

    def row_align_right row, row_w, rect
      # "==== def row_align_right row, row_w, rect"
      remaining_space = rect.w - row_w
      raise("Space is negative") if remaining_space.negative?

      row.each do |r|
        r.x += remaining_space
      end
    end

    def row_justify(row, row_w, rect)
      # "==== def row_justify(row, #{row_w}, #{rect}) | #{row.size}"
      return if row.empty?

      raise "Forked Error: Row Width (#{row_w}) is greater than display rect width (#{rect.w}.)" if row_w > rect.w

      remnant = rect.w - row_w
      num_spaces = row.size - 1
      spacer_size = remnant / num_spaces

      row.each_with_index do |word, i|
        word.x += spacer_size * i
      end
    end
  end
end