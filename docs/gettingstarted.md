# Getting Started

!> In order to start using firefuel you must have Firebase configured for your application. See the [FlutterFire Docs](https://firebase.flutter.dev/docs/overview/) before you continue.

## Overview

The firefuel repository consists of several pub packages:

- [firefuel](https://pub.dev/packages/firefuel) - The firefuel library.
- [firefuel_core](https://pub.dev/packages/firefuel_core) - The files required for firefuel to function. Core can be used on its own to provide DocumentId, UID, Serializable, and Failure to your app.

## Installation

For a [Flutter](https://flutter.dev/) application, we need to add the `firefuel` package to our `pubspec.yaml` as a dependency.

Run

```bash
flutter pub add firefuel;
```

### Dependencies

| package         | version                                                                                                      |
| --------------- | ------------------------------------------------------------------------------------------------------------ |
| cloud_firestore | [![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/cloud_firestore) |
| equatable       | [![pub package](https://img.shields.io/pub/v/equatable.svg)](https://pub.dev/packages/equatable)             |
| firebase_core   | [![pub package](https://img.shields.io/pub/v/firebase_core.svg)](https://pub.dev/packages/firebase_core)     |
| firefuel        | [![pub package](https://img.shields.io/pub/v/firefuel.svg)](https://pub.dev/packages/firefuel)               |

Use the above versions to populate your `pubspec.yaml` file. It should look something like this:

[pubspec.yaml](_snippets/getting_started/firefuel_pubspec.yaml.md ":include")

Next we need to install firefuel.

## Import

Now that we have successfully installed firefuel, we can create our `main.dart` and import `firefuel`.

[main.dart](_snippets/getting_started/firefuel_main.dart.md ":include")

For a Flutter application we can import `firefuel`.

You'll also want to initialize firefuel with the instance of FirebaseFirestore you want to use.

[main_init.dart](_snippets/getting_started/firefuel_main_init.dart.md ":include")
