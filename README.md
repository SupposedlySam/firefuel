## Firefuel

Firebase Cloud Firestore libraries to help you fuel your applications growth!

| Package | Pub |
| -- | -- |
| [firefuel](https://github.com/SupposedlySam/firefuel/tree/main/packages/firefuel)           | [![pub package](https://img.shields.io/pub/v/firefuel.svg)](https://pub.dev/packages/firefuel) |
| [firefuel_core](https://github.com/SupposedlySam/firefuel/tree/main/packages/firefuel_core) | [![pub package](https://img.shields.io/pub/v/firefuel_core.svg)](https://pub.dev/packages/firefuel_core)         |

---

### Firefuel

Kickstart development with the Firefuel Library. Simply create a `FirefuelCollection` for your model and instantly get predefined `CRUD` (create, read, update, and delete) operations. 

View the [full README](https://github.com/SupposedlySam/firefuel/tree/main/packages/firefuel), get access to [detailed documentation](http://firefueldocs.com), and see the [API Reference](https://pub.dev/documentation/firefuel/latest/)

#### Want more?
See the [Medium article](https://supposedlysam.medium.com/firefuel-basics-e4d97f1685c9) where we walk you through how to install, setup, and use the package (including using subcollections).



### Firefuel Core

The pure-Dart types `firefuel` is built on: `Serializable`, `DocumentId`, `Failure`, `Either` and `FieldUpdate`. It depends on neither Flutter nor Firestore, so model packages shared with a server or CLI can use it on their own.

---

### Working on this repo

The packages form a [pub workspace](https://dart.dev/tools/pub/workspaces): run `flutter pub get` once at the root. Flutter is pinned with [fvm](https://fvm.app) in `.fvmrc`. CI runs format, `dart analyze --fatal-infos` and every package's tests; see [`.github/workflows/ci.yaml`](.github/workflows/ci.yaml). Plans and design decisions live in [`project_management/`](project_management/README.md). Agents: start with [`llms.txt`](docs/llms.txt).

The documentation site is served by GitHub Pages straight from `docs/` on `main`: **merging to `main` publishes the docs**.
