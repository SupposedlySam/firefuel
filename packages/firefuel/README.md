<p align="center">
<img src="https://raw.githubusercontent.com/SupposedlySam/firefuel/main/docs/assets/firefuel_logo.png" height="200" alt="firefuel" />
</p>

<p align="center">
<a href="https://pub.dev/packages/firefuel"><img src="https://img.shields.io/pub/v/firefuel.svg" alt="Pub"></a>
<a href="https://github.com/SupposedlySam/firefuel"><img src="https://img.shields.io/github/stars/SupposedlySam/firefuel.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://github.com/tenhobi/effective_dart"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style: effective dart"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

# Overview

The goal of this package is to make it easy to interact with [Cloud Firestore](https://firebase.google.com/docs/firestore/) database. The `firefuel` community aims to always make this package simple, intuitive, and consistent. `firefuel` wraps the [cloud_firestore](https://pub.dev/packages/cloud_firestore) plugin, and provides conventions to help jump-start your development.

Still not convinced? See our documentation on why we think you should [choose firefuel](https://firefueldocs.com/#/whyfirefuel)

# Scope

`firefuel` focuses on simplifying the edge of your data layer, meaning this package pairs well with all ui, state management, model generation, and injection packages.

# Getting Started

Add `firefuel` to your `pubspec.yaml` (it needs Dart 3.10 / Flutter 3.38 or newer). Import `package:firefuel/firefuel.dart` into your entry point (often `main.dart`). Then initialize `firefuel` with `Firefuel.initialize(FirebaseFirestore.instance);` before calling `runApp`.

Upgrading from 0.4? Read the [migration guide](https://firefueldocs.com/#/migrating).

Read the full walkthrough in our [docs](https://firefueldocs.com/#/gettingstarted?id=installation).

# Quick Start

Choose a collection from your Firestore db and create a class to model your document. For this example let's assume you have a collection of users with a username, first name, last name, and favorite color.

Each model needs to extend `Serializable` so `firefuel` is able to automatically convert the model to JSON. We'll also want to add a `fromJson` method that we'll use to convert it from json into an instance of the model.

Most of the time, when comparing two models of the same type, you want to know whether the two instances have identical values. However, by default, Dart will compare whether the instances reference the same object in memory. We suggest using the `equatable` package with your models to compare by value rather than by reference.

## Create a Model

```dart
class User extends Serializable with Equatable {
  const User({
    required this.docId,
    required this.favoriteColor,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json, String docId) {
    return User(
      docId: docId,
      favoriteColor: json[fieldFavoriteColor] as String,
      username: json[fieldUsername] as String,
    );
  }

  static const String fieldDocId = 'docId';
  static const String fieldFavoriteColor = 'favoriteColor';
  static const String fieldUsername = 'username';

  final String docId;
  final String favoriteColor;
  final String username;

  @override
  List<Object?> get props => [docId, username, favoriteColor];

  @override
  Map<String, dynamic> toJson() {
    return {
      fieldDocId: docId, // optionally add this to your document
      fieldFavoriteColor: favoriteColor,
      fieldUsername: username,
    };
  }
}
```

## Create a Collection

```dart
class UserCollection extends FirefuelCollection<User> {
  UserCollection() : super(collectionName);

  static const collectionName = 'users';

  @override
  User? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return data == null
        ? null
        : User.fromJson(snapshot.data()!, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore(User? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
```

## Code Generation

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

You can write out the above classes manually or generate them using the Mason CLI

See the docs for more information: [firefuel brick](https://firefueldocs.com/#/firefuelbrick)

## Use It

That's it. Every read, query, stream and write is now a typed method:

```dart
final users = UserCollection();

final blueFans = await users.where([
  Clause(User.fieldFavoriteColor, isEqualTo: 'blue'),
]);
final live = users.streamAll();
await users.updateFields(
  docId: DocumentId('ada'),
  fields: {User.fieldFavoriteColor: 'green'},
);
```

Beyond CRUD you get `Clause.or`, cursors and `limitToLast` through `FirefuelQuery`, server-side counts and aggregates, listening with cache and pending-write metadata, collection groups, `FieldUpdate` transforms (including `ServerTimestamp` straight from `toJson`), transactions, atomic batches and offline-friendly writes. See the [API guide](https://firefueldocs.com/#/firefuelapi) and the [full API reference](https://pub.dev/documentation/firefuel/latest/).

Wrap the collection in a `FirefuelRepository` and each method returns `Either<Failure, T>` instead of throwing.

# Related Links

Follow the [official walkthrough](https://supposedlysam.medium.com/firefuel-basics-e4d97f1685c9) on Medium

See the [firefuel documentation](https://firefueldocs.com/#/coreconcepts) to learn the core concepts of using `firefuel`.

# Issues and feedback

Please file all `firefuel` specific issues, bugs, or feature requests in our [issue tracker](https://github.com/SupposedlySam/firefuel/issues)

Please file `FlutterFire` specific issues, bugs, or feature requests in their [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are _not specific_ to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Maintainers

The maintainers for `firefuel` are [Jonah Walker](https://github.com/SupposedlySam) and
[Morgan Hunt](https://github.com/mrgnhnt96)

## Logo Creator

Our logo was created by [Shawn Meek](https://shawnmeek.com/)
