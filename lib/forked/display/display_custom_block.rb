module Forked
  class Display
    def display_custom_block(y_pos, item)
      # "==== def display_custom_block(#{y_pos}, #{item}) | caller: #{caller}"

      custom_blocks = Parser.custom_block_list
      element_name = item.type
      return unless custom_blocks.include?(element_name)

      method_name = "display_#{element_name}".to_sym
      return unless self.methods.include?(:display_button_row)

      method(method_name).call(y_pos, item)
    end
  end
end