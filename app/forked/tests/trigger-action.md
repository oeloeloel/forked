# Test Trigger Action

## Test Trigger Action executes code on click (single line)
~~~
[Code execution](: puts "success" :)
~~~

[Code execution](: puts "success" :)

---
[Next](#)


## Test Trigger Action executes code on click (multi line)
~~~
[Code execution](: 
  puts "success1" 
  puts "success2"
:)
~~~
[Code execution](: 
  puts "success1" 
  puts "success2"
:)
---
[Next](#)


## Test comment in trigger action (single line)

[Test comment in trigger action](: putz "triggered"; # this is a comment :)
---
[Next](#)


## Test comment in trigger action (multi line)
[Test comment in trigger action](:
  putz "triggered 1"
  # this is a comment 
  putz "triggered 2"
:)
---
[Next](#)

## Test comment at start of trigger action (single line)

[Test comment in trigger action](: # this is a comment; no command should be executed :)
---
[Next](#)

## Test comment at start of trigger action (multi-line)
[Test comment in trigger action](:
  # this is a comment 
  putz "triggered"
:)
---
[Next]()
