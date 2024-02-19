# Saving and Loading Game Progress

## Saving and Loading Game Progress {#start}

:: 
```rb
autosave_off
clear_save_data
```
::

When this chunk was loaded, autosave was set to false and any existing save data for this story was deleted.

The current save file `dynamic-2547718119-dev.txt` should not exist.

Check the data folder to ensure that the save file does not exist.

---
[Next](#)



## Autosave

In this chunk, autosave is enabled. A save file was created in the data folder.

The save file name will be:\
`dynamic-2547718119-dev.txt`

Check that the file exists.

:: autosave_on ::

---
[Next](#)\
[Restart tests](#saving-and-loading-game-progress-start)

## Autoload

Quit the game and re-open it. This chunk, the current chunk, should be displayed.

---
[Next](#)\
[Restart tests](#saving-and-loading-game-progress-start)

## Save Bag (Inventory)
When this chunk loads, inventory will be added to the bag and displayed below. Close and re-open the game to check that the inventory remains the same.

::
```rb
bag_add "item 1"
bag_add "item 2"
bag_add "item 3"
```
::

<: bag_sentence :>

---
[Next](#)\
[Restart tests](#saving-and-loading-game-progress-start)

## Clear Bag

::
```rb 
autosave_off
clear_save_data
```
::

Autosave has been disabled and the save data has been cleared.

Check that the save file is removed.

---
[Next](#)\
[Restart tests](#saving-and-loading-game-progress-start)

## Autosaving disabled (last test)

:: 
autosave_off
::

Autosave is disabled. Close and reopen the game. 

When the game loads, you should not see this screen. The game will be returned to the first screen.

---
[Next]()\
[Restart tests](#saving-and-loading-game-progress-start)