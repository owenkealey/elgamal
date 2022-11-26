library elgamal;

import 'dart:convert';
import 'dart:math';

import 'package:english_words/english_words.dart';

part 'public_key.dart';
part 'private_key.dart';
part 'key_pair.dart';

class ElGamalSuite {
  /// Secure random number generator provided by dart:math
  Random randomNumberGenerator = Random.secure();
  ElGamalKeyGenerator keyGenerator = ElGamalKeyGenerator();

  /// Encrypts a plaintext message using a [PublicKey]
  ///
  /// Plain text is encrypted character by character by the
  /// character's UTF-16 code unit.
  /// Returns cipher text base64 encoded in the format:
  /// r|tOne,tTwo,tThree...tN
  ///
  /// Where r is α^k and tN is a hexadecimal number
  /// 't' computed as β^k * M, M being the UTF-16 code unit
  String encrypt(String message, PublicKey key) {
    // Compute 'k'
    int k = _randomSecret();
    // Compute r as α^k
    int r = pow(key.alpha, k).toInt();
    // Compute β^k
    int betaK = pow(key.beta, k).toInt();
    String cipherText = "$r|";
    // Compute each individual 't' and add it to the
    // cipher text
    for (var i = 0; i < message.codeUnits.length; i++) {
      int codeUnit = message.codeUnits[i];
      int t = betaK * codeUnit;
      String hexString = "0x${t.toRadixString(16)}";
      cipherText += hexString;
      // Only add a comma if we are not at the end
      // of the message
      if (i + 1 != message.codeUnits.length) {
        cipherText += ",";
      }
    }
    String cipherTextEncoded = base64Encode(cipherText.codeUnits);
    return cipherTextEncoded;
  }

  /// Decrypts a cipher text using a [PrivateKey]
  ///
  /// Cipher text is first base64 decoded.
  /// The first part of the text is the 'r' and the last part
  /// is the sequence of tN.
  String decrypt(String cipherText, PrivateKey privateKey) {
    String decodedCipherText = String.fromCharCodes(base64Decode(cipherText));
    List<String> parts = decodedCipherText.split("|");
    BigInt r = BigInt.parse(parts.first);
    // Compute r^-a.
    double rExp = 1 / r.pow(privateKey.a.toInt()).toInt();
    List<String> rawEncryptedCodeUnits = parts.last.split(",");
    List<int> decryptedCodeUnits = [];
    // Loop over every encrypted 't' and decrypt it. Add the
    // decrypted result to decryptedCodeUnits
    for (var rawEncryptedCodeUnit in rawEncryptedCodeUnits) {
      int encryptedCodeUnit = int.parse(rawEncryptedCodeUnit);
      int decryptedCodeUnit = (encryptedCodeUnit * rExp).round();
      decryptedCodeUnits.add(decryptedCodeUnit);
    }
    return String.fromCharCodes(decryptedCodeUnits);
  }

  /// Generates a key pair, with public and private key
  KeyPair generateKeyPair() {
    // Generate a pair of random words in the Engligh language
    // for the id of this key pair. Easier to memorize than
    // random letters or numbers. generateWordPairs provided by
    // the english_words package
    String id = generateWordPairs().take(1).first.asSnakeCase;
    // Generate a random 'a'
    int a = _randomSecret();
    PublicKey publicKey = keyGenerator.generatePublicKey(a);
    PrivateKey privateKey = keyGenerator.generatePrivateKey(BigInt.from(a));
    KeyPair pair = KeyPair(
      id: id,
      privateKey: privateKey,
      publicKey: publicKey,
    );
    return pair;
  }

  /// Return a random number from 1-50
  int _randomSecret() {
    return randomNumberGenerator.nextInt(50) + 1;
  }
}

/// Responsible for generating valid public and private keys
class ElGamalKeyGenerator {
  /// Secure random number generator provided by dart:math
  Random randomNumberGenerator = Random.secure();

