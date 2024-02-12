# Forked
Forked is a system for scripting interactive narratives in DragonRuby. The project is in development but complete enough to make fully functional text games, for example [My Death Story](https://akzidenz.itch.io/my-death-story).

Forked uses a simplified markup similar to markdown. It is intended to be simple to use, easy to learn for people without programming experience and to make it easier to focus on writing.

Additional functionality can be added by writing commands in Ruby.

What it lets you do:
* Write stories in a readable format with minimal distraction
* Player navigates to different parts of your story with button clicks
* Issue commands from within your story
  * Premade commands available for non-programmers
  * Custom commands are simple to create using Ruby
* Conditions allow you to control what the player sees
  * Show or hide text based on conditions
  * Show or hide buttons based on conditions
* Buttons can link to other parts of the story or run code
* Track the player's progress through the story
* Automatically save the player's progress so they can continue playing where they left off

## Getting started
To begin:
1. Dowload the latest version of DragonRuby, if necessary. For help with DragonRuby visit the [Discord server](http://discord.dragonruby.org).
2. Unzip a fresh copy of DragonRuby. 
3. Download Forked and unzip it (go [here](https://github.com/oeloeloel/forked/tree/main), click the green **Code** button and select **Download Zip**).
4. Drag the **contents** of the `forked` folder to DragonRuby's `mygame` folder, letting it overwrite the existing folders.
5. Run DragonRuby. 

By default, the user manual will load up and be displayed. The user manual itself was created with Forked and you can [look at the code](https://github.com/oeloeloel/forked/blob/main/app/story.md?plain=1) to see how it was made.

When you're ready to make your own story:
1. Create a new blank text file in the `mygame/app` folder. 
2. Name the file however you like but it is recommended to end the filename with `.md`, for example, `my-life-story.md`.
3. Edit the file `mygame/app/tick.rb`. Change the line at the top of the file from...
```rb
STORY_FILE = 'app/story.md'
```
to the file you just created. Note that the file path should begin with `app` and not `mygame`.
```rb
STORY_FILE = 'app/my-life-story.md'
```

Now you can start writing your story in the `my-life-story.md` file. See the [manual](https://github.com/oeloeloel/forked/blob/main/app/story.md?plain=1) for more information.

## Quick Reference

### Story title:
You must provide a title for your story and it should be the first line in the story file.
```
# Title
```

### Chunk heading and ID:
Forked displays the heading text for the current chunk.
The Chunk ID allows Forked to identify each chunk of the story and should be unique.
```
## Heading Name {#chunk_id}`
```

### Trigger and target:
By default, a trigger is displayed as a button.
The first part of the trigger, between `[ ]` is the visible text of the button.
The second part of the trigger, between `( )`, is the action to perform. See the examples below.

Navigate to a chunk by its Chunk ID
```
[Trigger text](#target_id)
```

Navigate to the following chunk in the story file:
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
| `jump 3` | navigates chunks in the story file relative to the current chunk (e.g. 3 chunks below the current chunk). Negative numbers will navigate to previous chunks in the story file.
| `history[-1]` | Gets the chunk_id for the most recently visited chunk (the current chunk) |
| `history[-2]` | Gets the chunk_id for the last visited chunk |

## Author Mode
Author mode provides some features that may be useful while writing your story. Note that the shortcut keys may change in the future.

| Shortcuts | Action |
|-|-|
| Hold `f` and press `u` | Toggle Author Mode on or off. When author mode is active, a red square appears in the bottom left corner of the screen. The following shortcuts become available when Author Mode is on. |
| `q` | Display information sidebar. This displays 1) the current chunk ID and the text of the current chunk heading 2) the most recent 20 items in the player's navigation history |
| `n` | Navigate to the following chunk in the story file until the last chunk is displayed. |
| `h` | Navigate to the preceding chunk in the story file until the first chunk is displayed. |
