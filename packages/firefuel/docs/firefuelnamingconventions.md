# Naming Conventions

!> The following naming conventions are simply recommendations and are completely optional. Feel free to use whatever naming conventions you prefer. You may find some of the examples/documentation do not follow the naming conventions mainly for simplicity/conciseness. These conventions are strongly recommended for large projects with multiple developers.

## Collection Conventions

> Collections should be named in **singular form** because events are things that have already occurred from the firefuel's perspective.

### Anatomy

[collection](_snippets/firefuel_naming_conventions/collection_anatomy.md ':include')

?> Initial load collections should follow the convention: `FirefuelSubject` + `Started`

#### Examples

✅ **Good**

[collections_good](_snippets/firefuel_naming_conventions/collection_examples_good.md ':include')

❌ **Bad**

[collections_bad](_snippets/firefuel_naming_conventions/collection_examples_bad.md ':include')

## Repository Conventions

> Since a Repository is just a top level collection, the same naming conventions apply to Repositories as they do to Collections -- just replace "Collection" with "Repository"