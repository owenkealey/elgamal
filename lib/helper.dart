import 'dart:convert';
import 'dart:io';

import 'package:elgamal/core/elgamal.dart';

/// Loads a public key from disk. Parses out
/// the prime, alpha and beta.
Future<PublicKey> publicKeyWithId(String path) async {
  String rawContents = await File(path).readAsString();
  String decodedContents = String.fromCharCodes(rawContents.codeUnits);
  List<String> tokens = decodedContents.split("-");
  return PublicKey(
    p: BigInt.parse(tokens[0]),
    alpha: BigInt.parse(tokens[1]),
    beta: BigInt.parse(tokens[2]),
  );
}

/// Loads a private key from disk. Parses out
/// the 'a'
Future<PrivateKey> privateKeyWithId(String path) async {
  String rawContents = await File(path).readAsString();
  String decodedContents = String.fromCharCodes(rawContents.codeUnits);
  return PrivateKey(
    a: int.parse(decodedContents),
  );
}

/// Saves a public key to disk. Public key's contents
/// are stored in format: prime-alpha-beta
Future<void> savePublicKey(String path, PublicKey key) async {
  await File(path).writeAsString(
    key.toString(),
  );
}

/// Saves a private key to disk. Private key's format
/// is just 'a'
Future<void> savePrivateKey(String path, PrivateKey key) async {
  await File(path).writeAsString(
    key.toString(),
  );
}

/// Saves cipher text to a file on disk
Future<void> saveCipherTextToFile(String path, String cipherText) async {
  List<int> compressedUnits = GZipCodec().encode(cipherText.codeUnits);
  await File(path).writeAsBytes(compressedUnits);
}

/// Loads cipher text from a file on disk
Future<String> loadCipherTextFromFile(String path) async {
  List<int> compressedBytes = await File(path).readAsBytes();
  return String.fromCharCodes(GZipCodec().decode(compressedBytes));
}
