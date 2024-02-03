# Link Validation

## Fall Through to Valid Target A
~~~
[Fall through to valid target](#)
~~~

[Fall through to valid target](#)
---
[Next](#)


## Fall Through to Valid Target B (final)

This chunk is the target for "Fall Through to Valid Target A"
---
[Next](#)


## Link to Valid Target A {#link-to-valid-target}
~~~
[Valid link to valid target](#link-to-valid-target-b)
~~~
[Valid link to valid target](#link-to-valid-target-b)
---
[Next](#)


## Link to Valid Target B (final) {#link-to-valid-target-b}

This chunk is the target for Link to Valid Target A
---
[Next](#)


## Link to Invalid Target {#link-to-invalid-target}
Following the link will create an exception.
[Link to invalid target (does not exist)](#invalid-target-does-not-exist)
---
[Next](#)


## Jump to Valid Target A {#jump-to-valid-target-a}
[Jump to valid target](: jump('#jump-to-valid-target-b') :)
---
[Next](#)


## Jump to Valid Target B (final) {#jump-to-valid-target-b}
This chunk is the target for Jump to Valid Target A
[Next](#)


## Jump to Invalid Target {#jump-to-invalid-target}
Following the link will create an exception.
[Jump to invalid target (does not exist)](: jump('#invalid-target-does-not-exist') :)
---
[Next](#)

## (Deprecated) Fall to Next Chunk {#fall-to-next-chunk}
The `fall` action has been deprecated. Please use `jump(1)` instead.
[Fall to next chunk](: fall :)
---
[Next](#)


## (Deprecated) Rise to Previous Chunk {#rise-to-previous-chunk}
The `rise` action has been deprecated. Please use `jump(-1)` instead.
[Rise to Previous chunk](: rise :)
---
[Next](#)


## Jump Relative Down One A {#jump-relative-down-1-a}
[Jump relative down one](: jump 1 :)
---
[Next](#)

## Jump Relative Down One B {#jump-relative-down-1-b}
This chunk is the target for Jump Relative Down One A
---
[Next](#)

## Jump Relative Up One B {#jump-relative-up-1-b}
This chunk is the target for Jump Relative Up One A
---
[Next](#)


## Jump Relative Up One {#jump-relative-up-1}
[Jump relative up one](: jump(-1) :)
---
[Next](#)


## More Jump Cases {#more-jump-cases}
[Jump without target (ignored because it will fail at runtime)](: jump :)
[Multiline jump](:
  a = 1
  jump('#valid-target')
  b = 2
:)
[Inline jump with multiple commands](: c = 3; jump('#valid-target'); d = 4 :)
[Jump with code fence](:
  ```rb
  jump('#valid-target')
  ```
:)
[Jump hidden in comment (should have no effect)](:
  ```rb
    # jump('#valid-target')
  ```
:)


## Valid Target {#valid-target}
Success