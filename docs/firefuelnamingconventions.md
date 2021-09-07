# Naming Conventions

!> The following naming conventions are simply recommendations and are completely optional. Feel free to use whatever naming conventions you prefer. You may find some of the examples/documentation do not follow the naming conventions mainly for simplicity/conciseness. These conventions are strongly recommended for large projects with multiple developers.

## Collection Conventions

> Collections should be named in **singular form** because most methods on a collection work directly with a single Document.

### Anatomy

[collection](_snippets/firefuel_naming_conventions/collection_anatomy.md ':include')

?> `Collections` should follow the convention: `CollectionName` + Collection

#### Examples

✅ **Good**

[collections_good](_snippets/firefuel_naming_conventions/collection_examples_good.md ':include')

❌ **Bad**

[collections_bad](_snippets/firefuel_naming_conventions/collection_examples_bad.md ':include')

## Repository Conventions

> Since a Repository is just a top level collection, the same naming conventions apply to Repositories as they do to Collections -- just replace "Collection" with "Repository"


## Either Conventions

`Either` types stored in variables should be named with the description of the success value you plan to receive, plus the word "Result". "Result" signifies the value is not of your success type, but rather a possibility of "either" a success or failure that hasn't been handled yet.

?> `Either` type variables should follow the convention: `successValue` + Result

#### Examples

✅ **Good**

[eithers_good](_snippets/firefuel_naming_conventions/either_examples_good.md ':include')

❌ **Bad**

[eithers_bad](_snippets/firefuel_naming_conventions/either_examples_bad.md ':include')

## Nullable Variable Conventions

When working with null-safe code, it's easy to let your IDE tell you what's nullable or not. However, it gets a little confusing when the same type can be turned from a null-safe type into a nullable type after a method call.

When working with the extension methods `getRightOrElseNull` and `getLeftOrElseNull` you should name the returned variable with the prefix of `maybe`. 

?> Nullable type variables should follow the convention: maybe + `Descriptor`

#### Examples

✅ **Good**

[nullables_good](_snippets/firefuel_naming_conventions/nullable_examples_good.md ':include')

❌ **Bad**

[nullables_bad](_snippets/firefuel_naming_conventions/nullable_examples_bad.md ':include')