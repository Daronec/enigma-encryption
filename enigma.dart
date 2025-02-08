//
// class Enigma {
//   final List<String> alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя.,? '.split('');
//   final String key;
//   List<int> rotors = [];
//
//   Enigma(this.key) {
//     // Инициализация роторов на основе ключа
//     initRotors();
//   }
//
//   void initRotors() {
//     // Создаем три ротора на основе ключа
//     var keyHash = 0;
//     for (var char in key.codeUnits) {
//       keyHash += char;
//     }
//
//     rotors = List.generate(3, (index) {
//       return (keyHash * (index + 1)) % alphabet.length;
//     });
//   }
//
//   void rotateRotors() {
//     rotors[0] = (rotors[0] + 1) % alphabet.length;
//     if (rotors[0] == 0) {
//       rotors[1] = (rotors[1] + 1) % alphabet.length;
//       if (rotors[1] == 0) {
//         rotors[2] = (rotors[2] + 1) % alphabet.length;
//       }
//     }
//   }
//
//   String encrypt(String text) {
//     var result = StringBuffer();
//
//     for (var char in text.split('')) {
//       if (alphabet.contains(char)) {
//         var charIndex = alphabet.indexOf(char);
//
//         // Применяем преобразование через роторы
//         var encoded = charIndex;
//         for (var rotor in rotors) {
//           encoded = (encoded + rotor) % alphabet.length;
//         }
//
//         result.write(alphabet[encoded]);
//         rotateRotors();
//       } else {
//         result.write(char);
//       }
//     }
//
//     return result.toString();
//   }
//
//   String decrypt(String text) {
//     // Сбрасываем роторы в начальное положение
//     initRotors();
//     var result = StringBuffer();
//
//     for (var char in text.split('')) {
//       if (alphabet.contains(char)) {
//         var charIndex = alphabet.indexOf(char);
//
//         // Применяем обратное преобразование через роторы
//         var decoded = charIndex;
//         for (var rotor in rotors.reversed) {
//           decoded = (decoded - rotor + alphabet.length) % alphabet.length;
//         }
//
//         result.write(alphabet[decoded]);
//         rotateRotors();
//       } else {
//         result.write(char);
//       }
//     }
//
//     return result.toString();
//   }
// }
//
//
// /*
// void main() {
//   String key = "ABC";  // Ключ шифрования
//   Enigma enigma = Enigma(key);
//   String plaintext = "HELLO WORLD";
//   String encrypted = enigma.encrypt(plaintext);
//   print("Ключ: $key");
//   print("Исходный текст: $plaintext");
//   print("Зашифрованный текст: $encrypted");
//
//   // Проверка расшифровки
//   Enigma enigma2 = Enigma(key);
//   String decrypted = enigma2.encrypt(encrypted);
//   print("Расшифрованный текст: $decrypted");
// }
//
// class Enigma {
//   late List<List<String>> rotors;
//   late List<String> reflector;
//   late List<int> shifts;
//   late List<int> ringSettings;
//   final String alphabet =
//       'ABCDEFGHIJKLMNOPQRSTUVWXYZАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ';
//
//   Enigma(String key) {
//     if (key.length != 12) {
//       throw ArgumentError('Ключ должен состоять из 12 символов');
//     }
//
//     rotors = [
//       'EKMFLGDQVZNTOWYHXUSPAIBRCJАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'.split(''),
//       'AJDKSIRUXBLHWTMCQGZNPYFVOEАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'.split(''),
//       'BDFHJLCPRTXVZNYEIWGAKMUSQOАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'.split(''),
//       'ESOVPZJAYQUIRHXLNFTGKDCMWBАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'.split(''),
//       'VZBRGITYUPSDNHLXAWMJQOFECKАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'.split(''),
//       'JPGVOUMFYQBENHZRDKASXLICTWАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'.split(''),
//     ];
//     reflector =
//         'YRUHQSLDPXNGOKMIEBFZCWVJATАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'.split('');
//
//     setRotorPositions(key.substring(0, 6));
//     setRingSettings(key.substring(6));
//   }
//
//   void setRotorPositions(String positions) {
//     shifts = positions
//         .split('')
//         .map((char) => alphabet.indexOf(char.toUpperCase()))
//         .toList();
//     for (int i = 0; i < 6; i++) {
//       rotors[i] = [
//         ...rotors[i].sublist(shifts[i]),
//         ...rotors[i].sublist(0, shifts[i])
//       ];
//     }
//   }
//
//   void setRingSettings(String settings) {
//     ringSettings = settings
//         .split('')
//         .map((char) => alphabet.indexOf(char.toUpperCase()))
//         .toList();
//     print(ringSettings);
//   }
//
//   int applyRingSetting(int index, int setting) {
//     return (index - setting + alphabet.length) % alphabet.length;
//   }
//
//   String encrypt(String plaintext) {
//     String ciphertext = '';
//     List<int> rotations = [0, 0, 0, 0, 0, 0];
//
//     for (int i = 0; i < plaintext.length; i++) {
//       String char = plaintext[i];
//       bool isLowerCase = char.toLowerCase() == char;
//       char = char.toUpperCase();
//
//       if (alphabet.contains(char)) {
//         int index = alphabet.indexOf(char);
//
//         // Применяем настройки колец и проходим через роторы
//         for (int j = 0; j < 6; j++) {
//           index = applyRingSetting(index, ringSettings[j]);
//           index = alphabet.indexOf(rotors[j][index]);
//         }
//
//         // Отражаем
//         index = alphabet.indexOf(reflector[index]);
//
//         // Обратный проход через роторы
//         for (int j = 5; j >= 0; j--) {
//           index = rotors[j].indexOf(alphabet[index]);
//           index = applyRingSetting(index, -ringSettings[j]);
//         }
//
//         char = alphabet[index];
//
//         // Восстанавливаем исходный регистр
//         if (isLowerCase) {
//           char = char.toLowerCase();
//         }
//
//         // Вращаем роторы
//         rotations[0]++;
//         for (int j = 0; j < 5; j++) {
//           if (rotations[j] == alphabet.length) {
//             rotations[j] = 0;
//             rotations[j + 1]++;
//           } else {
//             break;
//           }
//         }
//         for (int j = 0; j < 6; j++) {
//           rotors[j] = [...rotors[j].sublist(1), rotors[j][0]];
//         }
//       }
//       ciphertext += char;
//     }
//     return ciphertext;
//   }
// }
//  */
