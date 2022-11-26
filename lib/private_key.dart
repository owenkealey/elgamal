part of elgamal;

/// The private key
class PrivateKey {
  final int a;

  PrivateKey({
    required this.a,
  });

  @override
  String toString() {
    return a.toString();
  }
}
