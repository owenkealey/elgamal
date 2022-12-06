part of elgamal;

/// The public key
class PublicKey {
  final BigInt p;
  final BigInt alpha;
  final BigInt beta;

  PublicKey({
    required this.p,
    required this.alpha,
    required this.beta,
  });

  @override
  String toString() {
    return "$p-$alpha-$beta";
  }
}
