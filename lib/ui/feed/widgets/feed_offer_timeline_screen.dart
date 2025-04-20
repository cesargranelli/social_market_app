import 'package:flutter/material.dart';
import 'package:social_market_app/ui/offer/offer_publish_modal.dart';

import '../../../data/repositories/offers/offers_mock.dartoffers_mock.dart';
import '../../../ui/feed/widgets/feed_offer_item.dart';

class FeedOfferTimelineScreen extends StatelessWidget {
  const FeedOfferTimelineScreen({super.key});

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
        onPressed:
            () => {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                isScrollControlled: true,
                context: context,
                builder: (context) => const OfferPublishModal(),
              ),
            },
        // child: const Icon(Icons.switch_access_shortcut), // oferta com desconto
        // child: const Icon(Icons.local_fire_department), // oferta em destaque
        child: const Icon(Icons.electric_bolt_rounded), // oferta
      ),
    );
  }
}
