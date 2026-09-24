## 0.2.0

feat: `Either`

- A sealed `Either<L, R>` with `Left` / `Right`, `fold`, `map`, `leftMap`, `flatMap`, `getOrElse`, `swap`, `isLeft`, `isRight`, and `left()` / `right()`. It replaces firefuel's re-export of `package:dartz`

feat: `FieldUpdate`

- Server-computed values usable from models with no Flutter or Firestore dependency: `increment`, `arrayUnion`, `arrayRemove`, `delete`, `serverTimestamp` / `ServerTimestamp`

fix!: `FirefuelFailure` no longer prints itself when constructed; `Failure.props` leads with the failure's type, so two kinds of failure wrapping one error are not equal under equatable 3

fix: `DocumentId(throwsOnForwardSlash:)` is typed `bool` (it was an untyped dynamic parameter)

chore: Dart ^3.10.0; `equatable` >=2.1.0 <4.0.0; removed `universal_io`; `Failure` constructors are `const`

## 0.1.7

chore: bump deps

Output from `flutter pub upgrade --major-versions --tighten`

```sh
  > equatable: ^2.0.7 -> ^2.0.8
  > universal_io: ^2.2.2 -> ^2.3.1
  > test: ^1.26.3 -> ^1.31.0
```

## 0.1.6

fix: remove lockfile so dependency management is easier in downstream apps

## 0.1.5

chore: bump deps

## 0.1.4

chore: bump deps

## 0.1.3

chore: bump deps

Output from `flutter pub upgrade --major-versions`

```sh
> args 2.5.0 (was 2.4.2)
> frontend_server_client 4.0.0 (was 3.2.0)
> meta 1.14.0 (was 1.12.0)
> test 1.25.4 (was 1.25.2)
> test_api 0.7.1 (was 0.7.0)
> test_core 0.6.2 (was 0.6.0)
> vm_service 14.2.1 (was 14.0.0)
> web 0.5.1 (was 0.5.0)
> web_socket_channel 2.4.5 (was 2.4.4)
```

## 0.1.2

chore: bump deps

- Environment
  - dart: 2.19.0 > 3.3.0
- Dependencies
  - stack_trace: 1.11.0 > 1.11.1
  - universal_io: 2.0.4 > 2.2.2

## 0.1.1

chore: bump deps

## 0.1.0

feat: Add web support

- replace dart:io with univarsal_io

## 0.0.1

Initial Release

- feat: export DocumentId, UID, Serializable and Failure
