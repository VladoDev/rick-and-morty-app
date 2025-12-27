final class PageInfo {
  final int count;
  final int pages;
  final Uri? next;
  final Uri? prev;

  const PageInfo({
    required this.count,
    required this.pages,
    required this.next,
    required this.prev,
  });
}

final class Paginated<T> {
  final PageInfo info;
  final List<T> results;

  const Paginated({required this.info, required this.results});
}
