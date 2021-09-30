# firefuel_core

The core classes required to run firefuel

# Models

##  DocumentId

The `DocumentId` class should be used when you have a `String` that you intend to use as a document id in your Firebase database. 

`DocumentId` removes all forward slashes from the string by default. Set
`throwsOnForwardSlash` if you would prefer for it to throw a
[CannotContainForwardSlash] [FormatException] instead.

`DocumentId` also has the potential to throw a `FormatException` of type `CannotBeNoLongerThan1500Bytes`, `CannotSolelyConsistOfASingleOrDoublePeriod`, `CannotStartAndEndWithDoubleUnderscore`, or `CannotContainForwardSlash` when any of the rules matching the above exception types are broken.

### Examples

```dart
DocumentId('myDocId'); // valid
DocumentId(r'my\Doc\Id'); // stores myDocId
DocumentId(r'my\Doc\Id', throwsOnForwardSlash: true); // throws CannotContainForwardSlash
DocumentId('.'); // throws CannotSolelyConsistOfASingleOrDoublePeriod
DocumentId('..'); // throws CannotSolelyConsistOfASingleOrDoublePeriod
DocumentId('__someValue__') // throws CannotStartAndEndWithDoubleUnderscore
DocumentId(r'someReallyLongStringGreaterThan1500BytesInLength'); // throws CannotBeNoLongerThan1500Bytes
```

# Base Classes (abstract)

## Failure
The `Failure` class should be used as the super class (parent) of all your app specific failures. If you're using `firefuel`, your failures will be returned from a `Repository` as an `Either<Failure, YourSuccessType>`. 

You can also use `Failure` with your own architecture and without `firefuel`.

## Serializable
The `Serializable` class is simply used to know your model has a `toJson` method, which is required to convert models to JSON which will be stored in Firebase Cloud Firestore. 

`Serializable` should be `extended` and the `toJson` method should be implemented on all models you use to interact with data from the database.

### Examples

```dart
import 'package:firefuel/firefuel.dart';

/// Model for use with firefuel counter example app
class Counter extends Serializable {
  /// Default Constructor
  /// 
  /// [this.value] and [this.id] reference the class constructor arguments below
  const Counter({required this.value, required this.id}); 

  /// Creates a [Counter] from the provided JSON and snapshot id
  ///
  /// Note: A named constructor can also be used if you prefer.
  factory Counter.fromJson(Map<String, dynamic> json, String id) {
    return Counter(value: json[fieldValue] ?? 0, id: id);
  }

  /// Document fields
  /// 
  /// As a convention, always prefix every String used as a field on your 
  /// Document with field so you can easily access then in your code.
  static String fieldValue = 'value', fieldId = 'id';

  /// Class constructor arguments
  final int value;
  final String id;

  /// Required method implementation for [Serializable]
  @override
  Map<String, dynamic> toJson() => {fieldValue: value, fieldId: id};
 }
```

The above example uses common syntax for the `Dart` programming language. It's okay if you're feeling lost, take a look at the [Dart Language Tour](https://dart.dev/guides/language/language-tour).