# Test Action Block

## Action block execute on start (single line)
Action block automatically executes when chunk is loaded. Check console for 'success' message.

:: putz "success" ::

[Next](#)

## Action block execute on start (multi line)
Action block automatically executes when chunk is loaded. Check console for two 'success' messages.

::
  putz "success1"
  putz "success2"
::