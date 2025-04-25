import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/offer/offer.dart';

class OfferPublishModal extends StatefulWidget {
  const OfferPublishModal({super.key});

  @override
  State<OfferPublishModal> createState() => _OfferPublishModalState();
}

class _OfferPublishModalState extends State<OfferPublishModal> {
  // String _categoryType = "CARNES";

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _lastNameController = TextEditingController();
  // final TextEditingController _categoryController = TextEditingController();

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed:
                      (isLoading)
                          ? null
                          : () {
                            onButtonCancel();
                          },
                  style: const ButtonStyle(
                    shape: WidgetStatePropertyAll(CircleBorder()),
                  ),
                  child: const Icon(Icons.close, color: Colors.black),
                ),
                ElevatedButton(
                  onPressed: () {
                    onButtonPublish();
                  },
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.amberAccent),
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
                            "Publicar",
                            style: TextStyle(color: Colors.black),
                          ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _textController,
              maxLines: 5,
              maxLength: 152,
              decoration: const InputDecoration(
                hintText: "O que você encontrou de oferta hoje?",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            // Chip(
            //   avatar: CircleAvatar(
            //     backgroundColor: Colors.grey.shade800,
            //     child: const Text('AB'),
            //   ),
            //   label: const Text('Aaron Burr'),
            // ),
            // const SizedBox(height: 16),
            // TextFormField(
            //   controller: _nameController,
            //   decoration: const InputDecoration(
            //     label: Text("Essa oferta é do Extra da rua X número 100?"),
            //   ),
            // ),
            // TextFormField(
            //   controller: _lastNameController,
            //   decoration: const InputDecoration(
            //     label: Text("Adicione ao menos uma foto do produto e o preço"),
            //   ),
            // ),
            // const SizedBox(height: 16),
            // const Text('Categoria'),
            // DropdownButton<String>(
            //   value: _categoryType,
            //   isExpanded: true,
            //   items: const [
            //     DropdownMenuItem(value: "AMBROSIA", child: Text('Ambrosia')),
            //     DropdownMenuItem(value: "CANJICA", child: Text('Pudim')),
            //     DropdownMenuItem(
            //       value: "BRIGADEIRO",
            //       child: Text('Brigadeiro'),
            //     ),
            //   ],
            //   onChanged: (value) {
            //     setState(() {
            //       _categoryType = value ?? _categoryType;
            //     });
            //   },
            // ),
            // const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  onButtonCancel() {
    if (!isLoading) {
      Navigator.pop(context);
    }
  }

  onButtonPublish() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      Offer feedOffer = Offer(
        id: const Uuid().v1(),
        username: _nameController.text,
        userHandle: 'userHandle',
        profileImageUrl: 'profileImageUrl',
        text: _textController.text,
        images: [
          "https://picsum.photos/500/300?random=${Random().nextInt(10)}",
        ],
        createdAt: DateTime.now(),
        category: 'categoria',
        store: 'mercado',
        address: 'local',
        likes: 0,
        retweets: 0,
        comments: 0,
        truth: 0,
        bought: 0,
      );

      Navigator.pop(context, feedOffer);
    }
  }
}
