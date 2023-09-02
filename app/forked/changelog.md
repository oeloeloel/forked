Current Version:

Version 0.0.3

* Multiline actions/conditions allow optional code fence:
::
```rb
    # this code is highlighted in the editor
    # and the code fence (```) is not displayed by Forked
    this(code).is("highlighted").in(:the) == EDITOR
```
::
* Backslash (hard wrap symbol, equivalent to <br>) on an empty line prevents it from collapsing
* It is now possible to specify the spacing between paragraphs as well as the spacing between paragraphs and other elements
* History tracks movement through chunks so you can know where the player came from or how many times they have visited a chunk
* `history` command gets the history array. Navigate backwards through history with `history[-2]`
* Get the text of the current heading with `heading` command
* Set the text of the current heading with `heading_set` command
* Fixed issue with blockquotes retaining the `>` delimiter if not first character in line.
* Jump method now accepts either a chunk ID or a relative index number. `Jump(3)` will navigate to the third chunk below the current chunk in the story file.
* Added `fall` method that falls through story chunk immediately below the current chunk in the story file. You can use fall to drop to the next chunk regardless of its ID (it doesn't need to have one)
  ```md
    [continue...](: fall :)
  ```
* Added `fall` shortcut using `#`. Example:
  ```md
    [Next ->](#)
  ```
* Added `rise` method that behaves like `fall` but navigates to the story chunk immediately above the current chunk in the story file.
** Added author mode to enable features to aid story authoring. Hold F and press U to toggle author mode. Author mode currently allows you to `fall` by pressing the `n` key and `rise` using the `h` key.
* "Author Mode" added toggle on and off by holding `f` and pressung `u`. A red square appears in the top right of the screen to inform you that author mode is activated. In author mode:
  * Press `n` to jump to the chunk that follows the current chunk in the story file (shortcut key is temporary).
  * Press `h` to jump to the chunk that precedes the churrent chunk in the story file (shortcut key is temporary).
  * Hold `q` do display information about the current story.
* Refactored conditions and paragraphs for better lazy continuation and correct spacing.
* Parser: All open elements (e.g. paragraph, blockquote, etc.) are now closed when when the parser meets a new chunk heading.

Older versions:

Version 0.0.2
* Added new syntax (colons) for action blocks, conditions and trigger actions. Mirrors existing syntax (hashes and ticks) which will continue working for the time being but will eventually be removed.
* Added single line chunk actions
* Added single line trigger actions
* Added single line conditions (interpolation & conditional text)
* Changed preformatted marker to @@ because $$ breaks formatting in VSC
* Updated Manual to include new syntax
* Updated countdown timer example
* Added command "timer_seconds", returns time remaining in seconds (stops at zero)
* Updated readme file for new syntax, etc.
* Formatting changes to the story of the three peas
* Updated threshold story for syntax changes

Version 0.0.1
* Fixed bug: Changing the size_enum caused interpolated text to appear in the wrong x location and line lengths were miscalculated.
* Fixed bug: When displaying the story title in place of a missing heading, the prefix # was displayed.
* Fixed bug: Comment markers at line character zero were ignored if the line contained extra comment markers later on.
* Reenabled feature "preserved line" (effectivle pre-formatted) allows a line to skip formatting and be presented as-is. Marker: line starts with `$$`.
* Clean-up in parse.rb to use methods to create hashes so they can be consistently applied from anywhere.
* Fixed bug: If there are two interpolated texts, they will now be displayed as two paragraphs if there is a blank line between them.
* Fixed bug (possibly): trigger action code starting with `#` tries to navigate instead of executing code. This is fixed with a kludge so Forked can tell the difference at runtime. It seems to work.

Previous versions:

Version 0.0.0
* Initial version