part of elgamal;

/// The public key
class PublicKey {
  final BigInt p;
  final int alpha;
  final int beta;

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
