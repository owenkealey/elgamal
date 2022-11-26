part of elgamal;

/// The private key
class PrivateKey {
  final BigInt a;

  PrivateKey({
    required this.a,
  });

  @override
  String toString() {
    return a.toString();
  }
}
