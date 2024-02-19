# Bag (Inventory Management)

## Intro {#intro}

:: state.forked.defaults[:autosave] = false ::

The `bag` is a place to store items held by the player. In classic text games, this is often called the player inventory.

---
[Next](#)


## bag_add item {#bag-add}
`bag_add item`	adds an item to the player's inventory.

When this chunk loads, three items will be added to the bag.

::
bag_add "item 1"
bag_add "item 2"
bag_add "item 3"
::

You should see three items printed out below:

<: bag_sentence :>
---
[Next](#)

<:
```rb
    subject = args.outputs.primitives[5...6]
    expect = [{:x=>200, :y=>498, :text=>"item 1, item 2, item 3. ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## bag_remove item {#bag-remove}
`bag_remove item`	removes an item from the player's inventory

When this chunk loads, item 2 will be removed from the bag.

::
bag_remove "item 2"
::

You should see two items printed out below:

<: bag_sentence :>

---
[Next](#)

<:
```rb
    subject = args.outputs.primitives[5...6]
    expect = [{:x=>200, :y=>498, :text=>"item 1, item 3. ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## bag_has? item {#bag-has}
`bag_has? item`	returns true if the item is in the player's inventory or false if it is not.

A new item is added to the player's bag.

::
bag_add "pocket calculator"
::

If the item was successfully added, you will see it printed below:

<: "You got the pocket calculator" if bag_has? "pocket calculator" :>

---
[Next](#)

<:
```rb
    putz subject = args.outputs.primitives[5...6]
    expect = [{:x=>200, :y=>498, :text=>"You got the pocket calculator ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>


## bag_sentence {#bag-sentence}
`bag_sentence`	returns a string containing all the items in the player's bag.

:: bag_add "a precious moon diamond" ::

Printed out below, you should see below "item 1, item 3, pocket calculator, a precious moon diamond."

<: bag_sentence :>
---
[Next](#)

<:
```rb
    putz subject = args.outputs.primitives[4...5]
    expect = [{:x=>200, :y=>533, :text=>"item 1, item 3, pocket calculator, a precious moon diamond. ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>


## bag_clear {#bag-clear}
`bag_clear`	clears all items from the inventory.

:: bag_clear ::

Your bag has been emptied out. Below you will see "nothing".

<: bag_sentence :>

---
[Next]()
<:
```rb
    putz subject = args.outputs.primitives[4...5]
    expect = [{:x=>200, :y=>533, :text=>"nothing ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

[Return to start](#intro-intro)