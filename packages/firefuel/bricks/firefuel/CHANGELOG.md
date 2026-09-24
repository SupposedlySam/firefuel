# 0.2.0

fix: generate code that compiles for any document name

- The model template hard-coded `User` for its constructor and `fromJson`,
  so every other document name produced broken code.
- `fromFirestore` referenced the raw `document_name` instead of its
  PascalCase form.
- The collection name was never substituted (`__COLLECTION_NAME__` was
  written out literally).

feat: target firefuel 0.5

- Models use `Equatable` as a mixin (EquatableMixin is deprecated) and
  stamp `createdAt` with `ServerTimestamp` on create.
- Repositories are named `<Name>Repository`, matching the naming
  conventions guide.
- Requires mason ^0.1.0.

# 0.1.1

fix: template filenames

- Note: now using brick_oven package to generate templates for Mason

# 0.1.0

feat: initial release
Asks for `collection_name`, `document_name` and whether to genereate a Repository.
