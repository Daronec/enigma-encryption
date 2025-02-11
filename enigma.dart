import 'dart:math';

class Rotor {
  late List<int> map;
  late List<int> notches;
  bool step;
  int index = 0;
  int ring = 0;

  Rotor({List<int>? cipher, List<int>? notches, this.step = true, Random? random}) {
    random ??= Random();
    if (cipher == null) {
      List<int> chars = List<int>.generate(Machine.ALL_CHARS.length, (i) => i);
      map = List<int>.from(chars)..shuffle(random);
    } else {
      setMap(cipher);
    }
    setNotches(notches ?? [random.nextInt(Machine.ALL_CHARS.length)]);
  }

  int encode(int value) {
    int ind = (value + index - ring + Machine.ALL_CHARS.length) % Machine.ALL_CHARS.length;
    return (map[ind] - index + ring + Machine.ALL_CHARS.length) % Machine.ALL_CHARS.length;
  }

  int decode(int value) {
    int ind = (value + index - ring + Machine.ALL_CHARS.length) % Machine.ALL_CHARS.length;
    return (map.indexOf(ind) - index + ring + Machine.ALL_CHARS.length) % Machine.ALL_CHARS.length;
  }

  void turnover({bool override = false}) {
    if (step || override) {
      index = (index + 1) % Machine.ALL_CHARS.length;

      for (int i = 0; i < notches.length; i++) {
        notches[i] = (notches[i] - 1 + Machine.ALL_CHARS.length) % Machine.ALL_CHARS.length;
      }
    }
  }

  void setMap(List<int> charList) {
    if (charList.length != Machine.ALL_CHARS.length ||
        !List<int>.generate(Machine.ALL_CHARS.length, (i) => i).every((i) => charList.contains(i))) {
      throw Exception("Invalid cipher configuration");
    }
    map = List<int>.from(charList);
  }

  void setNotches(List<int> inds) {
    if (inds.any((ind) => ind < 0 || ind >= Machine.ALL_CHARS.length)) {
      throw Exception("invalid notch position");
    }
    notches = List<int>.from(inds);
  }

  void setIndex(int ind) {
    if (ind < 0 || ind >= Machine.ALL_CHARS.length) {
      throw Exception("invalid index");
    }
    index = ind;
  }

  void setRing(int ind) {
    if (ind < 0 || ind >= Machine.ALL_CHARS.length) {
      throw Exception("invalid index");
    }
    ring = ind;
  }

  void reset() {
    index = 0;
    ring = 0;
  }

  String getKey() {
    return Machine.ALL_CHARS[index];
  }
}

class Reflector extends Rotor {
  Reflector({bool step = false, Random? random}) : super(step: step) {
    random ??= Random();
    var temp = List<int>.generate(Machine.ALL_CHARS.length ~/ 2, (i) => i)..shuffle(random);

    map = List<int>.filled(Machine.ALL_CHARS.length, 0);
    for (int i = 0; i < temp.length; i++) {
      int a = temp[i];
      int b = temp[i] + Machine.ALL_CHARS.length ~/ 2;
      map[a] = b;
      map[b] = a;
    }

    index = 0;
    ring = 0;
    notches = [];
  }
}

class EntryRotor extends Rotor {
  EntryRotor({bool step = false}) : super(step: step) {
    map = List<int>.generate(Machine.ALL_CHARS.length, (i) => i);
  }
}

class Plugboard {
  late List<int> map;

  Plugboard([dynamic connections = 1, Random? random]) {
    setPlugs(connections, random: random);
  }

  int encodeChar(int value) {
    if (value < 0 || value >= Machine.ALL_CHARS.length) {
      throw Exception("invalid character");
    }
    return map[value];
  }

  void setPlugs(dynamic connections, {Random? random}) {
    random ??= Random();
    map = List<int>.generate(Machine.ALL_CHARS.length, (i) => i);

    if (connections is String) {
      var pairs = connections.split(' ');
      if (pairs.length > Machine.ALL_CHARS.length ~/ 2) {
        throw Exception("invalid plugboard config");
      }
      for (var pair in pairs) {
        if (pair.length != 2) {
          throw Exception("invalid plugboard config");
        }
        int a = Machine.ALL_CHARS.indexOf(pair[0]);
        int b = Machine.ALL_CHARS.indexOf(pair[1]);
        if (a == -1 || b == -1) {
          throw Exception("invalid character in plugboard config");
        }
        map[a] = b;
        map[b] = a;
      }
    } else if (connections is List<List<int>>) {
      if (connections.length > Machine.ALL_CHARS.length ~/ 2) {
        throw Exception("invalid plugboard config");
      }
      for (var pair in connections) {
        if (pair.length != 2) {
          throw Exception("invalid plugboard config");
        }
        map[pair[0]] = pair[1];
        map[pair[1]] = pair[0];
      }
    } else if (connections is int) {
      if (connections > Machine.ALL_CHARS.length ~/ 2) {
        throw Exception("invalid plugboard config");
      }
      var temp = List<List<int>>.generate(connections, (_) =>
      [random!.nextInt(Machine.ALL_CHARS.length), random.nextInt(Machine.ALL_CHARS.length)]);
      for (var pair in temp) {
        map[pair[0]] = pair[1];
        map[pair[1]] = pair[0];
      }
    } else {
      throw Exception("invalid plugboard config");
    }
  }
}

