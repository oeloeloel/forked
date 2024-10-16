module Forked
  # Display class
  class Display
    def display_callout(y_pos, item)
      return y_pos if item.content.empty?

      display = data.style.display
      style = data.style.callout
      box = data.style.callout_box || default_box

      display_box = {
        x: display.margin_left,
        y: display.margin_bottom,
        w: display.w,
        h: display.h,
      }.border!

      outer_rect = {
        x: display_box.x,
        w: display.w,
        h: 0,
        y: y_pos,
        anchor_y: 1
      }

      rect = {
        x: outer_rect.x + box.margin_left,
        w: outer_rect.w - box.margin_left - box.margin_right,
        h: box.margin_top + box.margin_bottom,
        y: outer_rect.y - box.margin_top,
        anchor_y: 1
      }

      inner_rect = {
        x: rect.x + box.padding_left,
        h: rect.h - (box.padding_top + box.padding_bottom),
        y: rect.y - box.padding_top,
        w: rect.w - box.padding_left - box.padding_right,
        anchor_y: 1
      }

      rect.h = rect.h.greater(inner_rect.h + box.padding_top + box.padding_bottom)
      outer_rect.h = outer_rect.h.greater(rect.h + box.margin_top + box.margin_bottom) 

      next_y_pos = inner_rect.y
      labels = []
      image_box = nil
      text_rect = nil
      im = nil

      # if there is an image
      #   if the image is first
      if item.content.first.type == :image
        image_box = inner_rect.dup
        im = display_callout_image(image_box, item.content.first, :left)
      elsif item.content.last.type == :image
        image_box = inner_rect.dup
        im = display_callout_image(image_box, item.content.last, :right)
      end

      inner_rect = image_box if image_box
      #     display image on right
      #   if the image is anywhere else
      #     don't display the image

      # if there is text
      #   display text in remaining space not consumed by image

      item.content.each do |part|
        if part.type == :paragraph
          text_rect = inner_rect.dup
          result = display_callout_paragraph(text_rect, next_y_pos, part)
          @last_printed_element_type = :callout_paragraph
          labels << result[1]
          next_y_pos = result[0]
          text_rect.h = text_rect.y - next_y_pos
        end
      end

      # get out if no valid elements to display
      return y_pos if image_box.nil? && text_rect.nil?

      inner_rect.h = (image_box&.h || 0).greater(text_rect&.h || 0)
      rect.h = inner_rect.h + box.padding_top + box.padding_bottom
      outer_rect.h = rect.h + box.margin_top + box.margin_bottom
      next_y_pos = outer_rect.y - outer_rect.h
      style.size_px = size_enum_to_size_px(style.size_enum)

      bg_rect = {
        x: rect.x,
        y: rect.y - rect.h,
        w: rect.w,
        h: rect.h,
        r: box.r,
        g: box.g,
        b: box.b,
        anchor_y: 1
      }

      bg = Effed.rounded_panel(rect: bg_rect)
      data.primitives << [bg, labels, im]

      # outputs.static_debug << [
      #   outer_rect.dup.border!(r: 255),
      #   rect.dup.border!(g: 255),
      #   inner_rect.dup.border!(b: 255, g: 255)
      # ]

      next_y_pos
    end

    def display_callout_paragraph(outer_rect, y_pos, item)
      callout = data.style.paragraph
      callout_box = data.style.callout_box
      display = data.style.display

      callout.size_px = args.gtk.calcstringbox('X', callout.size_enum, callout.font)[1]
      output_labels = []

      rect = {
        **outer_rect
      }

      right = rect.w + rect.x

      new_y_pos = y_pos
      x_pos = rect.x

      # if @last_printed_element_type == :callout_paragraph
      #   # paragraph follows paragraph, so undo the added 'spacing after'
      #   new_y_pos += blockquote.size_px * blockquote.spacing_after
      #   # paragraph follows paragraph, so add 'spacing between'
      #   new_y_pos -= blockquote.size_px * blockquote.spacing_between
      # else
      #   puts @last_printed_element_type
      # end

      if @last_printed_element_type == :callout_paragraph
      #   # paragraph follows paragraph, so undo the added 'spacing after'
      #   new_y_pos += blockquote.size_px * blockquote.spacing_after
      #   # paragraph follows paragraph, so add 'spacing between'
        new_y_pos -= callout.size_px * callout.spacing_between
      # else
      #   puts @last_printed_element_type
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
          # new_y_pos += blockquote.size_px * blockquote.spacing_between
          # add 'spacing after'. Next element might not be a paragraph.
          # new_y_pos -= blockquote.size_px * blockquote.spacing_after
          # new_y_pos -= blockquote.size_px * blockquote.spacing_between
        end

        font_style = {
          **callout,
          **get_callout_font_style(atom.styles)
        }

        font_style.size_px = args.gtk.calcstringbox('X', font_style.size_enum, font_style.font)[1]
        words = split_preserve_one_space(atom.text)
        line_frag = ''

        until words.empty?
          word = words[0]
          new_frag = line_frag + word
          new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.size_enum, font_style.font)[0]

          if new_x_pos >= right
            loc = { x: x_pos.to_i, y: new_y_pos.to_i }
            lab = loc.merge(make_callout_label(line_frag, font_style))
            output_labels << lab
            line_frag = ''
            x_pos = rect.x

            # line space after soft wrap
            new_y_pos -= callout.size_px * callout.line_spacing
          else
            ### CHANGED
            line_frag = new_frag # + ' '
            words.shift
          end

          next unless words.empty?

          loc = { x: x_pos.to_i, y: new_y_pos.to_i }
          lab = loc.merge(make_blockquote_label(line_frag, font_style))

          output_labels << lab
          x_pos = new_x_pos # + default_space_w
          line_frag = ''
          if atom.text[-1] == "\n"
            x_pos = rect.x

            # line space after hard wrap
            new_y_pos -= callout.size_px * callout.line_spacing
          end

          # we made it this far and this is the last atom? add
          # line spacing and 'spacing after'
          if i == item.atoms.size - 1
            new_y_pos -= callout.size_px * callout.line_spacing
            # new_y_pos -= blockquote.size_px * blockquote.spacing_after
            # new_y_pos -= blockquote.size_px * blockquote.spacing_between
          end
        end

        # this is the last atom and it's empty but the paragraph is not empty?
        # (interpolation will do this), apply paragraph spacing now because
        # we won't get there otherwise
        if  atom[:text] == '' &&
            !empty_paragraph &&
            i == item.atoms.size - 1
          new_y_pos -= callout.size_px * callout.line_spacing
          # new_y_pos -= blockquote.size_px * blockquote.spacing_after
          # new_y_pos -= blockquote.size_px * blockquote.spacing_between
        end
      end

      outer_rect.h = outer_rect.y - new_y_pos

      # outputs.static_debug << {
      #   **outer_rect,
      #   r: 255, g: 255, b: 0, a: 25,
      #   anchor_y: 1
      # }.solid!

      # return the y_pos for the next element
      y = empty_paragraph ? y_pos : new_y_pos

      [y, output_labels]
    end

    # display image 2 accepts a rect representing
    # the space available for the image to occupy
    # display image 3 returns the rect used by the image including the image margins
    def display_callout_image(outer_rect, item, align)
      image = data.style.callout_image
      # display = data.style.display

      if align == :left
      outer_rect.w = outer_rect.w - image.w - image.margin_left - image.margin_right

      image_rect = {
        x: outer_rect.x + image.margin_left,
        y: (outer_rect.y - image.margin_top).to_i,
        w: image.w,
        h: image.h,
        anchor_y: 1,
      }

      outer_rect.h = image_rect.h + image.margin_top + image.margin_bottom
      outer_rect.x += image_rect.w + image.margin_left + image.margin_right

      elsif align == :right
        image_rect = {
          x: outer_rect.w + outer_rect.x - image.w - image.margin_right, 
          y: outer_rect.y - image.margin_top, 
          w: image.w,
          h: image.h,
          anchor_y: 1
        }
  
        outer_rect.h = image_rect.h + image.margin_top + image.margin_bottom
        outer_rect.w -= image_rect.w + image.margin_left + image.margin_right
      end


      # outputs.static_debug << [
      #   outer_rect.dup.border!(r: 255, g: 127),
      #   image_rect.dup.border!(g: 255),
      # ]

      # I don't know why path doesn't work *as is*
      # It's a string, and it doesn't have any odd
      # characters in it
      # But putting it into a _new_ string makes it work
      path = item[:path].strip.to_s
      merger = {}
      if path.end_with?('}') && path.include?('{')
        path, remnant = Forked::Parser.pull_out('{', '}', path)
        merger = eval('{' + remnant + '}')
      end

      # h = merger.h || 80
      # w = merger.w || 80

      im = {
        **image_rect,
        path: path,
      }
      im
    end


    def get_callout_font_style(styles)
      if styles.include?(:bold) && styles.include?(:italic)
        data.style.callout_bold_italic
      elsif styles.include? :bold_italic
        data.style.callout_bold_italic
      elsif styles.include? :bold
        data.style.callout_bold
      elsif styles.include? :italic
        data.style.callout_italic
      elsif styles.include? :code
        data.style.callout_code
      else
        data.style.callout
      end
    end

    def make_callout_label(text, font_style)
      {
        text: text
      }.label!(data.style.callout).merge!(font_style)
    end
  end
end