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

## Starting a new story
Create your own story file in the `app` folder. Story files are plain text files. The file can be named anything you like.

Open the file `app/main.rb`.
Near the top of the file, change the following line to match the name of your story file.
```STORY_FILE = 'app/death-story.md'```

Write your story.

## Story writing
### The title
Every story needs a title. Add one at the top your file like this:
```md
# My Life Story
```
The title is identified by the single `#` at the _start_ of the line.

### Chunks
Forked stories are broken up into `chunks`. You can think of a chunk as a 'scene' or a 'chapter' of your story.
The first chunk in your file is important. This is where your story will start. Chunks begin with a heading and they end when you define a new heading or end of the file is reached.

### Headings and ids.
Every chunk must have a heading line:
```
# My Life Story

## The Start of It All {#the_beginning}
```
The heading line is indicated by the `##` symbols at the _start_ of the line, followed by the text to be displayed.

The heading line must include an `id`. The id is wrapped with curly braces `{}` and must begin with a `#` symbol as shown above.

The id is used to link to this chunk when the player navigates around your story.

Headings do not have to include display text. In the following example, the display text is omitted and Forked will display the story Title instead.
```
## {#the_beginning}
```
### Text
Now you can start writing your story:
```
# My Life Story

## The Start of It All {#the_beginning}

My story begins on the day of my birth. I do not have much recollection of that day but I have learned many of the events of that time from the accounts of others and through painstaking research.

My mother was of no help in this endeavour. Being a crocodile, typical of the West African species, she was not capable or relating her memories of that day. My father, as is typical of the males of our species, was not in attendance and, to this day, I have not laid eyes upon him. This is almost certainly not a considerable loss.
```
Paragraphs are separated by new lines. Blank lines are ignored so you don't need to leave a blank line between paragraphs but it makes the file easier to read.

### Triggers and Targets
Triggers allow the player to navigate around the story. In the display, they take the form of buttons. Triggers are wrapped in square brackets `[]`. 

Targets specify what happens when the trigger is pulled. They are wrapped in round brackets `()`.

The trigger and its target must be next to each other, without a space in-between, like this: `[trigger](target)`.
```
[Learn how I travelled to Europe](#europe)
```
This will display a rectangular button bearing the label "How I travelled to Europe in a submarine". When clicked, the player will be taken to the chunk with the id `#europe`.

Tip: If you want a button to be displayed but not clickable, you can disable it by leaving the target empty.

# Actions
Actions _make things happen_. Aside from navigating around your story, you may want to store and retrieve information. You may want the user to pick-up objects and put them in an inventory to use later. You may want to keep track of any gold they acquire along the way.

Chunk actions are surrounded by angle brackets and round brackets `<(chunk_action)>`. They are executed one time, at the moment when the chunk is displayed.
```
## Travelling to Europe by Submarine {#europe}
<(inventory_add submarine)>
Having received a submarine in payment for my services to the mutineers, I loaded it with food, water and a cargo of aromatic spices. Immediately, I set out for Europe in the hopes that I might find the Dauphine once again.
```
`Chunk actions` are surrounded by angle brackets and round brackets `<(chunk_action)>`. They are executed one time, at the moment when the chunk is displayed.

In the example above, when the chunk is displayed a submarine will be added to the user's inventory. There are actions available to remove items from the inventory `<(inventory_remove item)>` or check to see if an item is in the inventory `<(inventory_has? item)>`.

`Target actions` can be used as targets in a trigger/target pair. Instead of navigating to another chunk, the action will run when the trigger button is clicked.
```
[Give exotic spice to the pastry chef](inventory_remove cinnamon)
```
There will be more information about available actions later on.

### Conditions
Conditions allow you to decide whether to show or hide text or triggers. They are similar to chunk actions:
```
## Dangerous Waters {#shipwreck}
I confess that, being an exceptionally strong swimmer, the thought of being cast adrift did not terrify me as much as it did the the crew. However, I am not without feeling and did not want to see them all drowned.

<(inventory_has? dinghy) Having prepared for such an eventuality, I hauled my inflatable dinghy up on deck. Leaving the submariners taking turns to fill it with air, I leaped from the boat in pursuit of my quarry.>
```
Conditions are wrapped in angle brackets and round brackets `<()>`. If the condition is true, whatever else is inside the angle brackets `<>` will be displayed. In the example above, the second paragraph will only be displayed if they have the inflatable dinghy in their inventory.

To show what happens when the player _does not_ have a dinghy, we can negate the condition by putting an exclamation mark `!` in front of it. This turns true into false and false into true. Note the `!` in the following example:
```
<(!inventory_has? dinghy) Alas, death must come to us all, and so it was for those submariners as the vessel slipped back beneath the inky waves.

I grieved at the loss but I would be able to purchase more spices upon reaching the shores of Madagascar.>
```

The previous examples show how text can be displayed conditionally but we can do the same thing with conditions.

```
<(inventory_has? pistol) I touched the barrel of my dueling pistol to the tip of the archduke's nose.

[Pull the trigger](#wanted_for_murder)>

<(!inventory_has? pistol) Finding myself without a firearm for the first time since my sixth birthday, I had little choice but to raise my short, muscular arms above my head.

[Submit to the Archduke's men](#captivity)>
```

## Quick Reference
|||
|-------------|---------|
| Story title | `# Title` |
| Chunk heading and ID | `## Heading Name {#chunk_id}` |
| Trigger and target | `[Trigger text](#target_id)` |
| Chunk action | `<(action)>` |
| Trigger action | `[Trigger text](action)` |
| Condition | `<(condition) conditional text or trigger/target>` |
| Comment | `// this line is a comment` |

## Available Actions
|Inventory Management| (experimental) |
|-|-|
|`inventory_add item` | adds an item to the player's inventory |
|`inventory_remove item` | removes an item from the player's inventory |
|`inventory_has? item` | `true` if the item is in the player's inventory or `false` if not |

|Coin counting | (in progress) |
|-|-|
|`money_add amount`| adds `amount` to the player's money. `amount` must be a number
|`money_remove amount`| removes `amount` from the player's money. `amount` must be a number|
|`money_amount`| gives the total amount of money in the player's posession|

## Custom Actions
If you have experience with programming, you can write your own actions and conditions in DragonRuby and use them in your story. The following example shows a method written in Ruby and used in a condition.
```rb
# Ruby code written in main.rb
def lucky?
  random_number = rand # a random number between 0.0 and 1.0
  if random_number < 0.5 # it will be less than 0.5 about half of the time
    return true # yes, lucky
  else
    return false # no, unlucky
  end
end
```
```
## The Tossed Coin {#coin}
Never one to shy away from a challenge, I flipped the coin.

<(lucky?) Heads! I showed the coin to the assassins for verification.>
```