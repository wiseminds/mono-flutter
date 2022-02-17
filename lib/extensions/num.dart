import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

final Random _rnd = Random();

extension I on int {
  String get getRandomString => String.fromCharCodes(Iterable.generate(
    this, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}