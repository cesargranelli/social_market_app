import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'helpers/fake_repositories.dart';
import 'package:social_market_app/core/services/location_service.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/offers/presentation/new_offer_screen.dart';
import 'package:social_market_app/features/offers/presentation/offer_detail_screen.dart';
import 'package:social_market_app/features/stores/domain/store_model.dart';

/// Localização "real" dos fixtures: Praça da Sé -> Guarulhos (~14,75 km),
/// renderizada como '14,8 km' (haversine = 14,7504 -> arredonda p/ 1 casa).
const GeoPoint kSaoPauloGeo = GeoPoint(-23.5505, -46.6333);
const GeoPoint kGuarulhosGeo = GeoPoint(-23.4543, -46.5337);

const StoreModel kSeedGeoStore = StoreModel(
  id: 'store-1',
  name: 'Bom Preço',
  city: 'Campinas',
  neighborhood: 'Centro',
  createdBy: 'seed-user',
  geoPoint: kGuarulhosGeo,
);

Position positionOf(GeoPoint geo) => Position(
  latitude: geo.latitude,
  longitude: geo.longitude,
  timestamp: DateTime.fromMillisecondsSinceEpoch(0),
  accuracy: 10,
  altitude: 700,
  altitudeAccuracy: 5,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

/// LocationService falso injetável: devolve posição fixa (ou null p/
/// simular permissão negada/serviço desligado) e conta chamadas.
class FakeLocationService implements LocationService {
  FakeLocationService(this.position);

  Position? position;
  int calls = 0;

  @override
  Future<Position?> getCurrentPosition() async {
    calls++;
    return position;
  }
}

/// Bombeia frames discretos (evita pumpAndSettle com SnackBars/spinners).
Future<void> _pumpFrames(WidgetTester tester, [int frames = 2]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  /// Harness com o [FakeLocationService] injetado no MESMO ProviderScope
  /// (no Riverpod 3, override de escopo externo vence o interno — nunca
  /// aninhar scopes para injetar dependências nos testes).
  Future<(Phase3TestHarness, FakeLocationService)> pumpNewOffer(
    WidgetTester tester,
    Position? fakePosition,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final FakeLocationService fake = FakeLocationService(fakePosition);
    final Phase3TestHarness harness = Phase3TestHarness(locationService: fake);
    await tester.pumpWidget(
      harness.buildTestApp(
        home: const Scaffold(
          body: SingleChildScrollView(child: NewOfferScreen()),
        ),
      ),
    );
    await tester.pump();
    return (harness, fake);
  }

  group('_CreateStoreDialog — captura de localização', () {
    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(
        find.byKey(const Key('new_offer_open_create_store_button')),
      );
      await _pumpFrames(tester);
    }

    testWidgets('sucesso: botão muda para "capturada" e store é salva com geoPoint', (
      tester,
    ) async {
      final (Phase3TestHarness harness, FakeLocationService fake) =
          await pumpNewOffer(tester, positionOf(kSaoPauloGeo));

      await openDialog(tester);
      final int callsBeforeTap = fake.calls;

      await tester.tap(
        find.byKey(const Key('create_store_use_location_button')),
      );
      await _pumpFrames(tester, 4);

      // Serviço consultado; feedback verde e botão no estado capturado.
      expect(fake.calls, greaterThan(callsBeforeTap));
      expect(find.text('Localização capturada!'), findsOneWidget);
      expect(find.text('Localização capturada'), findsOneWidget);
      expect(find.text('Usar minha localização'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Cadastro segue normal e persiste o geoPoint capturado.
      await tester.enterText(
        find.byKey(const Key('create_store_name_field')),
        'Mercado Novo',
      );
      await tester.enterText(
        find.byKey(const Key('create_store_city_field')),
        'Campinas',
      );
      await tester.tap(find.byKey(const Key('create_store_save_button')));
      // Frames suficientes para createStore + saída completa do diálogo.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(harness.storesRepository.createdStores, hasLength(1));
      final StoreModel saved = harness.storesRepository.createdStores.first;
      expect(saved.geoPoint, isNotNull);
      expect(saved.geoPoint!.latitude, kSaoPauloGeo.latitude);
      expect(saved.geoPoint!.longitude, kSaoPauloGeo.longitude);

      // Drena os timers dos dois SnackBars em fila.
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets(
      'sem permissão (null): SnackBar amigável, botão intacto e '
      'cadastro segue funcional sem geoPoint',
      (tester) async {
        final (Phase3TestHarness harness, _) = await pumpNewOffer(tester, null);

        await openDialog(tester);
        await tester.tap(
          find.byKey(const Key('create_store_use_location_button')),
        );
        await _pumpFrames(tester, 4);

        expect(
          find.text('Não foi possível obter sua localização.'),
          findsOneWidget,
        );
        // Estado do botão permanece "não capturado".
        expect(find.text('Usar minha localização'), findsOneWidget);
        expect(find.text('Localização capturada'), findsNothing);
        expect(find.byIcon(Icons.my_location), findsOneWidget);

        // Fluxo de cadastro não foi bloqueado.
        await tester.enterText(
          find.byKey(const Key('create_store_name_field')),
          'Mercado Sem Geo',
        );
        await tester.enterText(
          find.byKey(const Key('create_store_city_field')),
          'Campinas',
        );
        await tester.tap(find.byKey(const Key('create_store_save_button')));
        // Saída completa do diálogo antes de afirmar sobre a árvore.
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));

        expect(harness.storesRepository.createdStores, hasLength(1));
        expect(harness.storesRepository.createdStores.first.name, 'Mercado Sem Geo');
        expect(harness.storesRepository.createdStores.first.geoPoint, isNull);
        expect(find.text('Mercado Sem Geo'), findsOneWidget);

        await tester.pump(const Duration(seconds: 10));
      },
    );
  });

  group('Resultados de busca — distância', () {
    Future<void> searchStore(WidgetTester tester) async {
      await tester.enterText(
        find.byKey(const Key('new_offer_city_field')),
        'Campinas',
      );
      await tester.enterText(
        find.byKey(const Key('new_offer_store_search_field')),
        'bom',
      );
      await tester.tap(
        find.byKey(const Key('new_offer_search_stores_button')),
      );
      await _pumpFrames(tester);
    }

    testWidgets(
      'exibe "· X,X km" quando há posição do usuário e store tem geoPoint',
      (tester) async {
        final Phase3TestHarness harness = Phase3TestHarness(
          seedStores: <StoreModel>[kSeedGeoStore],
          locationService: FakeLocationService(positionOf(kSaoPauloGeo)),
        );
        await tester.binding.setSurfaceSize(const Size(1200, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          harness.buildTestApp(
            home: const Scaffold(
              body: SingleChildScrollView(child: NewOfferScreen()),
            ),
          ),
        );
        await tester.pump();

        await searchStore(tester);

        expect(find.text('Bom Preço'), findsOneWidget);
        expect(find.text('· 14,8 km'), findsOneWidget);

        // Seleção continua funcionando normalmente.
        await tester.tap(find.text('Bom Preço'));
        await tester.pump();
        expect(find.text('Centro • Campinas'), findsOneWidget);
      },
    );

    testWidgets(
      'sem posição disponível: resultado listado SEM distância e fluxo intacto',
      (tester) async {
        final Phase3TestHarness harness = Phase3TestHarness(
          seedStores: <StoreModel>[kSeedGeoStore],
          locationService: FakeLocationService(null),
        );
        await tester.binding.setSurfaceSize(const Size(1200, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          harness.buildTestApp(
            home: const Scaffold(
              body: SingleChildScrollView(child: NewOfferScreen()),
            ),
          ),
        );
        await tester.pump();

        await searchStore(tester);

        expect(find.text('Bom Preço'), findsOneWidget);
        expect(find.textContaining('km'), findsNothing);

        await tester.tap(find.text('Bom Preço'));
        await tester.pump();
        expect(find.text('Centro • Campinas'), findsOneWidget);
      },
    );

    testWidgets(
      'store sem geoPoint: resultado listado SEM distância mesmo com posição',
      (tester) async {
        const StoreModel semGeo = StoreModel(
          id: 'store-2',
          name: 'Bom Preço',
          city: 'Campinas',
          neighborhood: 'Centro',
          createdBy: 'seed-user',
        );
        final Phase3TestHarness harness = Phase3TestHarness(
          seedStores: <StoreModel>[semGeo],
          locationService: FakeLocationService(positionOf(kSaoPauloGeo)),
        );
        await tester.binding.setSurfaceSize(const Size(1200, 2400));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          harness.buildTestApp(
            home: const Scaffold(
              body: SingleChildScrollView(child: NewOfferScreen()),
            ),
          ),
        );
        await tester.pump();

        await searchStore(tester);

        expect(find.text('Bom Preço'), findsOneWidget);
        expect(find.textContaining('km'), findsNothing);
      },
    );
  });

  group('OfferDetailScreen — linha de distância', () {
    OfferModel offer({required String storeId}) => OfferModel(
      id: 'of1',
      productName: 'Café torrado 500 g',
      price: 9.90,
      storeId: storeId,
      storeName: 'Bom Preço',
      authorUid: 'autor-1',
      authorName: 'Maria Silva',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    Future<void> pumpDetail(
      WidgetTester tester,
      Phase3TestHarness harness,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        harness.buildTestApp(home: OfferDetailScreen(offerId: 'of1')),
      );
      // Frames extras: os providers de store/posição só inicializam quando
      // a view do detalhe monta (após a oferta carregar).
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('mostra "Distância: X,X km" quando store+posição disponíveis', (
      tester,
    ) async {
      final Phase3TestHarness harness = Phase3TestHarness(
        seedStores: <StoreModel>[kSeedGeoStore],
        locationService: FakeLocationService(positionOf(kSaoPauloGeo)),
      );
      harness.offersRepository.offersById = <String, OfferModel>{
        'of1': offer(storeId: 'store-1'),
      };

      await pumpDetail(tester, harness);

      expect(find.text('Distância: 14,8 km'), findsOneWidget);
      expect(
        find.byKey(const Key('offer_detail_distance_row')),
        findsOneWidget,
      );
    });

    testWidgets('oculta a linha quando não há posição do usuário', (
      tester,
    ) async {
      final Phase3TestHarness harness = Phase3TestHarness(
        seedStores: <StoreModel>[kSeedGeoStore],
        locationService: FakeLocationService(null),
      );
      harness.offersRepository.offersById = <String, OfferModel>{
        'of1': offer(storeId: 'store-1'),
      };

      await pumpDetail(tester, harness);

      expect(find.textContaining('Distância:'), findsNothing);
      // Tela segue íntegra com os demais dados.
      expect(find.text('Café torrado 500 g'), findsOneWidget);
      expect(find.text('Bom Preço'), findsOneWidget);
    });
  });
}
