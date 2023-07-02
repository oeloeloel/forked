# Test Adventure

## Welcome to the Land of Test {#welcome}
You are now in the Land of Test where freedom is an illusion! But don't be discouraged and instead have fun because plenty of adventure awaits you!

[Start your grand adventure!](#kingdom_bridge)
[On second thought, let's not go. Tis a silly place.](#silly_place)

## Bridge to the Kingdom {#kingdom_bridge}
You stand before an unadorned bridge with a small entrance guarded by a massive knight draped in golden armor. He calmly stares at you, unmoved by your existence.

There's a path leading below the bridge towards the river that flows beneath it.

["May I pass?"](#kingdom_bridge_talk_event)
<```inventory_has? 'sword'```
  [|Sword| Attack!](#kingdom_bridge_attack_event)
  [|Sword| Present the sword](#kingdom_bridge_found_event)>
[Take the offroad path](#kingdom_bridge_underside)

## Bridge to the Kingdom {#kingdom_bridge_talk_event}
The knight motions towards the kingdom.

"You may go. Have a nice journey."

Well... that was easy.

[Be on your way!](#to_the_kingdom)

## Towards the Kingdom {#to_the_kingdom}
Finally, we're off to a grand adventure!

<```inventory_has? 'event_bridge_knight_murder'``` There may have been bumps along the way, but c'est la vie for you I suppose.>

But in the end, that's a story for another time.

[End of Adventure](```$gtk.request_quit```)

## Bridge to the Kingdom {#kingdom_bridge_attack_event}
You casually walk past the knight while whistling very conspicuously and then in a sudden twist you turn and stab him in the back!
He turns to you and grabs your shirt tightly, but alas your attack was fatal.
He slowly crumbles and barely ables to make out the word "why~~" before letting out his last gasp.
You feel a cold chill as you gaze at his lifeless body before you.

[Continue](#kingdom_bridge_murderer)

## Bridge to the Kingdom {#kingdom_bridge_murderer}
As you quickly shuffle away towards the kingdom in a hurry, you begin to hear wails of the nearby villagers gathering and grieving the loss of their beloved knight who so happened to be retiring next month actually.

Before you begin to suffer the the agony of contemplating the meaning of life and death and your hands involved in it. You cover your head and continue on. Eesh.

[Off to the kingdom you heartless bastard!](```inventory_add 'event_bridge_knight_murder'; jump '#to_the_kingdom'```)

## Bridge to the Kingdom {#kingdom_bridge_found_event}
<```!inventory_has? 'event_kingdom_bridge_found_presented_sword'```
The knight brightens in gleeful surprise!

"You found my sword! I've been looking for that. I'll give you my gold as a reword for finding it"
["Ok!"](#kingdom_bridge_found_event_yes)
["But I want the sword!"](#kingdom_bridge_found_event_no)
>
<```inventory_has? 'event_kingdom_bridge_found_presented_sword'```
"Oh ho? Have you changed your mind?"
["Ok!"](#kingdom_bridge_found_event_yes)
["NO!"](#kingdom_bridge_found_event_no)
>

## Bridge to the Kingdom {#kingdom_bridge_found_event_yes}
"Ahh, thank you lad. It's not much but it's all I have."

He hands you a rather large bag of gold coins.

Does he understand the value of this??

[Take the gold](```inventory_add 'large_gold_bag'; inventory_del 'sword'; jump '#kingdom_bridge'```)

## Bridge to the Kingdom {#kingdom_bridge_found_event_no}
<```!inventory_has? 'event_kingdom_bridge_found_presented_sword'```
"Ahh, I see. Well... I suppose it *is* yours since I lost it. Very well, may it help you on your journey."
>
<```inventory_has? 'event_kingdom_bridge_found_presented_sword'```
The knight looks very dejected.
>
[Gleefully covet the shiny sword in your hands](```inventory_add 'event_kingdom_bridge_found_presented_sword'; jump '#kingdom_bridge'```)

## Under the Kingdom's Bridge {#kingdom_bridge_underside}
You stand under the bridge to the Kingdom.

On one side is a river that seems *very* dangerous to cross.

On the other is the path that leads back to the topside of the bridge's entrance.

<```!inventory_has? 'event_kingdom_bridge_underside_sword'``` You see something glimmering in the sand.
[Check out the glimmering spot in the sand](#kingdom_bridge_underside_event)>
[Swim!](#kingdom_bridge_underside_swim)
[Head back to the top](#kingdom_bridge)

## Under the Kingdom's Bridge {#kingdom_bridge_underside_swim}
You dip your toes into the water to feel the very cold and refreshing water. Unconcerned by the rapid currents flowing before you, you dive headfirst into the river with an expression of glee.

Unbeknownst to you, the river is shallower than it seems. You have dived into a rock headfirst and have now knocked yourself unconcious.

The river carries you away, never to be seen again.

[Continue](#you_died)

## Under the Kingdom's Bridge {#kingdom_bridge_underside_event}
You found a gloriously shiny iron sword in the sand!

Who would drop such a thing here?
[Take the sword](```inventory_add 'sword'; inventory_add 'event_kingdom_bridge_underside_sword'; jump '#kingdom_bridge_underside'```)

## YOU DIED {#you_died}
[Rise from your grave](```inventory_clear; jump '#welcome'```)

## Leaving this silly land {#silly_place}
The people are sad to see you go and wave with weary and heartfelt goodbyes.
They will by waiting for a hero to arrive and save their kingdom from hefty levies and overbearing lords who force them to dance everyday once more...

[Good riddance you peasants!](```gtk.request_quit```)
