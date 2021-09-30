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

# Quick Start

We've created a base `Repository` and `Collection` for you to extend to your liking with the `FirefuelRepository` and `FirefuelCollection`. 

The `Repository` is structurally reponsible for holding references to your main/top-level collection and any subcollections. The `Repository` is also logically responsible for ensuring all errors are caught and returned to your business logic layer as `Either` types.

See the [firefuel documentation](https://firefuel.dev/#/coreconcepts) to walk through the core concepts of using `firefuel`.

See also: [Handling Errors](https://firefuel.dev/#/coreconcepts?id=handling-errors)

# Handling Errors Yourself
No problem! Use the `Collection`s on their own, and forget `Repositories` even exist. Handle errors how you are today without making the switch.

# Getting Started

Simply add the latest version of `firefuel` as a dependency in your `pubspec.yaml` file. Import `package:firefuel/firefuel.dart` into your entry point (often `main.dart`). Then, initialize `firefuel` using the `Firefuel.initialize(FirebaseFirestore.instance);` before calling `runApp`.

Read the full walkthrough in our [docs](https://firefuel.dev/#/gettingstarted?id=installation).

# Issues and feedback

Please file all `firefuel` specific issues, bugs, or feature requests in our [issue tracker](https://github.com/SupposedlySam/firefuel/issues)

Please file `FlutterFire` specific issues, bugs, or feature requests in their [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are *not specific* to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).


## Maintainers

The maintainers for `firefuel` are [Jonah Walker](https://github.com/SupposedlySam) and 
[Morgan Hunt](https://github.com/mrgnhnt96)

## Logo Creator

Our logo was created by Shawn Meek