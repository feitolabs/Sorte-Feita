/// Divide [items] (já embaralhados) em duplas (size 2) ou trios (size 3).
/// Sobras: duplas com 1 sobrando viram um trio; trios com 1 sobrando viram
/// duas duplas (nunca grupos de 4); trios com 2 sobrando formam uma dupla.
List<List<String>> buildGroups(List<String> items, int size) {
  assert(size == 2 || size == 3);
  final result = <List<String>>[];
  if (items.isEmpty) return result;
  if (items.length < size) return [List.of(items)];

  final rem = items.length % size;
  var end = items.length - rem;
  if (size == 3 && rem == 1 && end >= 3) end -= 3;

  for (int i = 0; i < end; i += size) {
    result.add(items.sublist(i, i + size));
  }
  final left = items.sublist(end);
  if (size == 2) {
    if (left.isNotEmpty) result.last.addAll(left);
  } else if (left.length == 4) {
    result.add(left.sublist(0, 2));
    result.add(left.sublist(2));
  } else if (left.isNotEmpty) {
    result.add(left);
  }
  return result;
}
