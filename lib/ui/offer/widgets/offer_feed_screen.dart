import 'package:flutter/material.dart';
import 'package:social_market_app/ui/offer/view_models/offer_viewmodel.dart';

import '../../../data/repositories/offers/offers_mock.dart';
import '../../../domain/models/offer/offer.dart';
import 'offer_item.dart';
import 'offer_publish_modal.dart';

class OfferFeedScreen extends StatefulWidget {
  const OfferFeedScreen({super.key, required this.viewModel});

  final OfferViewModel viewModel;

  @override
  State<OfferFeedScreen> createState() => _OfferFeedScreenState();
}

class _OfferFeedScreenState extends State<OfferFeedScreen> {
  Future<void> _showModal() async {
    final offer = await showModalBottomSheet<Offer>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return const OfferPublishModal();
      },
    );

    if (offer != null) {
      setState(() {
        offers.add(offer);
        widget.viewModel.addOffer(offer);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Market")),
      body: ListView.separated(
        itemCount: offers.length,
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          return OfferItem(item: offers[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModal(),
        child: const Icon(Icons.electric_bolt_rounded),
      ),
    );
  }
}
