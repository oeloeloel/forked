# Bag (Inventory Management)

## Intro {#intro}
The `bag` is a place to store items held by the player. In classic text games, this is often called the player inventory.

These are the available commands for managing the the player's bag.

`bag_add item`	adds an item to the player's inventory
`bag_remove item`	removes an item from the player's inventory
`bag_has? item`	true if the item is in the player's inventory or false if not
`bag_sentence`	returns a string containing all the items in the player's bag
`bag_clear`	clear all items from the inventory