
### Version 0.0.9
* Conditional content allows alternative content to be displayed if the result of the condition is false. E.g.:
  ```
  <!-- checks to see if the player has an item in their bag (inventory) -->
  <:
    bag_has? "pocket calculator"
  ::
    <!-- displayed if the item is in the player's bag -->
    You quickly solve the problem. The square root of 169 is 13!
  ::
    <!-- displayed if the item is not in the player's bag -->
    If only you had a pocket calculator!
  :>
  ```
* Added `load_story` command to load and switch to a different story from within the current story. See example of switching stories from a button click below. When the new story loads, data such as inventory, counters, memos, etc will be unloaded. If the new story has saved progress, it will be loaded.
```
[Read Memoirs of a Crocodile](: load_story 'app/memoirs-of-a-crocodile.md' :)
```
* When a story is loaded, the game title bar displays the name of the current story
* Author Mode changes: (hold `f` + press `u` to enter author mode. Hold `q` to display the sidebar)
  * Added list of author mode shortcuts to author mode sidebar
  * Added shortcut to display FPS (debug label): `d` (for diagnostic)
  * Added lists of `memos`, `counters`, `timers`, and `wallet` contents to sidebar
* Theme can be set from inside the story file, immediately after the story is loaded *regardless* of whether the game is continued from a save file. Use the `change_theme` command after the story title and before the first chunk.
```
# The Title of My Story
:: change_theme(KIFASS_THEME) ::

## This is the first chunk
```
* Navigating through chunks using Author Mode shortcuts now autosaves progress (if autosave is enabled)
* Examples: Added `memo`, `counter`, `wallet` examples to manuals
* Bugfix: Empty string interpolation no longer causes exception


## Current Version

### Version 0.0.8
* **Added Inline Styles**: Text can be marked up to appear as bold, italic, bold-italic or code styles using simple markdown. Styled text is surrounded by a matching pair of symbols:
  * *Italic text*: marked by a pair of single `*asterisks*` or `_underscores_`
  * **Bold text**: marked by a pair of double `**asterisks**` or `__underscores__`
  * ***Bold-italic text***: marked by a pair of triple `***asterisks***` or `___underscores___`
  * `Code`: marked by a pair of single `backticks`
* Fixed issue with spacing between buttons when buttons are separated by a blank line
* Fixed issuew with spacing between buttons when buttons are separated by hidden content


### Version 0.0.7

* **Added GitHub Flavor Markdown links**. It is now possible to link to headers as seen below. This makes buttons easier to create and improves compatibility with markdown editors, such as Visual Studio Code.

```md
<!-- header -->
## Target Header

<!-- button -->
[Go to Target Header](#target-header)
```
* **Added new autosave commands** that can be called from inside a story file: `autosave_off` and `autosave_on` control whether player variables will be automatically saved. By default autosave is enabled and runs whenever the player activates a button. Autosave commands can be called when a story chunk loads:
```
## Forgetting
:: autosave_off ::
```
Or when a button is activated:
```
## Remembering
[Start remembering](: autosave_on :)
```
* **Added ability to run actions whenever the game is loaded**. These block actions will run one time, when the game is reloaded or reset. This may be useful for changing autosave settings on a per-story basis. To do this, add a block action after the game title and before the first chunk heading. Example:
```
# Memoirs of an Amnesiac
:: autosave_off ::

## Chapter One
```
* **Load a story file from the command line** when launching DragonRuby. Example:
`./dragonruby —story app/my-story.md`\
Story files passed in this way will override the STORY_FILE specified in the code.\
Note that: DragonRuby recommends that passing command line arguments to the DragonRuby binary should be used for development/debugging purposes only.
* **Changed file structure**: In the Forked repo, the `forked` folder has moved from `app/forked` to `lib/forked`. Requires have been changed to use `require_relative` so the developer can require `forked` with a single line and move the `forked` folder wherever they like. 
* **Added bag to author mode sidebar**: The author mode sidebar (to access, press `f+u` and then hold `q`) now shows the contents of the player's bag (inventory)
* Documentation improvement: the manual has been updated and an expanded, non-interactive version is included with Forked (manual.md)
* Bugfix: Using the mouse to navigate to a chunk without any triggers would cause the mouse cursor to stay as finger instead of reverting to arrow


