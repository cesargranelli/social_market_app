import 'package:flutter/material.dart';

class OfferPublishModal extends StatefulWidget {
  const OfferPublishModal({super.key});

  @override
  State<OfferPublishModal> createState() => _OfferPublishModalState();
}

class _OfferPublishModalState extends State<OfferPublishModal> {
  String _accountType = "AMBROSIA";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 8.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (isLoading)
                            ? null
                            : () {
                              onButtonCancelClicked();
                            },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onButtonSendClicked();
                    },
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.amber),
                    ),
                    child:
                        (isLoading)
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              "Adicionar",
                              style: TextStyle(color: Colors.black),
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 5,
              maxLength: 152,
              decoration: const InputDecoration(
                hintText: "O que você encontrou de oferta hoje?",
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                label: Text("Essa oferta é do Extra da rua X número 100?"),
              ),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                label: Text("Adicione ao menos uma foto do produto e o preço"),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tipo da conta'),
            DropdownButton<String>(
              value: _accountType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "AMBROSIA", child: Text('Ambrosia')),
                DropdownMenuItem(value: "CANJICA", child: Text('Pudim')),
                DropdownMenuItem(
                  value: "BRIGADEIRO",
                  child: Text('Brigadeiro'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _accountType = value ?? _accountType;
                });
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  onButtonCancelClicked() {
    if (!isLoading) {
      Navigator.pop(context);
    }
  }

  onButtonSendClicked() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      String name = _nameController.text;
      String lastName = _lastNameController.text;

      // Account account = Account(
      //   id: const Uuid().v1(),
      //   name: name,
      //   lastName: lastName,
      //   balance: 0,
      //   accountType: _accountType,
      // );

      // await AccountService().addAccount(account);

      closeModal();
    }
  }

  closeModal() {
    Navigator.pop(context);
  }
}
