
# isolate all buttons in story and check that the target IDs exist
# checks ID targets like `(#chunk_id)` 
# as well as jump calls in Ruby code like `jump('#chunk_id')`
def validate_links(verbose = false, limit = 10000000)
  links = get_links

  num_buttons = 0
  num_target_links = 0
  num_code_only = 0
  num_jump_links = 0
  num_invalid_links = 0


  outputz = "=============================\nValidating Links\n"
  num_chunks = links.size

  links.each_with_index do |chunk_links, current_chunk_num|
    chunk_identity_str = "## #{chunk_links.keys[0][1]} {#{chunk_links.keys[0][0]}}"
    chunk_identity_str_output = false
    matched_link_to_id = false

    num_links = chunk_links.values.size
    chunk_links.values[0].each do |link|
      num_buttons += 1
      matched_link_to_id = false
      button_str = "[#{link[0]}](#{link[1]})"

      # identify fall through links (#)
      if action_has_fall_through?(link)
        link[1] = 'jump(1)'
      end

      # identify code actions
      if action_is_code?(link)

        ## identify jumps to named ids
        if target = action_has_jump?(link)
          link[1] = "##{target[1]}"
          num_jump_links += 1

          # identify relative navigation in code
          # fall, rise, jump(2), jump(-1)

        elsif target = action_has_relative_jump?(link) 
          target_num = current_chunk_num + target[1]
          if target_num >= 0 && target_num <= num_chunks - 1
            link[1] = links[target_num].keys[0][0]
          else
            link[1] = target[1]
          end
          num_jump_links += 1
        else

          # identify code only actions
          num_code_only += 1
          matched_link_to_id = true
          
        end
      else # link is to a non-code action (starts with #)
        # identify links to named ids
        num_target_links += 1
      end

      button_str_output = false
      links.each do |chunk_targets|
        # verify links have matching chunk ids in story
        if link[1] == chunk_targets.keys[0][0]
          if verbose && !chunk_identity_str_output 
            chunk_identity_str_output = true
            outputz += "================================\n" if limit >= 0 && verbose
            outputz +=  chunk_identity_str + "\n" if limit >= 0 && verbose
          end 
          outputz += "    Matched: #{chunk_targets.keys[0][0]} | #{button_str}\n" if limit >= 0 && verbose
          matched_link_to_id = true

          next
        end
      end
      unless matched_link_to_id
        limit -= 1
        if !chunk_identity_str_output && limit >= 0
          chunk_identity_str_output = true
          outputz += "================================\n"
          outputz +=  chunk_identity_str + "\n"
        end
        unless button_str_output
          button_str_output = true
        end
        outputz += "    Not Matched: #{link[1]} | #{button_str}\n" if limit >= 0
        num_invalid_links += 1
      end
    end
  end

  outputz += "================================\n"
  outputz += "Total number of buttons: #{num_buttons}\n" if verbose
  outputz += "  Number of buttons linking to chunk IDs: #{num_target_links}\n" if verbose
  outputz += "  Number of buttons with jump code: #{num_jump_links}\n" if verbose
  outputz += "  Number of buttons with code only: #{num_code_only}\n" if verbose
  outputz += "Number of invalid links: #{num_invalid_links}\n"
  outputz += "================================"
end

# returns true if action is not formatted as a chunk ID
def action_is_code?(link)
  !link[1].start_with?('#')
end

# returns the target of the jump command if code contains a jump command
def action_has_jump?(link)
  # TODO: MAKE MORE ROBUST. Go through code linewise, split lines by `;`
  # but check the semicolon isn't inside a string.
  # Make sure "jump" is a complete word (not a longer word) and is not
  # inside a string... or some other non-executable form?
  return unless link[1].include?("jump")



  id = link[1].dup
  if    try = pull_out("jump('#", "')", id)
  elsif try = pull_out('jump("#', '")', id)
  elsif try = pull_out("jump '#", "'",  id)
  elsif try = pull_out('jump "#', '"',  id)
  end

  try
end

def action_has_relative_jump?(link)
  id = link[1].dup.strip + "œ∑ƒ"
  if try = pull_out('jump(', ')', id)
  elsif try = pull_out('jump ', ' ', id)
  elsif try = pull_out('jump ', "\n", id)
  elsif try = pull_out('jump ', "œ∑ƒ", id)
  end

  if try && try[1] && string_is_valid_number?(try[1])
    try[1] = try[1].to_i
    return try
  end

  nil
end

def action_has_fall_through?(link)
  link[1] == "#"
end

def get_links
  $args.state.forked.story.chunks.map do |chunk|
    {
      [chunk.id, chunk.content[0].text] => 
      chunk.content.map do |element|
        tmp = nil
        if element.type == :button
          tmp = [element.text, element.action]
        end
        tmp
      end.compact!
    }
  end
end

def get_headings
  $args.state.forked.story.chunks.map do |chunk|
    [chunk.id, chunk.content[0].text]
  end
end

def pull_out left, right, str
  left_index = str.index(left)

  if left_index
    right_index = str.index(right, left.length)
  end
  return unless left_index && right_index

  pulled = str.slice!(left_index + left.size..right_index - 1)
  str.sub!(left + right, '')
  [str.strip + "\n", pulled.strip]
end

def string_is_valid_number?(str)
  str.each_char do |c| 
    return false if (c.ord < 48 || c.ord > 57) && c.ord != 45
  end

  true
end

# strip out comments from a single line of ruby
# returns nil if no comment was found
# returns non-comment portion of line if comment was found

def strip_ruby_comment_from_line(line)
  # bounce out if no # symbol
  return unless line.include?('#')

  # if first non-whitespace character is #
  if line.strip.start_with?('#')
    return ''
  # if line includes # somewhere other than start
  elsif line.include?(' #')
    # get the index of the [space]# characters
    index = line.index(' #')
    # ignore if the # symbol is inside a string
    return line[0...index]
  end

  nil
end

# provided with a string representing Ruby code
# and an integer representing an index in the string
# returns true if the index is enclosed in quotes " or '
def index_is_in_string_in_string(line)

end