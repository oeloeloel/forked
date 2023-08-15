# Forked
Forked is a prototype system for scripting interactive narratives in DragonRuby.

Forked uses a simplified markup similar to markdown. It is intended to be simple to use, easy to learn for people without programming experience and to make it easier to focus on writing.

Additional functionality can be added by writing commands in Ruby.

What it lets you do:
* Write stories in a readable format with minimal distraction
* Player navigates to different parts of your story with button clicks
* Issue commands from within your story
* Premade commands available for non-programmers
* Custom commands are simple to create using Ruby
* Conditions allow allow you to control what the player sees
* Show or hide text based on conditions
* Show or hide buttons based on conditions
* Buttons can link to other parts of the story or run code

## Getting started
Download or clone the project and run it in DragonRuby.

The default project is the user manual.

## Quick Reference

#### Story title:
```
# Title
```

#### Chunk heading and ID:
```
## Heading Name {#chunk_id}`
```

#### Trigger and target:
```
[Trigger text](#target_id)
```

#### Blockquote:
```
> This text is displayed as a blockquote.
```

#### Code Block:
```
~~~
# This text is displayed as code, in a monospace font with lines wrapped for length but otherwise without any changes.
~~~
```

#### Horizontal Rule:
```
---
```

#### Chunk action:
```
::
action
::
```

#### Trigger action:
```
[Trigger text](:
action
:)
```

#### Conditional text (string interpolation):
```
<:
condition
:>
```

#### Conditional text (show/hide text):
```
<:
condition
::
This text is displayed if the condition is true.
:>
```

#### Comment:
```
// this line is a comment
```

## Formatting
#### Blockquotes:
```
> This text is inside a blockquote
> This text is inside the same blockquote
```

#### Code Blocks (not executable):
````
~~~
This text looks like code
~~~
````

#### Preformat
```
@@ any formatting in this line is ignored
```

## Available Actions
|Bag: Inventory Management| (experimental) |
|-|-|
|`bag_add item` | adds an item to the player's inventory |
|`bag_remove item` | removes an item from the player's inventory |
|`bag_has? item` | `true` if the item is in the player's inventory or `false` if not |
|`bag_clear` | clear all items from the inventory |

|Memo: Storing Information| (experimental) |
|--|--
|`memo_add "memo name", "memo value"`| Creates a new memo using the supplied name and storing the supplied value |
|`memo_remove "memo name"` | Deletes the named memo |
|`memo_clear`| Deletes all memos |
|`memo_check "memo name"`| Returns the value of the named memo |

|Wallet: Financial Management| (experimental) |
|-|-|
|`wallet`| Returns the amount of coins, dollars, schekels, etc. in the player's wallet |
|`wallet_plus 10` | Adds 10 to the player's wallet |
|`wallet_minus 5` | Removes 5 from the player's wallet |
|`wallet_clear`| Discards all the player's money |

|Timer: Time Management| (experimental) |
|-|-|
|`timer_add "timer name", 10.seconds`| Creates a new timer with the provided name and the provided duration. The duration can be given in `ticks` (1/60 seconds) or in seconds as shown here.  |
|`timer_remove "timer name"` | Deletes the timer with the provided name |
|`timer_check "timer name"`| Returns the time remaining for the named timer (will keep counting down after reaching zero) |
|`timer_seconds "timer name"`| Returns the time remaining for the named timer in seconds (will stop counting down at zero) |
|`timer_done? "timer name"` | Returns true if the timer is complete |

| Counter: Number Tracking         | (experimental)                                                                                   |
|-|-|
| `counter_add "counter name", 5` | Creates a new counter with the provided name and the (optional) provided duration                |
| `counter_remove "counter name"`  | Deletes the named counter                                                                        |
| `counter_up "counter name", 1`   | Increases the value of the named counter by the provided value (or by 1 if no value is provided) |
| `counter_down "counter name", 1` | Decreases the value of the named counter by the provided value (or by 1 if no value is provided) |
| `counter_check "counter name"`   | Returns the value of the named counter                                                           |
| `counter_clear`                  | Deletes all stored counters                                                                      |

|Background Image|(experimental)|
|-|-|
|`background_image "sprites/bg_image.png"` | Sets the story background to the provided image. It is recommended to put images in `mygame/sprites`. This action should only be used with `conditional blocks` (see manual).|

| Roll Dice | (experimental) |
|-|-|
| `roll "2d6"` | Returns the result of a dice roll with two, six sided dice. Any other numbers may be substitutes: The first number represents the number of dice. The second number represents the number of sides for all rolled dice. |

| Headings | (experimental) |
|-|-|
| `heading` | Gets the text of the current heading |
| `heading_set` | Sets the text of the current heading |

| Navigation | (experimental) |
|-|-|
| `jump "#chunk_id"` | navigates to the chunk specified by `#chunk_id` |
| `history[-1]` | Gets the chunk_id for the current chunk |
| `history[-2]` | Gets the chunk_id for the last visited chunk |