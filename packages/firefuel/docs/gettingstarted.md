# Getting Started

?> In order to start using firefuel you must have the [Dart SDK](https://dart.dev/get-dart) installed on your machine.

## Overview

Firefuel consists of several pub packages:

- [firefuel](https://pub.dev/packages/firefuel) - Core firefuel library
- [flutter_firefuel](https://pub.dev/packages/flutter_firefuel) - Powerful Flutter Widgets built to work with firefuel in order to build fast, reactive mobile applications.
- [angular_firefuel](https://pub.dev/packages/angular_firefuel) - Powerful Angular Components built to work with firefuel in order to build fast, reactive web applications.
- [hydrated_firefuel](https://pub.dev/packages/hydrated_firefuel) - An extension to the firefuel state management library which automatically persists and restores firefuel states.
- [replay_firefuel](https://pub.dev/packages/replay_firefuel) - An extension to the firefuel state management library which adds support for undo and redo.

## Installation

For a [Dart](https://dart.dev/) application, we need to add the `firefuel` package to our `pubspec.yaml` as a dependency.

[pubspec.yaml](_snippets/getting_started/firefuel_pubspec.yaml.md ':include')

For a [Flutter](https://flutter.dev/) application, we need to add the `flutter_firefuel` package to our `pubspec.yaml` as a dependency.

[pubspec.yaml](_snippets/getting_started/flutter_firefuel_pubspec.yaml.md ':include')

For an [AngularDart](https://angulardart.dev/) application, we need to add the `angular_firefuel` package to our `pubspec.yaml` as a dependency.

[pubspec.yaml](_snippets/getting_started/angular_firefuel_pubspec.yaml.md ':include')

Next we need to install firefuel.

!> Make sure to run the following command from the same directory as your `pubspec.yaml` file.

- For Dart or AngularDart run `pub get`

- For Flutter run `flutter packages get`

## Import

Now that we have successfully installed firefuel, we can create our `main.dart` and import `firefuel`.

[main.dart](_snippets/getting_started/firefuel_main.dart.md ':include')

For a Flutter application we can import `flutter_firefuel`.

[main.dart](_snippets/getting_started/flutter_firefuel_main.dart.md ':include')

For an AngularDart application we can import angular_firefuel.

[main.dart](_snippets/getting_started/angular_firefuel_main.dart.md ':include')
