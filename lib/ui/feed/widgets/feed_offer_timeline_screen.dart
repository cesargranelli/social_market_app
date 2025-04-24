import 'package:flutter/material.dart';
import 'package:social_market_app/domain/models/feed/feed_offer.dart';
// import 'package:social_market_app/ui/feed/view_models/feed_offer_timeline_viewmodel.dart';
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
  Future<List<FeedOffer>> _feedOfferGetAll =
      FeedOfferMockRepository().getAllOffers();

  Future<List<FeedOffer>> refreshGetAll() async {
    setState(() {
      _feedOfferGetAll = FeedOfferMockRepository().getAllOffers();
    });
    return _feedOfferGetAll;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Market")),
      body: RefreshIndicator(
        onRefresh: refreshGetAll,
        child: FutureBuilder(
          future: refreshGetAll(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                {
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nenhuma conta recebida."));
                  } else {
                    List<FeedOffer> listFeedOffer = snapshot.data!;
                    return ListView.separated(
                      itemCount: listFeedOffer.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 0),
                      itemBuilder: (context, index) {
                        print(listFeedOffer.length);
                        return FeedOfferItem(item: listFeedOffer[index]);
                      },
                    );
                  }
                }
            }
          },
        ),
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
