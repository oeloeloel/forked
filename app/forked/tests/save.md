# Saving and Loading Game Progress

## Saving and Loading Game Progress
This file assumes that

1. Autosaving is enabled\
2. There is no current save file when beginning this test

If necessary, go to the `data` folder and delete the save files

No save file should be created yet (by default, progress is not saved immediately).

Check the `data` folder.

---
[Next](#)


## Autosave
Autosave must be enabled (it is by default) for this test to work.

When entering this chunk, a save file was created in the data folder.

---
[Next](#)

## Autoload
Autosave must be enabled and the previous chunk (# Autosave) must have been visited.

Quit the game and re-open it. This chunk, the current chunk, should be displayed.

---
[Next](#)

## Save Bag (Inventory)
When this chunk loads, inventory will be added to the bag. This will be verified in the next chunk.

::
bag_add "item 1"
bag_add "item 2"
bag_add "item 3"
::

---
[Next](#)

## View Bag

The bag should contain 3 items. If you see them listed below, the test passed.

The bag contains:
<: bag_sentence :>

---
[Next](#)

## Remove Item from Bag

The second item is removed from the bag when this chunk loads. The current list of items is shown below.

:: bag_remove "item 2" ::

The bag contains:
<: bag_sentence :>

Quit and restart this story. When it reloads, the same two items should be displayed.

---
[Next](#)

## Empty Bag

All items are removed from the bag using the `bag_clear` command.

:: bag_clear ::

The bag contains:
<: bag_sentence :>