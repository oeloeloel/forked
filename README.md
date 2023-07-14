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

Story title:
```
# Title
```

Chunk heading and ID:
```
## Heading Name {#chunk_id}`
```

Trigger and target:
```
[Trigger text](#target_id)
```

Chunk action:
```
^^^
action
^^^
```

Trigger action:
```
[Trigger text](^^^
action
^^^)
```

Conditional text (string interpolation):
```
<^^^
condition
^^^>
```

Conditional text (show/hide text) [note: to be improved]:
```
<^^^
condition ? "text displayed if true" : "text displayed if false"
^^^>
```

Comment:
```
// this line is a comment
```

## Formatting
Blockquotes:
```
> This text is inside a blockquote
> This text is inside the same blockquote
```

Code Blocks (not executable):
````
```
This text looks like code
```
````

## Available Actions
|Bag: Inventory Management| (experimental) |
|-|-|
|`bag_add item` | adds an item to the player's inventory |
|`bag_del item` | removes an item from the player's inventory |
|`bag_has? item` | `true` if the item is in the player's inventory or `false` if not |
|`bag_clear` | clear all items from the inventory |

|Memo: Storing Information| (experimental) |
|--|--
|`memo_add "memo name", "memo value"`| Creates a new memo using the supplied name and storing the supplied value |
|`memo_del "memo name"`| Deletes the named memo |
|`memo_exists? "memo name"`| Returns true if the named memo exists |
|`memo_clear "memo name"`| Deletes all memos |
|`memo_check "memo name"`| Returns the value of the named memo |

|Wallet: Financial Management| (experimental) |
|-|-|
|`wallet`| Returns the amount of coins, dollars, schekels, etc. in the player's wallet |
|`wallet_plus 10` | Adds 10 to the player's wallet |
|`wallet_minus 5` | Removes 5 from the player's wallet |
|`wallet_clear`| Discards all the player's money |

|Timer: Time Management| (experimental) |
|-|-|
|`timer_add "timer name", 10.seconds`| Creates a new timer with the provided name and the provided duration. The duration can be given in `ticks` (1/60 seconds) or in seconds as shown here.|
|`timer_del "timer name"`| Deletes the timer with the provided name |
|`timer_check "timer name"`| Returns the time remaining for the named timer|
|`timer_done "timer name"` | Returns true if the timer is complete |

|Background Image|(experimental)|
|-|-|
|`background_image "sprites/bg_image.png"` | Sets the story background to the provided image. It is recommended to put images in `mygame/sprites`. This action should only be used with `conditional blocks` (see manual).|
