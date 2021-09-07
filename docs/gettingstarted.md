# Getting Started

?> In order to start using firefuel you must have the [Dart SDK](https://dart.dev/get-dart) installed on your machine.

## Overview

Firefuel consists of several pub packages:

- [firefuel](https://pub.dev/packages/firefuel) - Core firefuel framework.
- [firefuel_core](https://pub.dev/packages/firefuel_core) - The core files required for firefuel to function. Core can be used on its own to provide DocumentId, UID, Serializable, and Failure to your app.
- [firefuel_env](https://pub.dev/packages/firefuel_env) - A standalone Firebase environment organizer for your application.

## Installation

For a [Dart](https://dart.dev/) application, we need to add the `firefuel` package to our `pubspec.yaml` as a dependency.

[pubspec.yaml](_snippets/getting_started/firefuel_pubspec.yaml.md ':include')

Next we need to install firefuel.

!> Make sure to run the following command from the same directory as your `pubspec.yaml` file.

- Run `flutter packages get`

## Import

Now that we have successfully installed firefuel, we can create our `main.dart` and import `firefuel`.

[main.dart](_snippets/getting_started/firefuel_main.dart.md ':include')

For a Flutter application we can import `flutter_firefuel`.

You'll also want to initialize firefuel with the instance of FirebaseFirestore you want to use.

[main_init.dart](_snippets/getting_started/firefuel_main_init.dart.md ':include')
