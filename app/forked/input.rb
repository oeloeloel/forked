module Forked
  class << self
    def keyboard_input_defaults
      {
        next:       [:down,  :right],
        prev:       [:up,    :left],
        activate:   [:space, :enter],
      }
    end

    def controller_input_defaults
      {
        next:     [:down, :right      ],
        prev:     [:up,   :left       ],
        activate: [:a,    :b, :r1, :r2]
      }
    end
  end
end

# alt
# meta
# control
# shift
# ctrl_KEY (dynamic method, eg args.inputs.keyboard.ctrl_a)
# exclamation_point
# zero - nine
# backspace
# delete
# escape
# enter
# tab
# (open|close)_round_brace
# (open|close)_curly_brace
# (open|close)_square_brace
# colon
# semicolon
# equal_sign
# hyphen
# space
# dollar_sign
# double_quotation_mark
# single_quotation_mark
# backtick
# tilde
# period
# comma
# pipe
# underscore
# a - z
# shift
# control
# alt
# meta
# left
# right
# up
# down
# pageup
# pagedown
# plus
# at
# forward_slash
# back_slash
# asterisk
# less_than
# greater_than
# carat
# ampersand
# superscript_two
# circumflex
# question_mark
# section_sign
# ordinal_indicator
# raw_key (unique numeric identifier for key)
# left_right
# up_down
# directional_vector
# truthy_keys (array of Symbols)