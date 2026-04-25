# Firefuel Playground

An interactive, single-page example that shows common Firefuel APIs against an
in-memory `FakeFirebaseFirestore` instance.

The playground includes small demos for:

- creating and reading documents
- live collection streams
- repository error handling
- field updates and transforms
- queries, counts, sums, and averages
- pagination
- multi-document reads and streams
- document-change streams
- batch writes

## Running

```sh
fvm flutter run
```

No Firebase project setup is required for the example because `main.dart`
initializes Firefuel with `FakeFirebaseFirestore`.
