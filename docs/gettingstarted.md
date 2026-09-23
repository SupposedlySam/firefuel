# Getting Started

!> In order to start using firefuel you must have Firebase configured for your application. See the [FlutterFire Docs](https://firebase.flutter.dev/docs/overview/) before you continue.

## Overview

The firefuel repository consists of several pub packages:

- [firefuel](https://pub.dev/packages/firefuel) - The firefuel library.
- [firefuel_core](https://pub.dev/packages/firefuel_core) - The pure-Dart types firefuel is built on: `Serializable`, `DocumentId`, `Failure`, `Either` and `FieldUpdate`. Use it on its own in model packages that shouldn't depend on Flutter or Firestore.

## Installation

For a [Flutter](https://flutter.dev/) application, we need to add the `firefuel` package to our `pubspec.yaml` as a dependency.

Run

```bash
flutter pub add firefuel
```

firefuel 0.5 needs Dart 3.10 / Flutter 3.38 or newer. Upgrading from 0.4? Read [Migrating to 0.5](migrating.md).

### Dependencies

| package         | version                                                                                                      |
| --------------- | ------------------------------------------------------------------------------------------------------------ |
| cloud_firestore | [![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/cloud_firestore) |
| equatable       | [![pub package](https://img.shields.io/pub/v/equatable.svg)](https://pub.dev/packages/equatable)             |
| firebase_core   | [![pub package](https://img.shields.io/pub/v/firebase_core.svg)](https://pub.dev/packages/firebase_core)     |
| firefuel        | [![pub package](https://img.shields.io/pub/v/firefuel.svg)](https://pub.dev/packages/firefuel)               |

Use the above versions to populate your `pubspec.yaml` file. It should look something like this:

[pubspec.yaml](_snippets/getting_started/firefuel_pubspec.yaml.md ":include")

## Import

Now that we have successfully installed firefuel, we can create our `main.dart` and import `firefuel`.

[main.dart](_snippets/getting_started/firefuel_main.dart.md ":include")

`package:firefuel/firefuel.dart` re-exports the Firestore types you need day to day, including `FirebaseFirestore`, so you rarely need a separate `cloud_firestore` import.

Initialize firefuel with the `FirebaseFirestore` instance you want to use, before any collection is used.

[main_init.dart](_snippets/getting_started/firefuel_main_init.dart.md ":include")

`Firefuel.initialize` also takes an `env` prefix for collection names, an [observer](firefuelapi.md#observing-failures) for failures, and a [write acknowledgement mode](firefuelapi.md#writing-while-offline) for offline-friendly writes.

## Next

- Define your first collection: [Core Concepts](coreconcepts.md)
- See everything a collection can do: [API Guide](firefuelapi.md)
- Generate the boilerplate: [Build With Mason](firefuelbrick.md)
