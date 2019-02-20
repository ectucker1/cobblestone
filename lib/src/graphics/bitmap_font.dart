part of cobblestone;

/// Loads a font from a .fnt file and a texture
Future<BitmapFont> loadFont(String fontUrl, Future<Texture> texture) async {
  String fontData = await HttpRequest.getString(fontUrl);
  Texture atlasTexture = await texture;
  return new BitmapFont.parse(fontData, atlasTexture);
}

// Parsers for loading .fnt file
Parser _number =
(char('-').optional() & digit().plus()).flatten().trim().map(int.parse);
Parser _list = (_number & char(','))
    .and()
    .seq(_number.separatedBy(char(','), includeSeparators: false))
    .pick(1);
Parser _string = (char('"') &
(word() | whitespace() | char('.') | char('/')).star().flatten() &
char('"'))
    .pick(1);

Parser _variable = word().plus().flatten().trim() &
char('=').trim() &
(_string | _list | _number);
Parser _line = word().plus().flatten().trim() & _variable.plus().trim();

Parser _font = _line.star();

// A set of data and a texture used for rendering text
class BitmapFont {
  // Raw data of a .fnt file
  List _data;

  // Parsed list of characters and kernings
  Map<int, _Character> _characters;
  List<_Kerning> _kernings;

  // The height of a line of text
  int lineHeight;

  int base;

  // The texture used to rendering the font
  Texture texture;

  // Creates a font from the contents of a .fnt and a texture
  BitmapFont.parse(String description, this.texture) {
    this._data = _font.parse(description).value;

    var common = _data.firstWhere((e) => e[0] == "common")[1];
    lineHeight = _getVariable(common, "lineHeight");
    base = _getVariable(common, "base");

    this._characters = new Map();
    _data.where((e) => e[0] == "char").forEach((e) {
      var props = e[1];
      _characters[_getVariable(props, "id")] = new _Character(
          _getVariable(props, "id"),
          _getVariable(props, "x"),
          _getVariable(props, "y"),
          _getVariable(props, "width"),
          _getVariable(props, "height"),
          _getVariable(props, "xoffset"),
          _getVariable(props, "yoffset"),
          _getVariable(props, "xadvance"),
          texture);
    });

    this._kernings = [];
    _data.where((e) => e[0] == "kerning").forEach((e) {
      var props = e[1];
      _kernings.add(new _Kerning(
          _getVariable(props, "first"),
          _getVariable(props, "second"),
          _getVariable(props, "amount")));
    });
  }

  _getVariable(line, String name) {
    return line.firstWhere((e) => e[0] == name)[2];
  }

  // Renders text to the given [batch] using the font
  void drawLine(SpriteBatch batch, int x, int y, String text, {int lineWidth: -1}) {
    if(lineWidth == -1) {
      drawWord(batch, x, y, text);
      return;
    }

    _Character space = _characters[' '.codeUnitAt(0)];
    int cursor = 0;
    int line = y;
    Queue<String> words = Queue.from(text.split(' '));
    while(words.isNotEmpty) {
      String word = words.removeFirst();
      int width = measureWord(word);
      if(width > lineWidth) {
        limitedWords(word, lineWidth).forEach((section) => words.addFirst(section));
        word = words.removeFirst();
      }

      if(cursor + width > lineWidth) {
        cursor = 0;
        line -= lineHeight;
      }
      drawWord(batch, x + cursor, line, word);
      cursor += width;
      cursor += space.xadvance;
    }
  }

  // Draws text without considering wrapping
  void drawWord(SpriteBatch batch, int x, int y, String word) {
    int lastChar = -1;

    for(var code in word.runes) {
      if(_characters.containsKey(code)) {
        x += calcKerning(lastChar, code);
        _Character char = _characters[code];
        batch.draw(char.glyph, x + char.xoffset,
            y + lineHeight - base - char.height - char.yoffset);
        x += char.xadvance;
        lastChar = code;
      }
    }
  }

  /// Calculates the kerning between two characters
  int calcKerning(int last, int next) {
    if(_kernings.indexWhere((k) => k.char2 == next) != -1) {
      _kernings.where((k) => k.char2 == next).forEach((k) {
        if (last == k.char1) {
          return k.offset;
        }
      });
    }
    return 0;
  }

  // Calculates the length in pixels of a string rendered with this font
  int measureWord(String word) {
    int length = 0;
    int lastChar = -1;
    for(var code in word.runes) {
      if(_characters.containsKey(code)) {
        length += _characters[code].xadvance;
        length += calcKerning(lastChar, code);
      }
    }
    return length;
  }

  // Breaks up a word that would measure longer than [maxLength]
  Iterable<String> limitedWords(String word, int maxLength) {
    List<String> results = [];
    String current = "";
    for(var char in word.split('')) {
      current += char;
      if(measureWord(current + '-') > maxLength) {
        results.add(current.substring(0, current.length - 1) + '-');
        current = char;
      }
    }
    results.add(current);
    return results.reversed;
  }

}

// Data concerning a character in a BitmapFont
class _Character {
  int id;
  int x;
  int y;
  int width;
  int height;
  int xoffset;
  int yoffset;
  int xadvance;

  Texture font;
  Texture glyph;

  _Character(this.id, this.x, this.y, this.width, this.height, this.xoffset,
      this.yoffset, this.xadvance, this.font) {
    this.glyph = new Texture.clone(font);
    glyph.setRegion(x, font.height - y - height, width, height);
  }
}

// Data considering the kerning between two characters
class _Kerning {

  int char1;
  int char2;

  int offset;

  _Kerning(this.char1, this.char2, this.offset);

}