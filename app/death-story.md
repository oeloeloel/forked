# Death Story

## Doctor's Office {#doctor}

The doctor's office has a splendid view of the mountain. You've always dreamed about getting to that peak some day. Maybe you will, one day, when you have time.

Silhouetted against the window, the doctor's features are unreadable.

The doctor says "I'm afraid I have some very bad news. You have 30 seconds left to live. 

"By the time I finish talking, you will have 20 seconds left so, sorry about that. 

"By clicking the button below, you accept that the hospital is not responsible."

[Continue](#bucket)

## Bucket List {#bucket}

Tick tock.

[JUMP OUT OF A PLANE](#airport_jump)
[TELL SWEETHEART "I LOVE YOU"]()
[RIDE A CROCODILE](#lake)
[ROB A BANK](#bank)
<%!inventory_has? "trampoline"%[SEE THE WORLD](#airport_world)>
<%inventory_has? "trampoline"%[SEE THE WORLD](#trampoline)>
<%args.state.death_story.money.less_than 1000%[ORDER THE MOST EXPENSIVE THING ON THE MENU](#restaurant)>
<%!args.state.death_story.money.less_than 1000%[ORDER THE MOST EXPENSIVE THING ON THE MENU](#restaurant_with_money)>
[GAMBLE EVERYTHING AND LOSE](#casino)
[GO TO THE TOP OF A BIG MOUNTAIN](#mountain)
[TAKE PART IN AN ILLEGAL CAGE FIGHT](#cage)

## International Airport {#airport_jump}
<(airport_wait_reset)>

You are waiting at the International Airport for any plane that can take you straight up in the air. It's so exciting to think about skydiving back to earth. 

<(airport_wait_num_greater_than 0) But the wait is very long.>

<(airport_wait_num_greater_than 1) And boring.>

<(airport_wait_num_greater_than 2) Time passes.>

<(airport_wait_num_greater_than 3) You sit and look at your phone.>

<(airport_wait_num_greater_than 4) You start watching an entertaining video about a cat but you never finish it.>

<(airport_wait_num_less_than 4)[Continue waiting](airport_wait_add)>
<(airport_wait_num 4)[Continue waiting](airport_wait_add; cause_of_death_set "You died watching an entertaining cat video at an airport.")>

<(airport_wait_num 5)[Continue](#cemetary)>

<(!airport_wait_num 5)[Check your Bucket List](#bucket)>

## International Airport {#airport_world}
You are waiting at the International Airport for the first plane out. It's so exciting to think about the places you will see. But the wait is very long. And boring.

Time passes.

You sit and look at your phone.

[Check your Bucket List](#bucket)

## The First Bank You Could Find {#bank}
You are at the first bank you could find.

The teller glances up at you and back down at the huge pile of green paper on their desk.

"Give me all your money!" you shout.

The teller looks up again but this time without lifting their head.

"Why?" they ask.

"Oh, good point", you reply.

[Check your Bucket List](#bucket)



## Restaurant Très Cher {#restaurant}
You were lucky to get a table at the swankiest, most avant garde restaurant in town.

A snooty waiter approaches.

The waiter asks, "May I ask how you will be paying today?"

"Oh, good point", you reply.

[Check your Bucket List](#bucket)

## Restaurant Très Cher {#restaurant_with_money}
You were lucky to get a table at the swankiest, most avant garde restaurant in town.

The waiter asks, "What can I get you?"

<(inventory_has? "sandwich")"An excellent choice. Here is your sandwich. Please be advised that this sandwich contains small pieces of ground up diamond. It is not really for eating, more for sort of looking at.>

<(inventory_has? "soup")"An excellent choice. Here is your  crocodile soup. Please be advised that the raw crocodile is very dangerous and quite angry.">

<(!inventory_has? "soup" && !inventory_has? "sandwich")
[Soup .......... $20](inventory_add "soup")
[Sandwich ..... $980](inventory_add "sandwich")>

## Casino {#casino}
You walk into the casino feeling lucky.

A croupier beckons you over to the roulette table.

"Do you have any money?" they ask. 

<(!has_money?)You shake your head.

"If you don't have any money, I recommend that you get some money. And then you bring the money here. And then you gamble all that money on the roulette wheel. And then you do it again until you have no money. It's a LOT of fun." 
[Check your Bucket List](#bucket)>

<(has_money?)You nod your head.

"If you have some money, I recommend you put all the money on red. Unless you prefer to put all the money on black. They are both very good places to put all your money. It's a LOT of fun."

//<(gamble_won?) YOU WON!>

//<(!gamble_won?) YOU LOST!>

//[Put all the money on red](gamble "red")
//[Put all the money on black](gamble "black")
[Play roulette](#casino_gamble)
[Check your Bucket List](#bucket)>

## The Roulette Wheel {#casino_gamble}
<(gamble "reset")>

<(!args.state.placed_bet) Place your bets on the roulette wheel.>
<(args.state.placed_bet) The croupier spins the roulette wheel.>

<(args.state.placed_bet && args.state.color_choice == "red") The croupier says "I see you put all your money on red. That's a really smart choice.">
<(args.state.placed_bet && args.state.color_choice == "black") The croupier says "I see you put all your money on black. That's a really clever choice.">

<(args.state.winning_color == "red") "Oh, it's RED!>
<(args.state.winning_color == "black") "Oh, it's BLACK!">
<(!args.state.won && args.state.placed_bet) "You lost all of your money! I told you this would be fun!"

"And now you have to leave because you have lost all of your money. I suggest you find some more money and come back."

YOU COMPLETED AN ITEM ON YOUR BUCKET LIST.>
<(args.state.won) "You won a lot of money!">

<(args.state.death_story.money != 0)[Put all your money on red](gamble "red")
[Put all your money on black](gamble "black")>
<(args.state.death_story.money == 0)[Check your Bucket List](#bucket)>

## Mount Charlie {#mountain}

In front of you stands the impressive Mount Charlie. This mountain is your destiny. You have wanted to reach its summit since you were old enough to have pointless ambitions.

But you never had the the time. You still don't, but you're going to try it anyway.

You find a hand-hold. Then you find a second hand-hold. Then you realise you're holding your own hand.

Oh boy, this is tiring. You find a nice comfortable spot to sit down.

[Check your Bucket List](#bucket)

## Illegal Cage Fighting Venue {#cage}

It's not easy to find an illegal cage fighting venue at short notice, but you managed it.

The referee is speaking.

"In the red corner! The world champion of illegal cage fighting! The Masked Lump!

"Who is brave enough! To enter this illegal cage! And fight The Masked Lump!"

You step into the cage. The referee says "I want a good! Clean! Fight! Now shake hands!".

[Fight a Good Clean Fight](#clean_fight)
[Fight a Low-Down Dirty Fight](#dirty_fight)

## Illegal Cage Fighting Venue {#clean_fight}
<(inventory_add "trampoline")>
Without stopping to shake hands, The Masked Lump kicks you in the private parts. You buckle over and drop to the ground, clutching your nether region and crying tears of pain.

"Congratulations!" the referee shouts at you. "You won second prize!"

"A trampoline!"

The trampoline fits nicely in your pocket!

[Admire your Bucket List](#bucket)

## Illegal Cage Fighting Venue {#dirty_fight}
<(money_add 1000)>
Without stopping to shake hands, you punch The Masked Lump in the private parts. Your opponent buckles over and drops to the ground, clutching their nether region and crying tears of pain.

"Congratulations!" the referee shouts at you. "You won first prize!"

"One thousand dollars!"

You are now richer by $1,000!

[Admire your Bucket List](#bucket)

## Crocodile Lake {#lake}

There must be a crocodile around here somewhere. Why else would it be called Crocodile Lake?

"Hey crocodiles!" You yell. "I'm right here! Come and get me!".

You didn't really think this plan through.

Fortunately, no crocodiles take you up on your offer.

[Check your Bucket List](#bucket)

## Cemetary {#cemetary}
You expired while looking at your phone in an airport.

Now you're pushing up the daisies in the cemetary.

Rest in peace.

The End.



// TODO: Flush variables (reset state) on begin again
// TODO: Allow html/md style comments: <!--- --> (three dashes on opener)
// TODO: Triggers get picked up if there is a `]nospace(` anywhere in the line. It should also check to see if there is a `[` at the start of the line (at least for now - no inline triggers)
// TODO: try/catch command execution
// TODO: helpful error checking
// TODO: validate links within the document
// TODO: can't use round brackets in conditions/actions

// DONE: blank lines in display when there is a comment line removed!!!
// DONE: Make comments invisible (don't know why they're not)

