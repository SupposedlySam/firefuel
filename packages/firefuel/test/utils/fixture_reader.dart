import 'dart:convert';
import 'package:universal_io/io.dart';

import '../utils/test_path.dart';

/// Read file contents
///
/// ```dart
/// String data = fixture('fixtures/my_file.json');
/// ```
String fixture(String path) => File(testPath(path)).readAsStringSync();

/// Read file contents as json
///
/// ```dart
/// Map<String, dynamic> json = fixtureAsJson('fixtures/my_file.json');
/// ```
Map<String, dynamic> fixtureAsJson(String path) => json.decode(fixture(path));
