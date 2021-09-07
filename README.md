## Firefuel

Firebase Cloud Firestore libraries to help you fuel your applications growth!

| Package | Pub |
| -- | -- |
| [firefuel](https://github.com/SupposedlySam/firefuel/tree/main/packages/firefuel)           | [![pub package](https://img.shields.io/pub/v/firefuel.svg)](https://pub.dev/packages/firefuel) |
| [firefuel_core](https://github.com/SupposedlySam/firefuel/tree/main/packages/firefuel_core) | [![pub package](https://img.shields.io/pub/v/firefuel_core.svg)](https://pub.dev/packages/firefuel_core)         |
| [firefuel_env](https://github.com/SupposedlySam/firefuel/tree/main/packages/firefuel_env)   | [![pub package](https://img.shields.io/pub/v/firefuel_env.svg)](https://pub.dev/packages/firefuel_env)   |

---

### Firefuel

Kickstart development with the Firefuel Library. This library gets you started with `Collection`s and `Repositories` with predefined `CRUD` (create, read, update, and delete) methods. Simply create a new class that extends `FirefuelCollection` for each collection you'll need to work with in your Firestore project and you're off and running!

Want more structure? Need subcollection support?

Extend the `FirefuelRepository` and pass in the `Collection` you want to use as the main collection. Then, add all other subcollections as properties of the repository. Any commonly accessed methods can be added to a `Collection` or to the `Repository` when they span multiple subcollections.

### Firefuel Core

The `core` classes used in our `firefuel` library. Released as a standalone package for those wanting access to core, without all the bells and whistles of `firefuel`.

### Firefuel Environments

Coming Soon!