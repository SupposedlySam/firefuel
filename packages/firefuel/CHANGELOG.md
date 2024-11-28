## 0.4.3
chore: upgrade dependencies

Output from `flutter pub upgrade --major-versions --no-example`
```sh
Resolving dependencies... 
Changed 3 constraints in pubspec.yaml:
  cloud_firestore: ^4.15.5 -> ^5.5.0
  fake_cloud_firestore: ^2.1.0 -> ^3.1.0
  very_good_analysis: ^5.1.0 -> ^6.0.0
Resolving dependencies... 
Downloading packages... 
> _flutterfire_internals 1.3.46 (was 1.3.30)
> antlr4 4.13.2 (was 4.13.1)
  async 2.11.0 (2.12.0 available)
  boolean_selector 2.1.1 (2.1.2 available)
  characters 1.3.0 (1.3.1 available)
  clock 1.1.1 (1.1.2 available)
> cloud_firestore 5.5.0 (was 4.17.0)
> cloud_firestore_platform_interface 6.5.0 (was 6.2.0)
> cloud_firestore_web 4.3.4 (was 3.12.0)
  collection 1.18.0 (1.19.1 available)
> equatable 2.0.7 (was 2.0.5)
  fake_async 1.3.1 (1.3.2 available)
> fake_cloud_firestore 3.1.0 (was 2.4.9)
> firebase_core 3.8.0 (was 2.30.0)
> firebase_core_platform_interface 5.3.0 (was 5.0.0)
> firebase_core_web 2.18.1 (was 2.15.0)
> firefuel_core 0.1.4 (was 0.1.3)
> leak_tracker 10.0.5 (was 10.0.0) (10.0.8 available)
> leak_tracker_flutter_testing 3.0.5 (was 2.0.1) (3.0.9 available)
> leak_tracker_testing 3.0.1 (was 2.0.1)
> logger 2.5.0 (was 2.2.0)
> logging 1.3.0 (was 1.2.0)
  matcher 0.12.16+1 (0.12.17 available)
> material_color_utilities 0.11.1 (was 0.8.0) (0.12.0 available)
> meta 1.15.0 (was 1.11.0) (1.16.0 available)
> mocktail 1.0.4 (was 1.0.3)
> more 4.4.0 (was 4.2.0)
  path 1.9.0 (1.9.1 available)
> quiver 3.2.2 (was 3.2.1)
> rx 0.4.0 (was 0.3.0)
> rxdart 0.28.0 (was 0.27.7)
  stack_trace 1.11.1 (1.12.0 available)
  string_scanner 1.2.0 (1.4.0 available)
> test_api 0.7.2 (was 0.6.1) (0.7.4 available)
> typed_data 1.4.0 (was 1.3.2)
> very_good_analysis 6.0.0 (was 5.1.0)
> vm_service 14.2.5 (was 13.0.0) (14.3.1 available)
> web 1.1.0 (was 0.5.1)
```

## 0.4.2
chore: upgrade dependencies

Output from `flutter pub upgrade --major-versions`
```sh
> _flutterfire_internals 1.3.30 (was 1.3.22)
> cloud_firestore 4.17.0 (was 4.15.5)
> cloud_firestore_platform_interface 6.2.0 (was 6.1.6)
> cloud_firestore_web 3.12.0 (was 3.10.5)
> fake_cloud_firestore 2.4.9 (was 2.4.8)
> firebase_core 2.30.0 (was 2.25.4)
> firebase_core_web 2.15.0 (was 2.11.4)
  leak_tracker 10.0.0 (10.0.5 available)
  leak_tracker_flutter_testing 2.0.1 (3.0.5 available)
  leak_tracker_testing 2.0.1 (3.0.1 available)
> firefuel_core 0.1.3 (was 0.1.2)
  leak_tracker 10.0.0 (10.0.5 available)
  leak_tracker_flutter_testing 2.0.1 (3.0.5 available)
  leak_tracker_testing 2.0.1 (3.0.1 available)
  material_color_utilities 0.8.0 (0.11.1 available)
  meta 1.11.0 (1.14.0 available)
  rx 0.3.0 (0.4.0 available)
  test_api 0.6.1 (0.7.1 available)
> logger 2.2.0 (was 2.0.2+1)
  material_color_utilities 0.8.0 (0.11.1 available)
  meta 1.11.0 (1.14.0 available)
  rx 0.3.0 (0.4.0 available)
  test_api 0.6.1 (0.7.1 available)
  vm_service 13.0.0 (14.2.1 available)
> web 0.5.1 (was 0.4.2)
These packages are no longer being depended on:
- js 0.6.7
```

