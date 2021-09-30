
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // first initialize Firebase
  Firefuel.initialize(FirebaseFirestore.instance);

  runApp(...);
}
```