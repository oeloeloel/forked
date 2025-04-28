module Forked
  class << self
    def keyboard_input_defaults
      {
        next:         [:tab              ],
        prev:         [:shift_tab        ],
        next_visible: [:right,     :d    ],
        prev_visible: [:left,      :a    ],
        down:         [:down,      :s    ],
        up:           [:up,        :w    ],
        page_up:      [:page_up          ],
        page_down:    [:page_down        ],
        home:         [:home             ],
        end:          [:end              ],
        activate:     [:space,     :enter],
      }
    end

    def controller_input_defaults
      {
        next:          [:r1        ],
        prev:          [:l1        ],
        next_visible:  [:right     ],
        prev_visible:  [:left      ],
        down:          [:down      ],
        up:            [:up        ],
        page_up:       [:r2        ],
        page_down:     [:l2        ],
        home:          [           ],
        end:           [           ],
        activate:      [:a,     :b,]
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