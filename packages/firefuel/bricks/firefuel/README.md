# firefuel

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

Creates a Collection, Model Stub and optional Repository for the [firefuel library](https://pub.dev/packages/firefuel).

---

## Getting Started 🚀

---

### Prerequisites

- Ensure the `mason_cli` is installed globally by running `flutter pub global activate mason_cli` in your Terminal.
- Run `mason init` inside of your Flutter app root directory.
- Run `mason add firefuel`

### Using the package

Run `mason make firefuel` and follow the prompts!

> Prompt: Collection name?

The name of a Firebase Cloud Firestore Collection (plural form)

Ex. Provide `Users` if you'd like to perform generation for your `Users` collection.

> Prompt: Document name? Commonly the singular form of your Collection name.

The name of a Firebase Cloud Firestore Document (singular form)

Ex. A `Users` collection would contain `User` documents.

> Prompt: Would you like to generate a Repository?

Whether to create a Repository class to contain your data layer business logic.

i.e. persist data both locally and remote, create a readable name for multiple collection access, etc.

For more information, see [the docs](https://firefuel.dev/#/firefuelbrick)

---

## Mason Resources 🧱

---

This is a starting point for a new brick.
A few resources to get you started if this is your first brick template:

- [Official Mason Documentation](https://github.com/felangel/mason/tree/master/packages/mason_cli#readme)
- [Code generation with Mason Blog](https://verygood.ventures/blog/code-generation-with-mason)
- [Very Good Livestream: Felix Angelov Demos Mason](https://youtu.be/G4PTjA6tpTU)
