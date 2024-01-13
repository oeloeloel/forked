# Link Validation

## Fall Through to Valid Target
[Fall through to valid target](#)

## Link to Valid Target {#link-to-valid-target}
[Valid link to valid target](#valid-target)
---
[Next](#)

## Link to Invalid Target {#link-to-invalid-target}
[Invalid link to invalid target](#invalid-target)
---
[Next](#)

## Jump to Valid Target {#jump-to-valid-target}
[Jump to valid target](: jump('#valid-target') :)
---
[Next](#)

## Jump to Invalid Target {#jump-to-invalid-target}
[Jump to invalid target](: jump('#invalid-target') :)
---
[Next](#)

## Mixed {#mixed-valid-invalid-links-jumps}
[Jump to valid target](: jump('#valid-target') :)
[Jump to invalid target](: jump('#invalid-target2') :)
[Valid link to valid target](#valid-target)
[Invalid link to invalid target](#invalid-target3)

---
[Next](#)

## Fall to Next Chunk {#fall-to-next-chunk}
[Fall to next chunk](: fall :)
---
[Next](#)

## Rise to Previous Chunk {#rise-to-previous-chunk}
[Rise to Previous chunk](: rise :)
---
[Next](#)

## Jump Relative Down One {#jump-relative-down-1}
[Jump relative down one](: jump 1 :)
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
[Jump hidden in comment](:
  ```rb
    # jump('#valid-target')
  ```
:)

## Valid Target {#valid-target}
Success

## Info
22 buttons total (search `](`)
14 links to targets (#___) (search `(#`) (Won't work for some links in future)
6 code jumps
10 fall throughs (#)
4 valid links/jumps
18 invalid links (including fall through)
8 invalid links (not including fall through)