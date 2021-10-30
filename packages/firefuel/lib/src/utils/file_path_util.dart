import 'package:universal_io/io.dart';

class FilePathUtil {
  /// Provide a [Platform] agnostic file path
  ///
  /// Finds the separator currently being used in the file path given and
  /// replaces it with the [Platform.pathSeparator].
  static String agnosticFilePath(String filePath) {
    final delimiter = Platform.pathSeparator;
    final delimiterUsed =
        RegExp(r'\w+(.{1})\w+').firstMatch(filePath)!.group(0)!;

    final matchExists = delimiterUsed.length == 1;
    final isNotOSDelimiter = delimiterUsed != delimiter;
    if (matchExists && isNotOSDelimiter) {
      return filePath.replaceAll(delimiterUsed, delimiter);
    }
    return filePath;
  }
}
