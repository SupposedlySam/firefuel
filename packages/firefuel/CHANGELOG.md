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
