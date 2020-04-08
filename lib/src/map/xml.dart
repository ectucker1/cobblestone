part of cobblestone;

/// Reads [attrib] on the given [element] parsed by [parseAttrib].
///
/// If the element does not have the attribute, [defaultVal] or null is returned instead.
T _parseAttrib<T>(
    xml.XmlElement element, String attrib, T Function(String) parseAttrib,
    [T defaultVal]) {
  String data = element.getAttribute(attrib);

  if (data == null) return defaultVal;

  return parseAttrib(data);
}

/// Splits a string by "," and returns a list with the output of [parseItem]
List<T> _parseCsv<T>(String csv, T Function(String) parseItem) {
  List<T> parsed = [];
  csv.split(',').forEach((String item) => parsed.add(parseItem(item)));
  return parsed;
}