extension MapExt on Map<String, dynamic> {
  T? getKey<T>(String key) {
    try {
      return this[key] as T?;
    } catch (e) {
      return null;
    }
  }
}
