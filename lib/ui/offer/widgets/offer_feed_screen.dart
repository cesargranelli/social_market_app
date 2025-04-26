import 'package:flutter/material.dart';
import 'package:social_market_app/ui/offer/view_models/offer_viewmodel.dart';

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
        // offers.add(offer);
        widget.viewModel.addOffer(offer);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Market")),
      body: FutureBuilder(
        future: widget.viewModel.getFeedOffers(),
        builder: (context, snapshot) {
          print(snapshot.hasData);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No offers available'));
          }
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              return OfferItem(item: snapshot.data![index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModal(),
        child: const Icon(Icons.electric_bolt_rounded),
      ),
    );
  }
}
