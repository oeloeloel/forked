# Navigation Tests

## Begin on first chunk {#first}

The first chunk must always load first

[Next](#)

## Fall through to next chunk A

Button action `#` navigates to next chunk in file, if chunk exists.

[Next](#)

## Fall through to next chunk B
Story navigated to this chunk from the preceding chunk.

[Next](#)
<: 
  ```rb
    $expect = $story.history[-2...$story.history.size] == [1, 2]
  ```
:>

<: $expect ? "Test passed " : "Test failed" :>

## Navigate to chunk by ID A

Button action `#chunk_id` navigates to named ID

[Next](#navigate-to-chunk-id)

## Navigate to chunk by ID B {#navigate-to-chunk-id}

Button action `#chunk_id` navigated to this chunk.

[Next](#)

<: 
  ```rb
    $expect = $story.history[-2...$story.history.size] == [3, 4]
    $expect ? "Test passed " : "Test failed"
  ```
:>

## Navigate to chunk by relative index A

Button action `jump(2)` navigates to 2 chunks below.

[Next](: jump(2) :)

## Navigate to chunk by relative index C
Button action `jump(-1)` navigated to this chunk

[Next](: jump(2) :)

## Navigate to chunk by relative index B

Button action `jump(2)` navigated to this chunk

Button action `jump(-1)` navigates to chunk above.

[Next](: jump(-1) :)

<: 
  ```rb
    # puts $story.history[-2...$story.history.size]
    $expect = $story.history[-2...$story.history.size] == [5, 7]
    $expect ? "Test passed " : "Test failed"
  ```
:>

## Button contains code, no navigation

[code only button](: puts "code only button clicked" :)
[Next](#)

## Tests Complete
All tests are complete.

[Begin again](#first)