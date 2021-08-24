// Source: https://github.com/terryx/flutter-muscle/blob/master/github_provider/test/utils/test_path.dart
// Running unit tests via VSCode/Android studio has a slightly different working directory than unit tests invoked via 'flutter test' on the CLI
// This script is a way to ensure that tests can be run via the CLI and in a given IDE.

import 'dart:io';

import 'package:firefuel/src/utils/file_path_util.dart';

String testPath(String relativePath) {
  //Fix vscode test path
  final delimiter = Platform.pathSeparator;
  final current = Directory.current;
  final path = current.path.endsWith('${delimiter}test')
      ? current.path
      : '${current.path}${delimiter}test';
  final agnosticFilePath = FilePathUtil.agnosticFilePath(relativePath);

  return '$path$delimiter$agnosticFilePath';
}
