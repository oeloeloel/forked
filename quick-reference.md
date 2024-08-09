## Quick Reference

### Story title:
You must provide a title for your story and it should be the first line in the story file.
```
# Title
```

### Chunk heading (and optional Chunk ID)
Forked displays the heading text for the current chunk. Headings begin with `##` (2 hash/pound symbols).

```md
## Heading Name
```
Forked allows you to link from one chunk to another using the heading name (see [Trigger and Target](#trigger-and-target)). Optionally, you can add a Chunk ID to the heading line. The Chunk ID must be unique and it will help you to ensure that you do not have duplicated heading lines.

```md
## Heading Name {#chunk_id}`
```

### Trigger and target:
By default, a trigger is displayed as a button.
The first part of the trigger, between `[ ]` is the visible text of the button.
The second part of the trigger, between `( )`, is the action to perform. To navigate to another chunk of the story, add the chunk header here. The chunk header must be rewritten to contain only lower-case letters (`a`-`z`), numbers (`0`-`9`), hyphens (`-`) or underscores (`_`). Spaces must be replaced with hyphens. If you are using a code editor that understands markdown (such as Visual Studio Code), it may autocomplete links for you.

```md
<!-- the following examples will show navigation to a chunk named "Target Header" -->
## Target Header

<!-- Navigate to "Target Header" -->
[Trigger text](#target-header)
```

This trigger will navigate to the following chunk in the story file:
```
[Trigger text](#)
```

Display an inactive trigger:
```
[Trigger text]()
```

See also [Trigger Action](#trigger-action)

### Horizontal Rule:
By default, this displays a horizontal line in the display, to use as a divider between sections of content within a chunk.
```
---
```

### Chunk action:
Chunk actions are blocks of DragonRuby Ruby code, which run one time, when the chunk is navigated to.
```
::
action
::
```

### Trigger action:
Trigger actions are blocks of DragonRuby Ruby code, which run whenever the trigger (button) is activated.
```
[Trigger text](:
action
:)
```

### Conditional text (string interpolation):
Conditional blocks contain code that runs every tick (60 times per second).
If the condition code returns a string (text), it will be inserted into the display.
```
<:
condition
:>
```

### Conditional text (show/hide text):
If the condition code returns true (a boolean value), the text following the `::` symbols is displayed. If the code returns false, the text is hidden.
```
<:
condition
::
This text is displayed if the condition is true.
:>
```

### Conditional text (with alternative text)
If the condition code returns true (a boolean value), the text following the *first* `::` symbols is displayed. If the code returns false, the text following the *second* `::` symbols is displayed.
```
<:
bag.has? "cinnamon"
::
I reluctantly offered the precious spice to the pastry chef.
::
Alas, I had no cinnamon! Now, only a miracle could save me from certain death. 
:>
```


### Comment:
Comments are not displayed and can be useful for leaving notes for yourself of other people.

There are two kinds of comments available. C-style line comments, which are easier to type:
```
// this line is a comment
a = 1 // this is an inline comment
```
And HTML-style comments which have greater compatibility with markdown editors:
```
<!-- This is an html-style comment
which can span multiple lines -->
```

## Formatting

*Italic text*
```md
*italic text*
```

**Bold text**
```md
**bold text**
```

***Bold Italic text***
```md
***bold italic text***
```

`code span`
```md
`code span`
```

### Blockquote:
By default, blockquotes display text inside a box.
Blockquotes can run over more than one line. To separate blockquotes, include a blank line between them.
```
> This text is displayed as a blockquote.

> This text is inside a second blockquote
> This text is inside the same blockquote
```

### Code Block:
By default, code blocks display text inside a box, in a monospace font. The text is displayed *as-is*, without any changes except for wrapping long lines. Code in code blocks is not executable.
```
~~~
# This text is displayed as code
~~~
```

### Preformat
Preformatted text ignores any formatting or markup within the text.
```
@@ any formatting in this line is ignored
```

### Hard Wrap
Add a backslash `\` at the end of a line to display the following line in the file to display as a new line in Forked (instead of continuing the same line).
```
This is the first line\
This is the second line
```

### Images
Add images to your story. It is necessary to specify the width (`w`) and height (`h`) that you want to display the image, otherwise it will be displayed at 80x80.
```
![](sprites/image.png {w: 80, h: 80})
```

## Available Action Commands
Forked provides built-in commands to use in chunk actions, trigger actions or conditions.
The commands are experimental and may change in the future.

The Bag is a handy place to store stuff your player might be carrying with them. You can add and remove items, check if an item exists or empty it out.
|Bag: Inventory Management| (experimental) |
|-|-|
|`bag_add item` | adds an item to the player's inventory |
|`bag_remove item` | removes an item from the player's inventory |
|`bag_has? item` | `true` if the item is in the player's inventory or `false` if not |
|`bag_sentence` | returns a string containing all the items in the player's bag |
|`bag_clear` | clear all items from the inventory |

Memo is for storing useful textual information, such as your player's name or what pronouns they use to describe themself. You can use it to store any information you want check or reuse later in your story.
|Memo: Storing Information| (experimental) |
|--|--
|`memo_add "memo name", "memo value"`| Creates a new memo using the supplied name and storing the supplied value |
|`memo_remove "memo name"` | Deletes the named memo |
|`memo_clear`| Deletes all memos |
|`memo_check "memo name"`| Returns the value of the named memo |

Wallet can be used to store numbers. This could be useful to keep track of how much gold or player has. You can add or subtract from the wallet, check how full it is, or clean it out entirely.
|Wallet: Financial Management| (experimental) |
|-|-|
|`wallet`| Returns the amount of coins, dollars, schekels, etc. in the player's wallet |
|`wallet_plus 10` | Adds 10 to the player's wallet |
|`wallet_minus 5` | Removes 5 from the player's wallet |
|`wallet_text '$'`| Returns the amount in the wallet as text, with an optional currency symbol prefix |
|`wallet_clear`| Discards all the player's money |

Timer can be used to time events in the game. This could be useful if the player has to make a quick decision, before the air in their space-suit runs out. You can can create and delete timers, check if they're done or see how much time is remaining, in ticks or in seconds.
|Timer: Time Management| (experimental) |
|-|-|
|`timer_add "timer name", 10.seconds`| Creates a new timer with the provided name and the provided duration. The duration can be given in `ticks` (1/60 seconds) or in seconds as shown here.  |
|`timer_remove "timer name"` | Deletes the timer with the provided name |
|`timer_check "timer name"`| Returns the time remaining for the named timer (will keep counting down after reaching zero) |
|`timer_seconds "timer name"`| Returns the time remaining for the named timer in seconds (will stop counting down at zero) |
|`timer_done? "timer name"` | Returns true if the timer is complete |

Counter can be used to keep track of any numerical information. You can use it to keep the player's score, or count how many times they tried to do something. This is similar to `wallet`, except that you can create any number of counters. You can create, delete, add to, or subtract from counters, and you can clear every counter in the game, if you need to. 
| Counter: Number Tracking         | (experimental)                                                                                   |
|-|-|
| `counter_add "counter name", 5` | Creates a new counter with the provided name and the (optional) provided duration                |
| `counter_remove "counter name"`  | Deletes the named counter                                                                        |
| `counter_up "counter name", 1`   | Increases the value of the named counter by the provided value (or by 1 if no value is provided) |
| `counter_down "counter name", 1` | Decreases the value of the named counter by the provided value (or by 1 if no value is provided) |
| `counter_check "counter name"`   | Returns the value of the named counter                                                           |
| `counter_clear`                  | Deletes all stored counters                                                                      |

Sets a background image behind the story display.
|Background Image|(experimental)|
|-|-|
|`background_image "sprites/bg_image.png"` | Sets the story background to the provided image. It is recommended to put images in `mygame/sprites`. This action should only be used with `conditional blocks` (see manual).|

Lucky?
| Roll Dice | (experimental) |
|-|-|
| `roll "2d6"` | Returns the result of a dice roll with two, six sided dice. Any other numbers may be substituted. The first number represents the number of dice. The second number represents the number of sides for all rolled dice. |

Check and set the currently displayed heading if, for whatever reason, it doesn't suit you.
| Headings | (experimental) |
|-|-|
| `heading` | Gets the text of the current heading |
| `heading_set` | Sets the text of the current heading |

Navigate around your story in code.
| Navigation | (experimental) |
|-|-|
| `jump "#chunk_id"` | navigates to the chunk specified by `#chunk_id` |
| `jump 3` | navigates chunks in the story file relative to the current chunk (e.g. 3 chunks below the current chunk). Negative numbers will navigate to previous chunks in the story file. |
| `jump_to 3` | navigates to the third chunk in the story file
| `jump_to -1` | navigates to the last chunk in the story file
| `history[-1]` | Gets the chunk_id for the most recently visited chunk (the current chunk) |
| `history[-2]` | Gets the chunk_id for the last visited chunk |

## Save Game Data
Forked automatically saves progress but, if you prefer, you can manually control game saves. [See README.md for instructions to disable autosaving](README.md). Note that game data is automatically loaded when Forked starts, if saved data exists.

| Save Game Data | (experimental) |
|-|-|
| `save_game` | saves game progress, including navigation history, bag items, timers, counters and memos. Saved data is automatically loaded when Forked starts up. |
| `clear_save_data` | deletes saved game progress if autosaving is disabled |
| `autosave_off` | disables autosaving |
| `autosave_on` | enables autosaving |

| Misc Commands ||
|-|-|
| `load_story path_to_story_file` | Loads and navigates to a different story. Player progress (history of visited chunks) will be unloaded but other data such as memos, bag, counters, etc, will persist in the newly loaded story. If the story being loaded has a save file, the history will be loaded and the story will continue from the save point. |
| `change_theme DARK_MODE` | Changes the theme. The current built-in themes are `DARK_MODE` (selected), `LIGHT_MODE`, `KIFASS_THEME` and `TWENTY_SECOND_THEME`.|

## Author Mode
Author mode provides some features that may be useful while writing your story. Note that the shortcut keys may change in the future.

| Shortcuts | Action |
|-|-|
| <nobr>`f` (hold) + `u`</nobr> | Toggle Author Mode on or off. When author mode is active, a red square appears in the bottom left corner of the screen. The following shortcuts become available when Author Mode is on. |
| `q` (hold) | Display information sidebar. This displays information such as the navigation history and the contents of the player's bag |
| `n` | Navigate to the following chunk in the story file until the last chunk is displayed. |
| `h` | Navigate to the preceding chunk in the story file until the first chunk is displayed. |
| `d` (hold) | Display the current framerate (fps) |
