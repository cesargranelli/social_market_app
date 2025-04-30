import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/offer/offer.dart';
import 'offer_image_picker.dart';

class OfferPublishModal extends StatefulWidget {
  const OfferPublishModal({super.key});

  @override
  State<OfferPublishModal> createState() => _OfferPublishModalState();
}

class _OfferPublishModalState extends State<OfferPublishModal> {
  final TextEditingController _textController = TextEditingController();

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
                FloatingActionButton(
                  onPressed:
                      (isLoading)
                          ? null
                          : () {
                            onButtonCancel();
                          },
                  child: const Icon(Icons.close, color: Colors.black),
                ),
                FloatingActionButton(
                  onPressed: () {
                    onButtonPublish();
                  },
                  child:
                      (isLoading)
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.upload, color: Colors.black),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const OfferImagePicker(
                              title: "Escolha uma imagem",
                            ),
                      ),
                    );
                  },
                  backgroundColor: Colors.amberAccent,
                  child: const Icon(Icons.photo, color: Colors.black),
                ),
                // FloatingActionButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const OfferTakePicture(),
                //       ),
                //     );
                //   },
                //   backgroundColor: Colors.amberAccent,
                //   child: const Icon(Icons.camera_alt, color: Colors.black),
                // ),
              ],
            ),
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

      Offer offer = Offer(
        id: const Uuid().v4(),
        username: "_nameController.text",
        userHandle: '@UserHandle',
        profileImageUrl:
            "https://picsum.photos/500/300?random=${Random().nextInt(10)}",
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

      Navigator.pop(context, offer);
    }
  }
}
