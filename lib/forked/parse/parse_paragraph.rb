module Forked
  # Forked story file parser
  class Parser
    class << self
      def parse_paragraph(line, context, story, _line_no)
        # check credentials
        prohibited_contexts = [:title, :code_block, :heading, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        conditional = false
        line.strip!

        # anything that comes here is either a paragraph or a blank line.
        # handle context open/opening/closing
        context_state = handle_paragraph_context(line, context)
        # when the line ends with `\`, hard wrap
        if line.strip[-1] == '\\'
          # terminate the line with a newline
          # add an nbsp to prevent empty lines from collapsing
          line = line.delete_suffix('\\') + " \n"
        end

        # new paragraph condition:
        # context was closed, now open
        if context_state == :opening
          story[:chunks][-1][:content] << make_paragraph_hash
          context_state = :open
        end

        return if line.strip.empty?

        # new atom condition
        # context is open
        if context_state == :open

          atoms = []
          if line == '«««INTER»»»' # internal placeholder for interpolation
            conditional = true
            line = ''
            atoms << make_atom_hash
          end

          ######
          # APPLY INLINE STYLES HERE
          ######

          while !line.empty?
            first_idx1 = 10000000
            first_idx2 = first_idx1
            first_mark = {}

            @style_marks.each do |m|
              next unless (idx1 = line.index(m.mark))
              next unless idx1 < first_idx1
              next unless (idx2 = line.index(m.mark, idx1 + 1))

              first_idx1 = idx1
              first_idx2 = idx2
              first_mark = m
            end

            if first_mark.empty?
              line = unescape(line, @escapable)
              atoms << make_atom_hash(line)
              line = ''
            else
              left_text = unescape(line[0...first_idx1], @escapable)
              marked_text = unescape(line[first_idx1 + first_mark[:mark].length...first_idx2], @escapable)

              line = line[first_idx2 + first_mark[:mark].length..-1]

              atoms << make_atom_hash(left_text) unless left_text.empty?
              atoms << make_atom_hash(marked_text, [first_mark[:symbol]])
            end
          end

          ######
          # INLINE STYLES DONE
          ######

          # if prev item is not a paragraph, make a new paragraph
          prev_item = story[:chunks][-1][:content][-1]
          unless prev_item[:type] == :paragraph
            story[:chunks][-1][:content] << make_paragraph_hash
          end
          # add a space to the last new atom
          atoms[-1].text += ' ' unless atoms.empty? || atoms[-1].text.end_with?("\n")
          story[:chunks][-1][:content][-1][:atoms] += atoms
        end

        # apply conditions to paragraph atoms
        if context.include?(:condition_block) || conditional
          condition = story[:chunks][-1][:conditions][-1]
          prev_item = story[:chunks][-1][:content][-1]
          if prev_item[:atoms]
            if !prev_item[:atoms].empty?
              prev_item[:atoms][-1][:condition] = condition
              prev_item[:atoms][-1][:condition_segment] = @condition_segment_count
            else
              prev_item[:atoms] << make_atom_hash('', [], condition, @condition_segment_count)
            end
          else
            prev_item[:condition] = condition
          end
        end
      end

      # version of parse_paragraph intended to add content to
      # most recently opened content array and thus work with
      # generic elements
      def parse_paragraph2(line, context, story, _line_no)
        # check credentials
        prohibited_contexts = [:title, :code_block, :heading, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        conditional = false
        line.strip!

        # anything that comes here is either a paragraph or a blank line.
        # handle context open/opening/closing
        context_state = handle_paragraph_context(line, context)
        # when the line ends with `\`, hard wrap
        if line.strip[-1] == '\\'
          # terminate the line with a newline
          # add an nbsp to prevent empty lines from collapsing
          line = line.delete_suffix('\\') + " \n"
        end

        # new paragraph condition:
        # context was closed, now open
        if context_state == :opening
          # story[:chunks][-1][:content] << make_paragraph_hash
          last_content(story, context) << make_paragraph_hash
          context_state = :open
        end

        return if line.strip.empty?

        # new atom condition
        # context is open
        if context_state == :open

          atoms = []
          if line == '«««INTER»»»' # internal placeholder for interpolation
            conditional = true
            line = ''
            atoms << make_atom_hash
          end

          ######
          # APPLY INLINE STYLES HERE
          ######

          while !line.empty?
            first_idx1 = 10000000
            first_idx2 = first_idx1
            first_mark = {}

            @style_marks.each do |m|
              next unless (idx1 = line.index(m.mark))
              next unless idx1 < first_idx1
              next unless (idx2 = line.index(m.mark, idx1 + 1))

              first_idx1 = idx1
              first_idx2 = idx2
              first_mark = m
            end

            if first_mark.empty?
              line = unescape(line, @escapable)
              atoms << make_atom_hash(line)
              line = ''
            else
              left_text = unescape(line[0...first_idx1], @escapable)
              marked_text = unescape(line[first_idx1 + first_mark[:mark].length...first_idx2], @escapable)

              line = line[first_idx2 + first_mark[:mark].length..-1]

              atoms << make_atom_hash(left_text) unless left_text.empty?
              atoms << make_atom_hash(marked_text, [first_mark[:symbol]])
            end
          end

          ######
          # INLINE STYLES DONE
          ######

          # if prev item is not a paragraph, make a new paragraph
          prev_item = last_element(story)
          if prev_item[:type] != :paragraph
            last_content(story, context) << make_paragraph_hash
          end
          # add a space to the last new atom
          atoms[-1].text += ' ' unless atoms.empty? || atoms[-1].text.end_with?("\n")
          last_content(story, context)[-1][:atoms] += atoms
        end

        # apply conditions to paragraph atoms
        if context.include?(:condition_block) || conditional
          condition = story[:chunks][-1][:conditions][-1]
          prev_item = story[:chunks][-1][:content][-1]
          if prev_item[:atoms]
            if !prev_item[:atoms].empty?
              prev_item[:atoms][-1][:condition] = condition
              prev_item[:atoms][-1][:condition_segment] = @condition_segment_count
            else
              prev_item[:atoms] << make_atom_hash('', [], condition, @condition_segment_count)
            end
          else
            prev_item[:condition] = condition
          end
        end
      end

      def handle_paragraph_context(line, context)
        if line.empty? && context.include?(:paragraph)
          # capture context closing
          context.delete(:paragraph) if context.include?(:paragraph)
          context_state = :closing
        elsif !context.include?(:paragraph) && !line.empty?
          # capture context opening
          context << :paragraph
          context_state = :opening
        elsif context.include?(:paragraph)
          context_state = :open
        end

        context_state
      end

      def make_paragraph_hash
        {
          type: :paragraph,
          atoms: []
        }
      end
    end
  end
end
