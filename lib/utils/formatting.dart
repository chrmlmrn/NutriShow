String formatValue(num value, String? portionSize) {
  if (portionSize != null) {
    if (portionSize.contains('.') || portionSize.contains('/')) {
      return value.toStringAsFixed(2);
    } else {
      final portionNumber = double.tryParse(portionSize);
      if (portionNumber != null && portionNumber % 1 != 0) {
        return value.toStringAsFixed(2);
      }
    }
  }
  return value.toStringAsFixed(0); // Round to whole number
}
