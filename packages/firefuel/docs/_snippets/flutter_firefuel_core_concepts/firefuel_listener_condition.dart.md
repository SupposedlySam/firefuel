```dart
FirefuelListener<FirefuelA, FirefuelAState>(
  listenWhen: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on FirefuelA's state
  },
  child: Container(),
)
```