  /// Generates a public key.
  /// Computes a large prime, α and β and formalizes them into a
  /// [PublicKey]
  PublicKey generatePublicKey(int a) {
    BigInt prime = _generatePrimeNumber();
    int alpha = _getPrimitiveRoot(prime);
    int beta = pow(alpha, a).toInt();
    return PublicKey(
      p: prime,
      alpha: alpha,
      beta: beta,
    );
  }

  /// Generates a private key.
  /// Computes a random 'a' and formalizes it into a
  /// [PrivateKey]
  PrivateKey generatePrivateKey(BigInt a) {
    return PrivateKey(
      a: a,
    );
  }

  /// Finds the first (and also smallest) primitive root in
  /// ℤp. Checks every number i and returns it (signifying it is a root)
  /// if i^(p-1)/2 = p - 1
  int _getPrimitiveRoot(BigInt p) {
    // Convert the normal int '2' to a BigInt since
    // we can only do calculations on BigInts with other BigInts
    BigInt two = BigInt.from(2);
    BigInt pMinusOne = (p - BigInt.one);
    BigInt exp = pMinusOne ~/ two;
    for (var i = 0; i < double.maxFinite; i++) {
      BigInt result = BigInt.from(i).modPow(exp, p);
      if (result == pMinusOne) {
        return i;
      }
    }
    return 0;
  }

  /// Generates a large number with arbitrary length
  /// This generates length random numbers and concatenates
  /// them into a String, then gives it to BigInt to convert into
  /// a number
  BigInt _generateLargeNumber(int length) {
    List<int> randomNumbers = [];
    for (var _ = 0; _ < length; _++) {
      int randomInt = randomNumberGenerator.nextInt(9);
      randomNumbers.add(randomInt);
    }
    BigInt largeNumber = BigInt.parse(randomNumbers.join());
    return largeNumber;
  }

  /// Miller Rabin Primality test
  /// Explained inline
  bool _millerRabinSaysPrime(BigInt m, BigInt n, int k) {
    BigInt two = BigInt.from(2);
    int rawA = randomNumberGenerator.nextInt(20) + 2;
    BigInt a = BigInt.from(rawA);
    // b = a^m mod n
    BigInt b = a.modPow(m, n);
    if (b == BigInt.one || b == n - BigInt.one) {
      return true;
    }
    // Compute b k times
    for (var _ = 0; _ < k; _++) {
      // If bn = 1
      if (b == BigInt.one) {
        // b is 1 so not prime
        return false;
        // If bn = p - 1
      } else if (b == n - BigInt.one) {
        // b is n - 1, so it is probably prime
        return true;
      }
      // b = b^2 mod n
      b = b.modPow(two, n);
    }
    return b == (n - BigInt.one);
  }

  /// Primality test
  /// Explained inline
  bool _isNumberPrime(BigInt candidate) {
    BigInt two = BigInt.from(2);
    // Easy edge cases
    if (candidate == two) {
      return true;
    }
    if (candidate % two == BigInt.zero) {
      return false;
    }
    BigInt nMinusOne = candidate - BigInt.one;
    int k = 1;
    BigInt m = BigInt.one;
    // Compute n - 1 = 2^km
    // Try every k until m is odd
    while (true) {
      BigInt twoToThek = two.pow(k);
      m = nMinusOne ~/ twoToThek;
      BigInt remainder = nMinusOne.remainder(twoToThek);
      if (remainder != BigInt.zero || m % BigInt.two == BigInt.zero) {
        k += 1;
      } else {
        break;
      }
    }
    // Run 40 iterations of Miller Rabin. All must pass.
    for (var _ = 0; _ < 40; _++) {
      if (!_millerRabinSaysPrime(m, candidate, k)) {
        return false;
      }
    }
    return true;
  }

  /// Generates a 200 digit prime number.
  /// Generates a large number and keeps generating until the
  /// number it got is prime.
  BigInt _generatePrimeNumber() {
    BigInt largeNumber = _generateLargeNumber(200);
    while (!_isNumberPrime(largeNumber)) {
      largeNumber = _generateLargeNumber(200);
    }
    return largeNumber;
  }
}