### Version 0.0.6

* Added save feature. Author can save the player's navigation history, inventory, etc. from within the story file using the `save_game` command:
To save the game when a chunk is loaded:
```
:: save_game ::
```

To save the game when a button is clicked:
```
[Save your progress before entering the boss battle](: save_game :)
```

Saved game data will be automatically loaded when the story starts up. The game will continue from the chunk that was on display when the game was saved.

Save data can be cleared from within the story file using the `clear_save_data` command. This empties the save file (note that this may not be meaningful if autosaves are enabled - see below)
```
:: clear_save_data ::
```
* Added automatic saves. Whenever the player clicks a button, the game automatically saves the game. Autosaving can be disabled by changing `autosave: false` in `defaults.rb`.
* Added html-style comments for greater ease of use in markdown editors
* Added command `timer_exist` to check to see if a timer has been created
* Added command `bag_sentence` which returns a string listing the player's inventory items.
* Added exception: when using the `jump()` command without a parameter, Forked raises an exception with a message.
* Fixed: No longer attempts to display string interpolation if the condition evaluates to an empty string
* Clean-up of functionality in `tick.rb` and comments added to make it easier to follow the deployment. Loading story file on second tick when running on the web for performance improvement.
* Added `Example: Inventory` to the manual to demonstrate simple inventory management with the `bag` commands.
* Updated `Example: Countdown` to better illustrate the timer functionality
* Updated story example `A Story As You Like it by Raymond Queneau` and published on itch.io https://akzidenz.itch.io/peas
* Updated story example `The Threshold`, added comments to the story file and published on itch.io https://akzidenz.itch.io/the-threshold

Version 0.0.5

* Added customizable keyboard navigation to display. Defaults: cycle forwards through buttons with right arrow or down arrow, cycle backwards with left or up arrows activate buttons with space or enter. Keyboard defaults can be modified in `app/forked/input.rb`
* Added customizable controller navigation to display. Defaults: cycle forwards through buttons with left or down dpad or left thumbstick, cycle backwards with up or left dpad or thumbstick, activate buttons with a, b, r1 or r2. Controller defaults can be modified in `app/forked/input.rb`
* Added display of player navigation history in the Author Mode Information Sidebar (shortcut: `f+u`, hold `q`). Limited to the 20 most recently visited chunks. (You can print the entire history to the console by entering `$story.history_get`)
* Display code has been changed to improve performance. The display is only recalculated if the content has changed.
* The default story file (the manual) has a number of spelling corrections.
* Exceptions: Exception message identifies incorrect chunk_id when navigation fails
* The `fall` and `rise` commands have been deprecated. Use `jump(1)` and `jump(-1)` instead.
* Added Background Image example to manual showing how to set a background image for the current story chunk.
* Added Roll Dice example to manual showing how to generate random dice rolls.

** Experimental features:**
* Added spellcheck export: Devmode support. Exports text file with code and chunk ids removed. Line numbers are added to make corrections easier. Type `Forked.export_spell_check` in the console to export a file `spellcheck.txt` in the project folder.
* Added json story export feature (experimental). Exports the currently loaded story to a json file in the DragonRuby folder. Json functionality is provided by [dragonjson](https://github.com/leviongit/dragonjson/blob/master/json.rb).
To use, load a story file into forked, then enter in the console: `Forked.export_story_as_json`
* Added manual json story import feature (experimental). Loads an exported json story file. Note that exported files are placed in the DragonRuby folder and need to be moved to the game folder to be imported. `Forked.import_story_from_json`
* Added automatic json story import (experimental). If you provide a valid json file as your STORY_FILE, forked will import it. Only filenames ending in `.json` are imported as json. Forked will attempt to import any other files as markdown type files.
* Added link validation (experimental). Checks all actions in the current story and verifies that the target chunk exists. Results are printed to the console. To run link validation, enter `validate_links` in the console. By default, only invalid links will be reported. To report on all links, enter `validate_links(true)`.

Version 0.0.4

* Fixed display issue that caused elements to display with incorrect y location
* Fixed parsing issue in conditional blocks if two paragraph texts are separated by a block level element without any line breaks between them.
* Updated font paths to be all lower-case

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

Version 0.0.0
* Initial version