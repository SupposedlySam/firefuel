```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // initialize Firebase first
  Firefuel.initialize(FirebaseFirestore.instance);

  runApp(const MyApp());
}
```
