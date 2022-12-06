import 'package:elgamal/core/elgamal.dart';
import 'package:elgamal/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const ElGamalFrontEnd());
}

class ElGamalFrontEnd extends StatelessWidget {
  const ElGamalFrontEnd({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: "Flutter Demo",
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  final ElGamalSuite elGamalSuite = ElGamalSuite();
  final TextEditingController encryptController = TextEditingController();
  _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  PublicKey? publicKey;
  PrivateKey? privateKey;
  String? cipherText;

  void _showDialog(String title, String subtitle) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(subtitle),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSelectPublicKey() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick a public key",
    );
    if (result != null) {
      publicKey = await publicKeyWithId(result.paths.first!);
      _showDialog("Success", "Public key selected");
    }
  }

  Future<void> _onSelectPrivateKey() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick the private key",
    );
    if (result != null) {
      privateKey = await privateKeyWithId(result.paths.first!);
      _showDialog("Success", "Private key selected");
    }
  }

  Future<void> _onTappedEncrypt() async {
    String cipherText = widget.elGamalSuite.encrypt(
      widget.encryptController.text,
      publicKey!,
    );
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: "Save cipher text",
      fileName: "my_cipher_text.bin",
    );
    saveCipherTextToFile(path!, cipherText);
    _showDialog("Success", "Cipher text saved");
  }

  Future<void> _onTappedCipherText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick the cipher text file",
    );
    if (result != null) {
      cipherText = await loadCipherTextFromFile(result.paths.first!);
      _showDialog("Success", "Cipher text loaded");
    }
  }

  Future<void> _onTappedDecrypt() async {
    String plainText = widget.elGamalSuite.decrypt(
      cipherText!,
      privateKey!,
    );
    _showDialog("Result", plainText);
  }

  Future<void> _onTappedGenerate() async {
    KeyPair pair = widget.elGamalSuite.generateKeyPair();
    String? publicPath = await FilePicker.platform.saveFile(
      dialogTitle: "Save public key",
      fileName: "${pair.id}_public.elgamalkey",
    );
    await savePublicKey(publicPath!, pair.publicKey);
    String? privatePath = await FilePicker.platform.saveFile(
      dialogTitle: "Save private key",
      fileName: "${pair.id}_private.elgamalkey",
    );
    await savePrivateKey(privatePath!, pair.privateKey);
    _showDialog("Success", "Key pair saved");
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xff1f1f1f),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Encrypt",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        "Enter text to encrypt",
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      CupertinoTextField(
                        controller: widget.encryptController,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      CupertinoButton(
                        onPressed: _onSelectPublicKey,
                        child: const Text("Select public key"),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CupertinoButton.filled(
                        onPressed: _onTappedEncrypt,
                        child: const Text(
                          "Encrypt",
                          style: TextStyle(
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        "or",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CupertinoButton.filled(
                        onPressed: _onTappedGenerate,
                        child: const Text(
                          "Generate Key Pair",
                          style: TextStyle(
                            color: CupertinoColors.white,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Decrypt",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CupertinoButton(
                        onPressed: _onSelectPrivateKey,
                        child: const Text("Select private key"),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      CupertinoButton(
                        onPressed: _onTappedCipherText,
                        child: const Text("Select cipher text"),
                      ),
                    ],
                  ),
                  CupertinoButton.filled(
                    onPressed: _onTappedDecrypt,
                    child: const Text(
                      "Decrypt",
                      style: TextStyle(
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
