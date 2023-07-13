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
|Inventory Management| (experimental) |
|-|-|
|`bag_add item` | adds an item to the player's inventory |
|`bag_del item` | removes an item from the player's inventory |
|`bag_has? item` | `true` if the item is in the player's inventory or `false` if not |
|`bag_clear` | clear all items from the inventory |