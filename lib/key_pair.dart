part of elgamal;

class KeyPair {
  final String id;
  final PrivateKey privateKey;
  final PublicKey publicKey;

  KeyPair({
    required this.id,
    required this.privateKey,
    required this.publicKey,
  });
}
