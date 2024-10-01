
module Forked
  # Display class
  class Display
    ### RULE

    def display_rule(y_pos, item, _previous_element_type)
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

      y_pos - rule.spacing_after
    end
  end
end