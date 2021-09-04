```dart
enum CounterEvent { increment, decrement }

class CounterFirefuel extends Firefuel<CounterEvent, int> {
  CounterFirefuel() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```
