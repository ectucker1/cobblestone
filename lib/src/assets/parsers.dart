part of cobblestone;

// Parser for AngelCode .fnt files
class _FontParser {
  static final Parser _number =
      (char('-').optional() & digit().plus()).flatten().trim().map(int.parse);
  static final Parser _string = (char('"') &
          (word() | whitespace() | char('.') | char('/')).star().flatten() &
          char('"'))
      .pick(1);
  static final Parser _list = (_number & char(','))
      .and()
      .seq(_number.separatedBy(char(','), includeSeparators: false))
      .pick(1);

  // Parsers for loading .fnt file
  static final Parser _variable = word().plus().flatten().trim() &
      char('=').trim() &
      (_string | _list | _number);
  static final Parser _line =
      word().plus().flatten().trim() & _variable.plus().trim();

  static final Parser _file = _line.star();
}

// Parser for LibGDX .atlas files
class _AtlasParser {
  static final Parser _number =
      (char('-').optional() & digit().plus()).flatten().trim().map(int.parse);
  static final Parser _string =
      (word() | char('.') | char('/')).plus().flatten().trim();
  static final Parser _bool = (string('true') | string('false'))
      .flatten()
      .trim()
      .map((val) => val == 'true');
  static final Parser _literal = (_number | _string | _bool);
  static final Parser _list = (_literal & char(','))
      .pick(0)
      .and()
      .seq(_literal.separatedBy(char(','), includeSeparators: false)).pick(1);

  static final Parser _variable = (word().plus().flatten().trim() &
          char(':').trim() &
          (_list | _bool | _number | _string))
      .permute([0, 2]);
  static final Parser _sectionName = (word() | char('.')).plus().flatten().trim();

  static final Parser _region = _sectionName & _variable.star();
  static final Parser _page = _sectionName & _variable.star() & _region.star();
  static final Parser _file = _page.star();
}

final Parser _fontParser = _FontParser._file;
final Parser _atlasParser = _AtlasParser._file;
