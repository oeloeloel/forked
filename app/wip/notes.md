kfischer_okarin — Today at 03:47
I myself would probably go with super simple, slightly verbose and possibly redundant top level commands and then have a nice list of commands somewhere 😉

```
memo 'Name', 'Jack'
memo_content 'Name'

counter_value 'anteaters'
counter_value_as_words 'anteaters' # two, three, twelve
add_to_counter 'anteaters', 1
subtract_from_counter, 'anteaters', 2
set_counter 'anteaters', 33
reset_counter 'anteaters' # same as set_counter 'anteaters', 0

start_countdown 'bomb', 30
remaining_countdown_seconds 'bomb'
stop_countdown 'bomb'
pause_countdown 'bomb' # maybe effectively just an alias for stop_countdown
resume_countdown 'bomb'

add_to_inventory 'a bread' # makes this item "unique"
add_to_inventory 'potion', 3 # makes this item countable
remove_from_inventory 'a bread'
remove_from_inventory 'potion', 1
remove_all_from_inventory 'potion'
amount_in_inventory 'potion'
amount_in_inventory_as_words 'potion' # three potions
inventory_as_words # "a bread, and three potions"
```

Conditional block
<`code_returns_true` This paragraph is visible! >

<`code_returns_true` This paragraph is visible!

And so is this one! > // > character must be on same line.

<`code_returns_true` [this button is visible!](#go_there)

[And so is this one!](#go_elsewhere)

> And so is this blocklist!

As well as this paragraph. >

<
```
multi
line
code
returns
true
```
 [this button is visible!](#go_there)

[And so is this one!](#go_elsewhere)

> And so is this blocklist! It doesn't close the condition block!

As well as this paragraph. The next gt symbol does and it doesn't need to be at the end of the line. > See?


Conditional block
%`code_returns_true` This paragraph is visible! %

%`code_returns_true` This paragraph is visible!

And so is this one! %

%`code_returns_true` [this button is visible!](#go_there)

[And so is this one!](#go_elsewhere)

> And so is this blocklist!

As well as this paragraph. %

%
```
multi
line
code
returns
true
```
 [this button is visible!](#go_there)

[And so is this one!](#go_elsewhere)

> And so is this blocklist! It doesn't close the condition block!

As well as this paragraph. The next gt symbol does and it doesn't need to be at the end of the line. % See?


<?`condition`
printed if true
?>

<?
```
printed if true
```
?>

<?

?>

<?`condition` single line allowed ?>
<?`condition`
multi line
allowed ?>

<?
```
conditon
```
multi
line
with
symbols on spare lines
?>

`action` doesn't print anything. Runs once.

<?`is_it_true`
You are right!
??
You are wrong!
?>
