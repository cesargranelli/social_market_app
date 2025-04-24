import 'package:flutter/material.dart';
import 'package:social_market_app/domain/models/feed/feed_offer.dart';
import 'package:social_market_app/ui/offer/offer_publish_modal.dart';

import '../../../data/repositories/offers/offers_mock.dart';
import '../../../ui/feed/widgets/feed_offer_item.dart';

class FeedOfferTimelineScreen extends StatefulWidget {
  const FeedOfferTimelineScreen({super.key});

  @override
  State<FeedOfferTimelineScreen> createState() =>
      _FeedOfferTimelineScreenState();
}

class _FeedOfferTimelineScreenState extends State<FeedOfferTimelineScreen> {
  void _updateList(FeedOffer offer) {
    setState(() {
      offers.add(offer);
    });
  }

  void _showModal() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return OfferPublishModal(onOfferAdded: _updateList);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Market")),
      body: ListView.separated(
        itemCount: offers.length,
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          return FeedOfferItem(item: offers[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModal(),
        child: const Icon(Icons.electric_bolt_rounded),
      ),
    );
  }
}
