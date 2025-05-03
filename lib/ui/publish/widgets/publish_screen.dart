import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/offer/offer.dart';
import '../view_models/publish_viewmodel.dart';

class PublishScreen extends StatefulWidget {
  final PublishViewModel viewModel;

  const PublishScreen({super.key, required this.viewModel});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();

  bool isLoading = false;

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compartilhe uma oferta"),
        backgroundColor: Colors.amberAccent,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
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
                    onPressed:
                        (_textController.text.isEmpty || _selectedImage == null)
                            ? null
                            : () {
                              onButtonPublish();
                            },
                    backgroundColor:
                        (_textController.text.isEmpty || _selectedImage == null)
                            ? Colors.amberAccent
                            : Colors.grey[200],
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
                textInputAction: TextInputAction.newline,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_selectedImage != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    onPressed: () => _pickImageFromGallery(),
                    backgroundColor:
                        (_selectedImage == null)
                            ? Colors.amberAccent
                            : Colors.grey[200],
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
      ),
    );
  }

  onButtonCancel() {
    if (!isLoading) {
      context.pop(context);
    }
  }

  onButtonPublish() {
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
        images: [_selectedImage],
        createdAt: DateTime.now(),
      );

      widget.viewModel.addOffer(offer);
      setState(() {
        isLoading = false;
      });

      context.pop(context);
    }
  }
}
