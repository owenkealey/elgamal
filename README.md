# Overview
There are two parts to this program:
    1. The CLI front end
    2. The ElGamal backend

1.  The CLI front end
    Can be found in bin/elgamal.dart. This part of the program asks the user
    for input, sanitizes it, and then uses the ElGamal backend to actually
    do something useful (in this case, encrypt, decrypt, gen key).

    This part also saves keys and encrypted cipher text to disk. Keys and cipher texts are stored in the out/ folder. Keys under out/keys and ciper text under out/cipher_texts.

2.  The ElGamal back end
    Can be found in lib/elgamal.dart. This implements the ElGamal cryptosystem including encrypting, decrypting and key generation.

# Functions
Key Generation:

    To generate a key, run the program and select '1'. The back end will generate a key pair with a random id and save it to out/keys/key_id.key
    Keys are base64 encoded.

Encryption:

    To encrypt a message, select '2' on the Menu screen. You will be asked for your key id. Input your key id from the previous step. The front end will look in out/keys for a key pair matching this id and load it.
    You will then be asked for plain text. Enter plain text, hit 'Enter' and the result will be stored, base64 encoded, in out/cipher_texts

Decryption:

    To decrypt a message, select '3' on the Menu Screen. You will be asked only for your key id. The front end will look in out/cipher_texts for encrypted cipher text matching that key. Note that only ONE block of cipher text per key is stored at any time i.e encrypting new text with the a key will overwrite any old cipher text generated with the same key.
    The program will decrypt and print out the plaintext.

Quit:

    Enter '4'

# How To Run
This program is made entirely in Dart. You should follow instructions 
here: https://dart.dev/get-dart to install Dart. 

Run the program with 'dart run' from this directory.

# Helpful Notes
The pow function does exponentiation. So a.pow(5) == "a-to-the-fifth"

The modPow function does modular exponentiation. So a.modPow(5, 3) == "a-to-the-fifth mod 3 "