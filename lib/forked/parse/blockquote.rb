module Forked
  class Parser
    class << self

      def parse_blockquote(line, context, story, line_no)
        # validate entry

        prohibited_contexts = [:title, :code_block, :heading, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = []
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        return unless line.strip.start_with?('>') || context.include?(:blockquote)

        if line.strip.start_with?('>')
          line.delete_prefix!('>')
          return if line.strip.empty?

          unless context.include?(:blockquote)
            context_open(context, :blockquote)
            story[:chunks][-1][:content] << make_blockquote_hash
          end
        # close context
        elsif line.strip.empty?
          context_close(context, :blockquote)
          return nil
        end

        line.strip! # remove the terminal \n (and any spaces lingering at the front)
        # open context

        if context.include?(:blockquote)
          parse_blockquote_paragraph(line, context, story, line_no)
          return true
        end
      end

      def parse_blockquote_paragraph(line, context, story, line_no)
        prohibited_contexts = []
        # prohibited_contexts = [:title, :code_block, :heading, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = [:blockquote]
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        conditional = false

        context_state = handle_paragraph_context(line, context)
        # when the line ends with `\`, hard wrap
        if (line.strip[-1] == '\\')
          # terminate the line with a newline
          # add an nbsp to prevent empty lines from collapsing
          line = line.delete_suffix('\\') + " \n"
        end

        # new paragraph condition:
        # context was closed, now open
        if context_state == :opening
          story[:chunks][-1][:content][-1][:content] << make_blockquote_paragraph_hash
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
            atoms << make_atom_hash()
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
          prev_item = story[:chunks][-1][:content][-1][:content][-1]

          if story.chunks[-1].content[-1]&.type == :blockquote &&
             story.chunks[-1].content[-1].content[-1]&.type == :blockquote_paragraph
          else
            story[:chunks][-1][:content][-1][:content] << make_blockquote_paragraph_hash
          end

          # add a space to the last new atom
          atoms[-1].text += ' ' unless atoms.empty? || atoms[-1].text.end_with?("\n")
          story[:chunks][-1][:content][-1][:content][-1][:atoms] += atoms
        end

        # apply conditions to paragraph atoms
        if context.include?(:condition_block) || conditional
          condition = story[:chunks][-1][:conditions][-1]
          prev_item = story[:chunks][-1][:content][-1][:content][-1]
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

        return true
      end

      def handle_blockquote_paragraph_context(line, context)
        if line.empty? && context.include?(:blockquote_paragraph)
          # capture context closing
          context.delete(:blockquote_paragraph) if context.include?(:blockquote_paragraph)
          context_state = :closing
        elsif !context.include?(:blockquote_paragraph) && !line.empty?
          # capture context opening
          context << :blockquote_paragraph
          context_state = :opening
        elsif context.include?(:blockquote_paragraph)
          context_state = :open
        else
          # blank line probably 
        end

        return context_state
      end

      def context_open(context, to_add)
        return if context.include?(to_add)

        context << to_add
      end

      def context_close(context, to_delete)
        return unless context.include?(to_delete)

        context.delete(to_delete)
      end

      def parse_blockquote_old_2(line, context, story, line_no)
        
        # there are 2 open/close contexts to worry about
        # 1. If the blockquote is open, everything is
        #    added to the currently open paragraph
        #    The context is closed only when an
        #    entirely blank line is found (and the
        #    context is open).
        # 2. If the blockquote is open and a line
        #    is found that contains only a `>` (there
        #    is no non-whitespace character following
        #    it), then there is a paragraph context
        #    that is closed within the blockquote
        # 
        # paragraph should automatically be
        # closed when a new blockquote is found
        # but paragraph could be allowed to exist
        # if a blockquote is already open
        #
        # Logic:
        # 1. BQ context is closed, line starts >
        #   a. open BQ context
        # 2. BQ context open, line starts >
        #    & line != >[blank], BQP context closed
        #   a. open BQP context
        #   b. add BQP to BQ
        #   c. add text to paragraph
        # 3. BQ context open, BQP context open 
        #    & line == >[blank]
        #   a. close BQP context
        # 4. BQ context open & line == [blank]
        #   a. close BQP context if open
        #   b. close BQ context if open
        # 5. BQ context is open & line !=[blank]
        #   a. 

        # BQ
        # * if BQ closed & line.start > & line.not >[blank]
        #   * open BQ
        # * IF BQ open & line.blank
        #   * close BQ

        # BQP
        # * if BQ open
        #   * if line.not >blank
        
        
        
        # check credentials
        prohibited_contexts = []
        # prohibited_contexts = [:title, :code_block, :heading, :action_block, :condition_code_block, :trigger_action]
        mandatory_contexts = [:blockquote]
        return unless context_safe?(context, prohibited_contexts, mandatory_contexts)

        return unless line.strip.start_with?('>')
        conditional = false
        line.strip!

        # anything that comes here is either a blockquote or a blank line.
        # handle context open/opening/closing
        context_state = handle_blockquote_context(line, context)
       
        # strip opening mark
        if line.strip.start_with?('>')
          # line.strip!
          line.delete_prefix!('>')
          line.strip!
        end
        
        # when the line ends with `\`, hard wrap
        if(line.strip[-1] == '\\')
          # terminate the line with a newline
          # add an nbsp to prevent empty lines from collapsing
          line = line.delete_suffix('\\') + " \n"
        end

        # new blockquote condition:
        # context was closed, now open
        if context_state == :opening
          story[:chunks][-1][:content] << make_blockquote_hash
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
            atoms << make_atom_hash()
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
          
          # if prev item is not a blockquote, make a new blockquote
          prev_item = story[:chunks][-1][:content][-1]
          unless prev_item[:type] == :blockquote
            story[:chunks][-1][:content] << make_blockquote_hash
            putz "made blockquote hash #{story[:chunks][-1][:content]}"
          end
          # add a space to the last new atom
          atoms[-1].text += ' ' unless atoms.empty? || atoms[-1].text.end_with?("\n")
          story[:chunks][-1][:content][-1][:atoms] += atoms
        end

        # apply conditions to blockquote atoms
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

        return true
      end

      # def handle_blockquote_context(line, context)
      #   if line.empty? && context.include?(:blockquote)
      #     # capture context closing
      #     context.delete(:blockquote) if context.include?(:blockquote)
      #     context_state = :closing
      #   elsif !context.include?(:blockquote) && !line.empty?
      #     # capture context opening
      #     context << :blockquote
      #     context_state = :opening
      #   elsif context.include?(:blockquote)
      #     context_state = :open
      #   else
      #     # blank line probably 
      #   end

      #   return context_state
      # end

      def make_blockquote_hash
        {
          type: :blockquote,
          content: []
        }
      end

      def make_blockquote_paragraph_hash
        {
          type: :blockquote_paragraph,
          atoms: []
        }
      end
    end
  end
end