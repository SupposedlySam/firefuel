import 'package:firefuel/firefuel.dart';

/// Every page of [query] from [source], in order, until the last.
Future<List<FirefuelPage<T>>> pageThrough<T extends Serializable>(
  ReadableQuery<T> source,
  FirefuelQuery query,
) async {
  final pages = <FirefuelPage<T>>[];
  FirefuelPage<T>? page;
  do {
    page = await source.paginate(query, after: page);
    pages.add(page);
  } while (page.status == ChunkStatus.nextAvailable);
  return pages;
}
