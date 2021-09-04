# Core Concepts (package:firefuel)

?> Please make sure to carefully read the following sections before working with [package:firefuel](https://pub.dev/packages/firefuel).

There are several core concepts that are critical to understanding how to use the firefuel package.

In the upcoming sections, we're going to discuss each of them in detail as well as work through how they would apply to a counter app.

## NoSQL Database

Firefuel works directly with [Firebase Cloud Firestore](https://firebase.flutter.dev/docs/firestore/overview) and the associated [Cloud Firestore Package](https://pub.dev/packages/cloud_firestore). As described in the usage section of their docs :

> Firestore stores data within "documents", which are contained within "collections". Documents can also contain nested collections. 

Documents are sent and received from Firebase using [JSON](https://www.json.org/json-en.html). Using the cloud firestore package, you receive this data as an untyped collection of type `Map<String, dynamic>`. And although you can immediately access this data using the bracket notation `json['myKey']`, this is not scalable.

## Type Safe Documents

To make your Documents type safe, you'll want to convert then from a `Map` to a `Type` of your choosing. The most common way of converting a `Map` to a `Type` is to create a `class` with both a static (class level) `fromJson` method and an instance level `toJson` method. Your `class` will normally contain properties that match the type and name of the fields located on the Document in your Firestore Collection and be called a `Model` by convention. You'll then use the `fromJson` method on your model to convert the `Map` from Firestore to a type `T` (your `Model` class) you can use in your application.

## Streamlining Type Safety with Collections

As developers, we always want to work with type safe code. This is why Firefuel makes all Firebase interactions type safe by default. Firefuel Collections require you to define `fromFirestore` and `toFirestore` methods that are used to automatically convert your data from a `DocumentSnapshot` (what's returned from Firebase) to type `T` (your model) on every interaction. 


[collection.dart](_snippets/architecture/collection.dart.md ':include')

?> Note: snapshots are included so you can get access to all parts of the `DocumentSnapshot`, but `snapshot.data()` is what you'll use to access the `Map` needed to call your `fromJson` method on your model.

You'll create a new Collection that extends FirefuelCollection for each top level collection, or subcollection in your Firebase project.

## Repositories
