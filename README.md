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
* Automatically (or manually) save the player's progress so they can continue playing where they left off

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

Now you can start writing your story in the `my-life-story.md` file. 

See the [Quick Reference](quick-reference.md) to see the formatting options and action commands available.

## User Manual
The user manual can be viewed in Forked. It is the default story that loads when you first start Forked. You can also [browse the manual on GitHub](https://github.com/oeloeloel/forked/blob/main/app/story.md?plain=1).

### Save game data
By default, Forked will automatically save the player's progress. When the game is reloaded, Forked will load the save file so the player can continue where they left off.

If you prefer not to automatically save player progress, you can disable autosaves:
1. Open the file `app/forked/defaults`
2. Change the line 
```rb
autosave: true,
```
to
```rb
autosave: false,
```

If autosaves are disabled, you can manually trigger a save from inside your story file using the `save_game` command.
To save when a new chunk is loaded:
```
## Save when this chunk loads {#save-on-load}
:: save_game ::
```

To save when a player activates a button:
```
## Save when player clicks button {#save-on-click}
[Click to save](: save_game :)
```

If you need to remove saved data, you can use the `clear_save_data` command.
Note that if autosaves are enabled, this command may not appear to have any effect.
To clear save data when a new chunk is loaded:
```
## Clear save data when this chunk loads {#clear-save-on-load}
:: clear_save_data ::
```

To clear save data when a player activates a button:
```
## Clear save data when player clicks button {#clear-save-on-click}
[Click to clear save data file](: clear_save_data :)
```