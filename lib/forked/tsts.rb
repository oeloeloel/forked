module Forked
  class Story
    ################
    # FORKED TESTING
    ################

    # Testing Boolean Conditions does not update the test data file
    # [ ] don't update the test expectation if there is no id

    # Initialize the test data
    # Load the test data from a file
    # Or create a new file if it does not exist
    def ftest_init(file)
      # "==== def ftest_init(file)"
      putz "loaded file #{file}"

      @test_data_file_path = ftest_data_file_path file

      # attempt to load the test data file 
      result = load_ftest_data_file file

      # check to see if the test data file exists
      if result
        # eval the test data and store it in the ftest_data hash
        @ftest_data = eval(result)
      else
        # if the test data file does not exist, create a new empty hash
        # and save it in a new file
        @ftest_data = {}
        save_ftest_data_file
      end
    end

    ### FILE HANDLING

    # take the file path of the current test file
    # and use it to create a path to the test data file
    def ftest_data_file_path file
      path_array = file.split("/")
      path_array.insert(-2, "ftest_data")
      "/#{path_array.join("/")}"
    end

    # load the test data file
    def load_ftest_data_file(file)
      gtk.read_file (ftest_data_file_path file)
    end

    # save the test data file
    def save_ftest_data_file
      gtk.write_file (@test_data_file_path), @ftest_data.to_s
    end

    ### MAIN TEST

    # Forked test function, called from the test file
    # This function will compare the subject hash to the expectation hash
    # If they match, the test passes
    # If they do not match, the test fails
    def forked_test(test_id: nil, expect: nil)
      # if no expect and no id, error out
      unless test_id || expect
        raise "No test id or expectation provided"
      end

      subject_hash = identify_test_subject
      expect = identify_expectation test_id, expect

      # putz "identified expectation: #{expect}"
      # This block is not needed but maybe a warning would be helpful here
      # if !expect
      #   raise "No expectation found for test id: #{test_id}"
      # end

      # expectation does not match subject
      if expect != subject_hash
        ftest_result_fail(test_id, subject_hash)
        return "Test failed"
      end

      # expectation matches subject
      ftest_result_success test_id
      "Test passed"
    end


    # return the provided expectation hash
    # if no expectation is provided, return the saved expectation
    def identify_expectation test_id, expect
      # puts "==== def identify_expectation expect"

      if expect
        expect
      else
        @ftest_data[test_id]
      end
    end

    def update_expectation test_id, expectation
      unless test_id
        raise "No test id provided"
      end
      @ftest_data[test_id] = expectation
      save_ftest_data_file
    end

    def identify_test_subject
      # "==== def identify_test_subject"
      return if outputs.primitives.empty?

      test_mark = []
      # it's easy to misremember the corret syntax for the test markers, so similar formulations are allowed
      valid_starts = ["<! start test !>", "<! test start !>", "<! start_test !>", "<! test_start !>"]
      valid_ends = ["<! end test !>", "<! test end !>", "<! end_test !>", "<! test_end !>"]
      outputs.primitives.each_with_index do |prim, i|
        if prim&.text && valid_starts.any?(prim&.text&.strip)
          test_mark << i + 1
        elsif prim&.text && valid_ends.any?(prim&.text&.strip) 
          test_mark << i - 1
        end
      end

      # did not find the required test markers
      if test_mark.count < 2
        puts "Testing Error: Test does not contain two testing markers. "\
        "Tests require two markers to be placed around the area to be tested: "\
        "'<! start test !> and '<! end test !>."
        return "Testing Error"
      end

      subject = outputs.primitives[test_mark[0]..test_mark[1]]
      subject.to_s.hash
    end

    def ftest_result_success(id)
      out = "Test "
      out << "'#{id} '" if id
      out << "passed."
      outputs.debug << "test passed"
    end

    def ftest_result_fail(id, expectation)
      # puts "==== def ftest_result_fail(id)"
      xoff = 20
      y = 60
      font_size = -2
      white = { r: 255, g: 255, b: 255 }

      fail_message = { 
        x: xoff, y: y, 
        text: "Test failed",
        size_enum: font_size,
        anchor_y: 0.5,
        **white
      }

      xoff += 200
      bw = 180
      bh = 30

      button_box = {
        x: xoff, y: y, w: bw, h: bh, 
        anchor_y: 0.5, anchor_x: 0.5,
        path: :pixel
      }

      button_label = {
        x: xoff, y: y, text: "Save New Expectation",
        anchor_x: 0.5, anchor_y: 0.5, size_enum: font_size,
      }

      prims = [ fail_message, button_box, button_label ]

      outputs.debug << prims

      mouse = inputs.mouse
      button_over = mouse.point.inside_rect?({ x: xoff, y: y, w: bw, h: bh, anchor_x: 0.5, anchor_y: 0.5 } )

      if mouse.click && button_over
        update_expectation id, expectation
      end
    end
  end
end