## 0.4.1

chore!: upgrade dependencies
- Environment
  - dart: 2.19.0 > 3.3.0
- Dependencies
  - [cloud_firestore](https://pub.dev/packages/cloud_firestore/changelog): 4.3.2 > 4.15.5

## 0.4.0

refactor!: renames `count` and `streamCount` to `countAll` and `streamCountAll`

This change was made to be more explicit, aligns with other methods such as `readAll` and `streamAll`, and leads us to look for other options like `countWhere` and `streamCountWhere` when using it in our apps.

BREAKING:

- `count` is now `countAll`
- `streamCount` is now `streamCountAll`

## 0.3.2

feat: adds a firefuel brick that can be used through Mason.

To install the `firefuel` brick, run `mason add firefuel`.

Afterwards, run `mason get` and `mason make firefuel` in the directory you'd like your FirefuelCollection and Model generated.

For more information, see the [firefuel brick documentation](https://firefuel.dev/#/firefuelbrick) or refer to the [brick's README](https://github.com/SupposedlySam/firefuel/blob/main/packages/firefuel/bricks/firefuel/README.md)

## 0.3.1

feat: adds `Firefuel.reset` to clear internal property values without needing to re-initialize.

This is useful in teardown methods in your tests so you can ensure a clean state.

## 0.3.0

### Adds `count` method

Adds `count` and `countWhere` to all `Collection`s:

Uses the count feature introduced in v4.0.0 of `cloud_firestore` to count
documents on the server without retrieving documents.

> ## Firebase Release Notes
>
> Cloud Firestore now supports a count() aggregation query that allows you
> to determine the number of documents in a collection. The server
> calculates the count, and transmits only the result, a single integer,
> back to your app, saving on both billed document reads and bytes
> transferred, compared to executing the full query.

> Source: https://firebase.google.com/support/releases#firestore-count-queries

---

Adds `streamCount` and `streamCountWhere` to all `Collection`s:

These methods DO NOT use the server side count function provided by v4.0.0 of `cloud_firestore` as they do not currenly support streams. These methods works by streaming documents from Firestore and accessing the size property once the full query is executed. This method will incur document reads and bytes transferred.

## 0.2.3

Our API has not changed so this is only a patch for `firefuel`. However, `cloud_firestore` and `firebase_core` both have breaking changes.

- chore: bump versions to align with latest cloud_firestore

### General Upgrade Path from `cloud_firestore` 3 to 4

See the changelogs for `cloud_firestore` and `firebase_core` on `pub.dev` for more details.

---

#### Android

android>app>build.gradle:
`compileSdkVersion 31`
`minSdkVersion 19`
`targetSdkVersion 31`

android>build.gradle:
`ext.kotlin_version = '1.6.10'`
`classpath 'com.android.tools.build:gradle:7.1.2'`

android>gradle>wrapper>gradle-wrapper.properties:
`distributionUrl=https\://services.gradle.org/distributions/gradle-7.2-bin.zip`

android>app>src>main>AndroidManifest.xml:
Add this attribute inside of the manifest>application>activity node
`android:exported="true"`

---

#### iOS

ios>Podfile:
`platform :ios, '11.0'`

Open your Flutter project in XCode and update the Minimum Deployment Target for the Runner Target to version 11.

`cd` into your `ios` directory and run `pod update`

## 0.2.2

- chore: bump versions to align with latest cloud_firestore

## 0.2.1

- fix: stack trace to show caught stack instead of creating a new one inside of the catch block

## 0.2.0

BREAKING chore: Upgrade Dependencies

- cloud_firestore v3.1.1:
  - BREAKING FEAT: update Android minSdk version to 19 as this is required by Firebase Android SDK 29.0.0 (#7298).

## 0.1.1

- feat: add web support

  - replace dart:io with universal_io

## 0.1.0+1

- docs: update readme

## 0.1.0

feat: Batches, filtering, and auto-gen docs!

- add ability to create batches with `FirefuelBatch` (#45)
- add `whereById` to `FirefuelCollection` (#48)
- add `generateDocId` to `FirefuelCollection` (#47)

## 0.0.2+2

- docs(fix): fix broken code in readme
  - update code example for model

## 0.0.2+1

- docs: update readme
  - add code example of creating a model and collection

## 0.0.2

- docs: update package links in pubspec
  - add homepage link
  - change repository link to direcly link to package
  - add documentation link

## 0.0.1

- feat: initial release
