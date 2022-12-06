# Overview
There are two parts to this program:
    1. The UI front end
    2. The ElGamal backend

1.  The UI front end
    Can be found in lib/main.dart. This part of the program asks the user
    for input, sanitizes it, and then uses the ElGamal backend to actually
    do something useful (in this case, encrypt, decrypt, gen key).

    This part also saves keys and encrypted cipher text to disk. This part of the program does not implement elgamal. Just UI.

2.  The ElGamal back end
    Can be found in lib/core/elgamal.dart. This implements the ElGamal cryptosystem including encrypting, decrypting and key generation.

# Helpful Notes
The pow function does exponentiation. So a.pow(5) == "a-to-the-fifth"

The modPow function does modular exponentiation. So a.modPow(5, 3) == "a-to-the-fifth mod 3 "

All code is in the lib/ folder. All other folders/files are machinations of Flutter (The UI framework used to make this app)