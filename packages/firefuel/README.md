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

The goal of this package is to make it easy to interact with [Cloud Firestore API](https://firebase.google.com/docs/firestore/). The `firefuel` community aims to always make this package simple, intuitive, and consistent. `firefuel` wraps the [cloud_firestore](https://pub.dev/packages/cloud_firestore) plugin, and provides conventions to help jump-start your development. 

Still not convinced? See our documentation on why we thing you should [choose firefuel](https://firefuel.dev/#/whyfirefuel)

# Scope
`firefuel` focuses on simplifying the edge of your data layer, meaning this package pairs well with all ui, state management, model generation, and injection packages.

# Getting Started

Simply add the latest version of `firefuel` as a dependency in your `pubspec.yaml` file. Import `package:firefuel/firefuel.dart` into your entry point (often `main.dart`). Then, initialize `firefuel` using the `Firefuel.initialize(FirebaseFirestore.instance);` before calling `runApp`.

Read the full walkthrough in our [docs](https://firefuel.dev/#/gettingstarted?id=installation).

# Quick Start

Choose a collection from your Firestore db and create a class to model your document. For this example let's assume you have a collection of users with a username, first name, last name, and favorite color. 

Each model needs to extend `Serializable` so `firefuel` is able to automatically convert the model to JSON. We'll also want to add a `fromJson` method that we'll use to convert it from json into an instance of the model.

Most of the time, when comparing two models of the same type, you want to know whether the two instances have identical values. However, by default, Dart will compare whether the instances reference the same object in memory. I suggest using the `equatable` package with your models to compare by value rather than by reference.

## Create a Model

```dart
class User extends Serializable with EquatableMixin {
  static const String fieldDocId = 'docId',
      fieldUsername = 'username',
      fieldFavoriteColor = 'favoriteColor';

  const User({
    required this.docId,
    required this.username,
    required this.favoriteColor,
  });

  final String docId;
  final String username;
  final String favoriteColor;

  @override
  List<Object?> get props => [docId, username, favoriteColor];

  factory User.fromJson(Map<String, dynamic> json, String docId) {
    return User(
      docId: docId,
      username: json[fieldUsername],
      favoriteColor: json[fieldFavoriteColor],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      fieldDocId: docId, // optionally add this to your document
      fieldUsername: username,
      fieldFavoriteColor: favoriteColor,
    };
  }
}
```

## Create a Collection

```dart
class UserCollection extends FirefuelCollection<User> {
  Collection() : super(collectionName);
  
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

## Profit
That's it! Now you can access your data through the `UserCollection` with any of [the following methods](https://pub.dev/documentation/firefuel/latest/firefuel/FirefuelCollection-class.html).

# Related Links

Follow the [official walkthrough](https://supposedlysam.medium.com/firefuel-basics-e4d97f1685c9) on Medium 

See the [firefuel documentation](https://firefuel.dev/#/coreconcepts) to learn the core concepts of using `firefuel`.


# Issues and feedback

Please file all `firefuel` specific issues, bugs, or feature requests in our [issue tracker](https://github.com/SupposedlySam/firefuel/issues)

Please file `FlutterFire` specific issues, bugs, or feature requests in their [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are *not specific* to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).


## Maintainers

The maintainers for `firefuel` are [Jonah Walker](https://github.com/SupposedlySam) and 
[Morgan Hunt](https://github.com/mrgnhnt96)

## Logo Creator

Our logo was created by [Shawn Meek](https://shawnmeek.com/)