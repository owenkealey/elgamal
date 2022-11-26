import 'dart:convert';
import 'dart:io';
import 'package:elgamal/elgamal.dart';

/// Saves cipher text to a file on disk
void saveCipherTextToFile(String keyId, String cipherText) {
  File("out/cipher_texts/${keyId}_enc.txt").writeAsStringSync(cipherText);
}

/// Loads cipher text from a file on disk
String loadCipherTextFromFile(String keyId) {
  return File("out/cipher_texts/${keyId}_enc.txt").readAsStringSync();
}

/// Saves a public key to disk. Public key's contents
/// are stored in format: prime-alpha-beta then
/// base64 encoded
void savePublicKey(String id, PublicKey key) {
  File("out/keys/${id}_public.key").writeAsStringSync(
    base64Encode(key.toString().codeUnits),
  );
}

/// Saves a private key to disk. Private key's format
/// is just 'a' base64 encoded
void savePrivateKey(String id, PrivateKey key) {
  File("out/keys/${id}_private.key").writeAsStringSync(
    base64Encode(key.toString().codeUnits),
  );
}

/// Loads a public key from disk. Decodes the base64 and parses out
/// the prime, alpha and beta.
PublicKey publicKeyWithId(String id) {
  String rawContents = File("out/keys/${id}_public.key").readAsStringSync();
  String decodedContents = String.fromCharCodes(base64Decode(rawContents));
  List<String> tokens = decodedContents.split("-");
  return PublicKey(
    p: BigInt.parse(tokens[0]),
    alpha: int.parse(tokens[1]),
    beta: int.parse(tokens[2]),
  );
}

/// Loads a private key from disk. Decodes the base64 and parses out
/// the 'a'
PrivateKey privateKeyWithId(String id) {
  String rawContents = File("out/keys/${id}_private.key").readAsStringSync();
  String decodedContents = String.fromCharCodes(base64Decode(rawContents));
  return PrivateKey(
    a: BigInt.parse(decodedContents),
  );
}

/// Prints a menu for the user
void printMenu() {
  print("""
Menu:
  1. Generate a new key pair
  2. Encrypt using a key pair
  3. Decrypt using a key pair
  4. Quit""");
}

/// Turns a raw number the user entered into a proper
/// [Command]
Command processRawCommand(String? line) {
  if (line == null) {
    return Command.quit;
  }
  int rawCommand = int.parse(line);
  return Command.values[rawCommand - 1];
}

/// Asks the user to enter a command, and makes it into a
/// proper [Command]
Command askForCommand() {
  stdout.write("Select an option: ");
  return processRawCommand(stdin.readLineSync());
}

/// Runs a command the user entered
void runCommand(Command command, ElGamalSuite elGamal) {
  switch (command) {
    case Command.gen:
      print("Generating key pair...");
      KeyPair pair = elGamal.generateKeyPair();
      savePublicKey(pair.id, pair.publicKey);
      savePrivateKey(pair.id, pair.privateKey);
      print("Generated key pair with id: ${pair.id}!");
      break;
    case Command.encrypt:
      stdout.write("Enter a key id: ");
      String keyId = stdin.readLineSync()!;
      stdout.write("Enter a message: ");
      String message = stdin.readLineSync()!;
      PublicKey key = publicKeyWithId(keyId);
      String cipherText = elGamal.encrypt(message, key);
      saveCipherTextToFile(keyId, cipherText);
      print("Cipher text saved!");
      break;
    case Command.decrypt:
      stdout.write("Enter a key id: ");
      String keyId = stdin.readLineSync()!;
      String cipherText = loadCipherTextFromFile(keyId);
      String message = elGamal.decrypt(cipherText, privateKeyWithId(keyId));
      print(message);
      break;
    case Command.quit:
      break;
  }
}

void main(List<String> arguments) {
  ElGamalSuite elGamal = ElGamalSuite();
  print("Elgamal Cryptosystem");
  printMenu();
  Command currentCommand = askForCommand();
  while (currentCommand != Command.quit) {
    runCommand(currentCommand, elGamal);
    currentCommand = askForCommand();
  }
  print("Goodbye.");
}

/// Represents a command the user can enter
enum Command {
  gen,
  encrypt,
  decrypt,
  quit;
}
