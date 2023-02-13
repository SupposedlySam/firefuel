# Core Concepts (package:firefuel)

?> Please make sure to carefully read the following sections before working with [package:firefuel](https://pub.dev/packages/firefuel).

There are several core concepts that are critical to understanding how to use the firefuel package.

In the upcoming sections, we're going to discuss each of them in detail as well as work through how they would apply to a counter app.

## NoSQL Database

Firefuel works directly with [Firebase Cloud Firestore](https://firebase.flutter.dev/docs/firestore/overview) and the associated [Cloud Firestore Package](https://pub.dev/packages/cloud_firestore). As described in the usage section of their docs :

> Firestore stores data within "documents", which are contained within "collections". Documents can also contain nested collections.

Documents are sent and received from Firebase using [JSON](https://www.json.org/json-en.html). Using the cloud firestore package, you receive this data as an untyped collection of type `Map<String, dynamic>`. And although you can immediately access this data using the bracket notation `json['myKey']`, this is not scalable.

## Type Safe Documents

To make your Documents type safe, you'll want to convert them from a `Map` to a `Type` of your choosing. The most common way of converting a `Map` to a `Type` is to create a `class` with both a static (class level) `fromJson` method and an instance level `toJson` method. Your `class` will normally contain properties that match the type and name of the fields located on the Document in your Firestore Collection and be called a `Model` by convention. You'll then use the `fromJson` method on your model to convert the `Map` from Firestore to a type `T` (your `Model` class) you can use in your application.

## Streamlining Type Safety with Collections

You'll create a new Collection that extends FirefuelCollection for each top level collection, and subcollection in your Firebase project.

### Collection Detail

As developers, we always want to work with type safe code. This is why Firefuel makes all Firebase interactions type safe by default. Firefuel Collections require you to define `fromFirestore` and `toFirestore` methods that are used to automatically convert your data from a `DocumentSnapshot` (what's returned from Firebase) to type `T` (your model) on every interaction.

[collection.dart](_snippets/architecture/collection.dart.md ":include")

?> Note: snapshots are included so you can get access to all parts of the `DocumentSnapshot`, but `snapshot.data()` is what you'll use to access the `Map` needed to call your `fromJson` method on your model.

## Subcollections

### Summary

Subcollections have all the same functionality as a top level collection, but are nested inside of a document.

### Subcollection vs Array

Subcollections are used as a replacement for an array when you need the ability to filter, paginate, or get a single element. Arrays are all or nothing in Firebase, when you access your document, every item in the array will also be retrieved. If you expect for your array to become large, you should use a subcollection instead.

### Subcollection Setup

Since subcollections are located on a document, you need the document id to access its subcollections.

#### Add Document Id to Model

With firefuel, you're able to add the document id to your model in the `fromFirestore` method of a FirefuelCollection. There are two suggested approaches to take:

1. Pass the `snapshot.id` into your Model's `fromJson` method separately

```dart
 @override
  YourModel? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return data == null ? null : YourModel.fromJson(data, snapshot.id);
  }
```

2. Create a new JSON object with the document id included

```dart
@override
  YourModel? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    final dataWithId = { ...data, 'id': snapshot.id };

    return YourModel.fromJson(dataWithId);
  }
```

with option #2 you'd then access the docId with by the key 'id' inside your model.

#### Defining Collection Names

With a top level collection, your collection path is simple; it's just the name of your collection. For example, let's assume you're creating a `UserCollection` that extends `FirefuelCollection<User>`. When you create your constructor, you'll then pass the collection name to your parent (aka `super`, aka `FirefuelCollection`).

```dart
class UserCollection extends FirefuelCollection<User> {
    UserCollection() : super('users');

    ...

}
```

but with a subcollection, the collection path would need to be `users/myDocumentId/mySubCollectionName`. For the purpose of this example, let's assume you're a person who has friends :people_holding_hands:. In case you become an influencer, we'd like to store these friends as a subcollection so we don't return too much data at once.

Let's refactor the previous example a little bit so we can access our `UserCollection` from our subcollection.

```dart
class UserCollection extends FirefuelCollection<User> {
    UserCollection() : super(name);

    static const String name = 'users';
    ...

}
```

Now we can create our subcollection and require the docId to be passed in, where we'll then interpolate that into our collection path.

```dart
class FriendCollection extends FirefuelCollection<Friend> {
    FriendCollection(this.docId) :
        super('${UserCollection.name}/${docId.docId}/$name');

    static const String name = 'friends'
    final DocumentId docId;

    ...

}
```

#### Connect Your Subcollection With Extensions

Now, let's tie it all together. We'll create an extension method on `User` called `friends` so we can easily build a subcollection for any `User` model we have.

```dart
extension UserSubcollectionX on User {
  FriendCollection get friends {
    // The docId below is a property on the User
    return FriendCollection(docId!);
  }
}
```

Make sure to `export` the `UserSubcollectionX` class from the `User` model or you'll have to manually type in the `import` to the extension yourself.

user.dart

```dart
export 'package:your_app_name/path/to/user_subcollection_x.dart';
```

#### Access A Subcollection From A Model

Then, anywhere you get a `User` back you can access any method on your `friends` subcollection!

```dart
final UserCollection userCollection = UserCollection();

final User user = await userCollection.read(DocumentId('celebrity'));

final List<Friend> friends = await user.friends.readAll();
```

!> Firestore does not support recursively deleting subcollections. If you delete a document that has subcollections, the subcollections still exist in your database and can be reference by url. They will not be visible in the firebase console. See [Delete Collections](https://firebase.google.com/docs/firestore/manage-data/delete-data#collections) and [this SO answer](https://stackoverflow.com/questions/49286764/delete-a-document-with-all-subcollections-and-nested-subcollections-in-firestore/57623425#57623425) for how to handle deleting subcollections.

## Repositories (Optional)

### Summary

You'll create a new Repository that extends FirefuelRepository for each FirefuelCollection in your project.

### Detail

A Repository in Firefuel is responsible for the business logic of your data layer. The FirefuelRepository automatically handles catching any errors from the FirefuelCollection and returning them as an `Either` type (see Handling Errors below). Another example of data layer business logic could be be when to cache data locally vs online.

### Repository Example

[repository.dart](_snippets/architecture/repository.dart.md ":include")

## Handling Errors

Firefuel is opinionated on how you should handle errors. Firefuel exposes the [dartz package](https://pub.dev/packages/dartz) [Either type](https://pub.dev/documentation/dartz/latest/dartz/Either-class.html), and requires that Repositories handle any error from the Collection and return "Either" a `Failure` or the success type for the function.

Before we get too far ahead of ourselves, all methods inherited from the `FirefuelRepository` already take care of returning the `Either` type for you.

## Either Types (via dartz package)

For every `Either` type you must provide a Type you expect if the method fails (`Left`) and a Type you expect if the method succeeds (`Right`). For example, the following defines an `Either` type where a failure would return a `Failure` class and a success would return a `String`:

```dart
Either<Failure, String>
```

### Failures (Left)

A failure should be returned as a `Left`. The `Left` class is a subclass of the `Either` type and can be returned from a method.

```dart
Either<Failure, String> someMethod() {
    try {
        // some code that throws an Exception
    }
    catch(e, stackTrace) {
        return Left(Failure(e, stackTrace: stackTrace));
    }
}
```

### Success Values (Right)

A success should be returned as a `Right`. The `Right` class is a subclass of the `Either` type and can be returned from a method.

```dart
Either<Failure, String> someMethod() {
    try {
        return Right('success!');
    }
    catch(e, stackTrace) {
        // the code in the try is successful so we won't make it here
    }
}
```

### Working with Either Types

Once you receive an `Either` type back from a `Repository` you need to know how to handle them correctly. The benefit of the `Either` type is you will never forget to handle possible errors because your code is making you handle them.

#### Fold

The main way you'll "unbox" these values is with the `fold` method. The `fold` method requires two functions (callbacks) to be given to it as arguments. The first one is for the sad path (failure/left) the second is for the happy path (success value/right).

For this example we'll use one of the prebuilt methods on the `FirefuelRepository` called `read`. The `read` method returns either a `Failure` or a `T` (where `T` is the Type we expect when the method is successful).

```dart
final MyRepository repository = MyRepository();

// By convention, you should name any method returning an `Either` type with "Result".
final readResult = repository.read(DocumentId('someExistingDocId'));

readResult.fold(
    (failure) {
        print(failure.toString());
    },
    (success) {
        print(success.toString());
    },
);
```

"Folding" the result of the `Either` type allows for you to handle both sides at once. It's common to handle one side and just pass through the other side.

```dart
readResult.fold(left, (success) => print(success.toString()));
```

#### Map

Since the `read` method returns a nullable type, you may want to take the value returned and cast it as a non-nullable type instead. To do this, you can use the `map` method on your `Either` type.

```dart
return readResult.map((nullableSuccess) => nullableSuccess!);
```

The `map` method is considered "right bias", which means the value being passed into your callback will be the value on the "right" side. aka. the success value.

#### GetOrElse

The last two methods provided by the `dartz` library that you should know about are the `getOrElse` and the `swap` methods.

`swap` switches the sides of your `Either` type so that what was on the left is now on the right and vice versa.

```dart
final Either<Failure, MyClass> eitherType;

final swappedEither = eitherType.swap(); // Either<MyClass, Failure>
```

Where `getOrElse` just tries to return to you the `Right` side of the `Either`.

```dart
eitherType.getOrElse(() => MyClass.default());
```

If the `eitherType` is actually a `Left` and not a `Right` like you expected/wanted it to be then the callback is triggered and your default value is returned.

### Either Type Extensions

We found that there are many cases where:

1. We don't want to have to provide a default value
2. We want our code to fail if we try to get it and it's not what we're looking for
3. We want to turn a non-nullable type into a nullable type

For the above cases, we created our own extension methods.

#### GetRight and GetLeft

If you want your code to throw an exception (aka fail) when the value you're looking for isn't there, use the `getRight` and `getLeft` extension methods.

```dart
import 'package:firefuel/firefuel.dart';

final success = eitherType.getRight();
```

```dart
import 'package:firefuel/firefuel.dart';

final failure = eitherType.getLeft();
```

#### GetRightOrElseNull and GetLeftOrElseNull

If you want to take your non-nullable type and turn it into a null value when the value you're looking for isn't there, use the `getRightOrElseNull` and `getLeftOrElseNull` methods.

Note: `maybe` is a good prefix to use when the value can be nullable.

```dart
import 'package:firefuel/firefuel.dart';

final maybeSuccess = eitherType.getRightOrElseNull();
```

```dart
import 'package:firefuel/firefuel.dart';

final maybeFailure = eitherType.getLeftOrElseNull();
```
