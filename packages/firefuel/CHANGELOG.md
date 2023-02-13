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