class Machine {
  static const int CHAR_SET_SIZE = 256;
  static final String ALL_CHARS = _generateAllChars();

  static String _generateAllChars() {
    StringBuffer buffer = StringBuffer();
    // Латинский алфавит (нижний и верхний регистр)
    for (int i = 65; i <= 90; i++) buffer.writeCharCode(i);
    for (int i = 97; i <= 122; i++) buffer.writeCharCode(i);
    // Кириллический алфавит (верхний и нижний регистр)
    for (int i = 1040; i <= 1071; i++) buffer.writeCharCode(i);
    for (int i = 1072; i <= 1103; i++) buffer.writeCharCode(i);
    // Цифры
    for (int i = 48; i <= 57; i++) buffer.writeCharCode(i);
    // Знаки препинания и специальные символы
    buffer.write('.,;:!?"-() ');
    return buffer.toString();
  }

  late List<Rotor> rotors;
  late EntryRotor entry;
  late Reflector reflector;
  late Plugboard plugboard;
  late String key;
  late String refPos;
  final Random random;

  Machine({int rotorCount = 3, dynamic plugboard = 1, int? seed}) :
        random = Random(seed) {
    assert(rotorCount > 0);

    rotors = List<Rotor>.generate(rotorCount, (_) => Rotor(random: random));

    entry = EntryRotor();
    reflector = Reflector(random: random);

    this.plugboard = Plugboard(plugboard, random);

    key = rotors.map((r) => r.getKey()).join();
    refPos = reflector.getKey();
  }

  void advanceRotors() {
    List<bool> step = List<bool>.filled(rotors.length + 1, false);

    List<List<int>> notches = rotors.reversed.map((r) => r.notches).toList();
    notches.add(reflector.notches);

    step[0] = true;
    for (int i = 1; i < step.length; i++) {
      if (notches[i - 1].contains(0)) {
        step[i] = true;
        step[i - 1] = true;
      }
    }

    for (int i = 0; i < step.length - 1; i++) {
      if (step[i]) {
        rotors[rotors.length - 1 - i].turnover();
      }
    }

    if (step.last) {
      reflector.turnover();
    }
  }

  String encodeString(String string, {String? key}) {
    if (key != null) {
      configureMachine(key: key);
    } else {
      configureMachine(key: this.key);
    }

    String out = '';
    for (int i = 0; i < string.length; i++) {
      String char = string[i];
      if (!ALL_CHARS.contains(char) || char == ' ') {
        out += char;  // Пропускаем символы, которых нет в нашем наборе, и пробелы
        continue;
      }

      advanceRotors();

      int val = ALL_CHARS.indexOf(char);

      val = plugboard.encodeChar(val);

      val = entry.encode(val);
      for (int j = rotors.length - 1; j >= 0; j--) {
        val = rotors[j].encode(val);
      }

      val = reflector.encode(val);

      for (Rotor r in rotors) {
        val = r.decode(val);
      }

      val = entry.decode(val);

      val = plugboard.encodeChar(val);
      out += ALL_CHARS[val];
    }

    return out;
  }

  void configureMachine({String? key, String? ring, String? refPos}) {
    if (key != null) {
      assert(key.length == rotors.length);
      for (int i = 0; i < key.length; i++) {
        rotors[i].setIndex(ALL_CHARS.indexOf(key[i]));
      }
      this.key = key;
    }

    if (ring != null) {
      assert(ring.length == rotors.length);
      for (int i = 0; i < ring.length; i++) {
        rotors[i].setRing(ALL_CHARS.indexOf(ring[i]));
      }
    }

    if (refPos != null) {
      reflector.setIndex(ALL_CHARS.indexOf(refPos[0]));
      this.refPos = refPos;
    }
  }

  void setRotor(int num, List<int> cipher, {bool step = true}) {
    if (num > rotors.length || num <= 0) {
      throw Exception("invalid rotor number");
    }

    rotors[num - 1].setMap(cipher);
    rotors[num - 1].step = step;
  }

  void setPlugs(dynamic plugs) {
    plugboard.setPlugs(plugs);
  }

  void reset() {
    configureMachine(key: key, refPos: refPos);
    for (var rotor in rotors) {
      rotor.reset();
    }
    reflector.reset();
    entry.reset();
  }
}

int charToInt(String x) {
  assert(x.length == 1);
  return x.codeUnitAt(0);
}

void main() {
  Machine enigma = Machine(rotorCount: 3, seed: 42);

  String plugs = 'AB CD EF GH IJ KL';
  String ring = 'ABC';
  String key = 'qwe';

  enigma.setPlugs(plugs);
  enigma.configureMachine(ring: ring, key: key);

  String message = 'Test test test';
  // String message = 'Один два';
  // String message = 'Hello Мир! 123 (test)';
  String encoded = enigma.encodeString(message, key: key);
  String decoded = enigma.encodeString(encoded, key: key);

  print('Original: $message');
  print('Encoded: $encoded');
  print('Decoded: $decoded');

  assert(message == decoded, 'Encoding and decoding failed');
  print('Test passed successfully!');
}

String encryptMessage({
  required String message,
  required String key,
}) {
  Machine enigma = Machine(rotorCount: 3, seed: 42);

  String plugs = 'AB CD EF GH IJ KL';
  String ring = 'ABC';

  enigma.setPlugs(plugs);
  enigma.configureMachine(ring: ring, key: key);

  String crypted = enigma.encodeString(message, key: key);

  return crypted;
}