import 'dart:convert';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'helpers/fake_repositories.dart';
import 'package:social_market_app/features/offers/data/offer_repository.dart';
import 'package:social_market_app/features/offers/domain/offer_model.dart';
import 'package:social_market_app/features/offers/presentation/new_offer_screen.dart';
import 'package:social_market_app/features/profile/domain/user_model.dart';
import 'package:social_market_app/features/profile/presentation/profile_tab.dart';
import 'package:social_market_app/features/stores/domain/store_model.dart';

const StoreModel kSeedStore = StoreModel(
  id: 'store-1',
  name: 'Bom Preço',
  city: 'Campinas',
  neighborhood: 'Centro',
  createdBy: 'seed-user',
);

/// PNG 1x1 transparente válido — permite que o preview `Image.file` da tela
/// decodifique de verdade dentro do teste.
const String _kPng1x1Base64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

/// Bombeia frames discretos (evita pumpAndSettle com SnackBars/spinners).
Future<void> _pumpFrames(WidgetTester tester, [int frames = 2]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Drena o timer do SnackBar para não vazar timer no fim do teste.
Future<void> _drainSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  group('NewOfferScreen (Fase 4)', () {
    Future<Phase3TestHarness> pumpForm(WidgetTester tester,
        {ImagePicker? imagePicker}) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final harness = Phase3TestHarness(seedStores: <StoreModel>[kSeedStore]);
      await tester.pumpWidget(
        harness.buildTestApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NewOfferScreen(imagePicker: imagePicker),
            ),
          ),
        ),
      );
      await tester.pump();
      return harness;
    }

    /// Preenche produto + preço e busca/seleciona o mercado semeado.
    Future<void> fillValidOfferAndStore(WidgetTester tester) async {
      await tester.enterText(
        find.byKey(const Key('new_offer_product_name_field')),
        'Café torrado 500 g',
      );
      await tester.enterText(
        find.byKey(const Key('new_offer_price_field')),
        '9,90',
      );
      await tester.enterText(
        find.byKey(const Key('new_offer_city_field')),
        'Campinas',
      );
      await tester.enterText(
        find.byKey(const Key('new_offer_store_search_field')),
        'bom',
      );
      await tester.tap(find.byKey(const Key('new_offer_search_stores_button')));
      await _pumpFrames(tester);
      await tester.tap(find.text('Bom Preço'));
      await tester.pump();
    }

    testWidgets('preço "0" mostra erro "maior que zero" e NÃO publica oferta', (
      tester,
    ) async {
      final harness = await pumpForm(tester);

      await tester.enterText(
        find.byKey(const Key('new_offer_product_name_field')),
        'Café torrado 500 g',
      );
      await tester.enterText(find.byKey(const Key('new_offer_price_field')), '0');
      await tester.tap(find.byKey(const Key('new_offer_publish_button')));
      await _pumpFrames(tester);

      expect(find.text('O preço deve ser maior que zero.'), findsOneWidget);
      expect(harness.offersRepository.createdOffers, isEmpty);

      // Mesmo erro para o preço normal OPCIONAL preenchido com zero.
      await tester.enterText(
        find.byKey(const Key('new_offer_price_field')),
        '9,90',
      );
      await tester.enterText(
        find.byKey(const Key('new_offer_regular_price_field')),
        '0',
      );
      await tester.tap(find.byKey(const Key('new_offer_publish_button')));
      await _pumpFrames(tester);

      expect(find.text('O preço deve ser maior que zero.'), findsOneWidget);
      expect(harness.offersRepository.createdOffers, isEmpty);
    });

    testWidgets('texto não numérico é filtrado pelo formatter e tratado como '
        'campo vazio (erro "Informe o preço atual")', (tester) async {
      final harness = await pumpForm(tester);

      final priceField = tester.widget<TextFormField>(
        find.byKey(const Key('new_offer_price_field')),
      );

      // enterText passa pelos inputFormatters: letras são descartadas.
      await tester.enterText(
        find.byKey(const Key('new_offer_price_field')),
        'abc',
      );
      expect(priceField.controller!.text, isEmpty);

      // '-1' também é impossível: o hífen é filtrado, restando '1'.
      await tester.enterText(
        find.byKey(const Key('new_offer_price_field')),
        '-1',
      );
      expect(priceField.controller!.text, '1');

      // Estado final coerente: campo vazio -> erro de obrigatório, sem publish.
      await tester.enterText(
        find.byKey(const Key('new_offer_product_name_field')),
        'Café torrado 500 g',
      );
      await tester.enterText(find.byKey(const Key('new_offer_price_field')), 'xyz');
      await tester.tap(find.byKey(const Key('new_offer_publish_button')));
      await _pumpFrames(tester);

      expect(find.text('Informe o preço atual.'), findsOneWidget);
      expect(harness.offersRepository.createdOffers, isEmpty);
    });

    testWidgets('fluxo sem foto publica oferta com imageUrl null e sem upload', (
      tester,
    ) async {
      final harness = await pumpForm(tester);

      await fillValidOfferAndStore(tester);
      await tester.tap(find.byKey(const Key('new_offer_publish_button')));
      await _pumpFrames(tester, 4);

      expect(find.text('Oferta publicada com sucesso!'), findsOneWidget);

      final saved = harness.offersRepository.createdOffers.single;
      expect(saved.imageUrl, isNull);
      expect(harness.offersRepository.uploadedImagePaths, isEmpty);

      await _drainSnackBar(tester);
    });

    testWidgets('falha de createOffer mostra SnackBar de erro e preserva form', (
      tester,
    ) async {
      final harness = await pumpForm(tester);
      harness.offersRepository.createOfferError = Exception('firestore down');

      await fillValidOfferAndStore(tester);
      await tester.tap(find.byKey(const Key('new_offer_publish_button')));
      await _pumpFrames(tester, 4);

      expect(
        find.text(
          'Não foi possível publicar sua oferta. '
          'Verifique os dados e tente novamente.',
        ),
        findsOneWidget,
      );
      // Nenhuma oferta chegou ao repositório...
      expect(harness.offersRepository.createdOffers, isEmpty);
      // ...e o formulário continua preenchido para nova tentativa.
      expect(find.text('Café torrado 500 g'), findsOneWidget);

      await _drainSnackBar(tester);
    });

    testWidgets('falha de upload mostra SnackBar de erro, preserva form e foto', (
      tester,
    ) async {
      // Arquivo temporário real para o preview Image.file decodificar.
      // I/O real exige tester.runAsync dentro de testWidgets.
      final Directory tempDir = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('sm_phase4'),
      ))!;
      addTearDown(
        () => tester.runAsync(() async {
          try {
            await tempDir.delete(recursive: true);
          } catch (_) {}
        }),
      );
      final String photoPath = (await tester.runAsync(() async {
        final File file = File('${tempDir.path}/foto_produto.png');
        await file.writeAsBytes(base64Decode(_kPng1x1Base64));
        return file.path;
      }))!;

      final stubPicker = _StubImagePicker(XFile(photoPath));
      final harness = await pumpForm(tester, imagePicker: stubPicker);
      harness.offersRepository.uploadOfferError = Exception('storage down');

      // Seleciona a foto pelo bottom sheet da própria tela.
      await tester.tap(find.byKey(const Key('new_offer_add_photo_button')));
      await _pumpFrames(tester, 3);
      await tester.tap(find.text('Escolher da galeria'));
      await _pumpFrames(tester, 3);
      expect(find.byType(Image), findsOneWidget); // preview visível

      await fillValidOfferAndStore(tester);
      await tester.tap(find.byKey(const Key('new_offer_publish_button')));
      await _pumpFrames(tester, 4);

      expect(
        find.text(
          'Não foi possível publicar sua oferta. '
          'Verifique os dados e tente novamente.',
        ),
        findsOneWidget,
      );
      // Upload foi tentado ANTES do create; create nunca aconteceu.
      expect(harness.offersRepository.uploadedImagePaths, hasLength(1));
      expect(harness.offersRepository.createdOffers, isEmpty);
      // Formulário E foto preservados para nova tentativa.
      expect(find.text('Café torrado 500 g'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      await _drainSnackBar(tester);
    });

    testWidgets('busca de mercado SEM cidade não consulta o repositório', (
      tester,
    ) async {
      final harness = await pumpForm(tester);

      await tester.enterText(
        find.byKey(const Key('new_offer_store_search_field')),
        'bom',
      );
      await tester.tap(find.byKey(const Key('new_offer_search_stores_button')));
      await _pumpFrames(tester);

      expect(
        find.text('Informe a cidade antes de buscar mercados.'),
        findsOneWidget,
      );
      expect(harness.storesRepository.searchCalls, isEmpty);
      // Nenhum resultado/estado de "buscou" foi apresentado.
      expect(find.textContaining('Nenhum mercado encontrado'), findsNothing);
      expect(find.text('Bom Preço'), findsNothing);

      await _drainSnackBar(tester);
    });
  });

  group('ProfileTab (Fase 4)', () {
    testWidgets('exibe card de pontos e SignOutButton', (tester) async {
      final harness = Phase3TestHarness(
        profile: UserModel(
          uid: 'uid-1',
          displayName: 'Maria Silva',
          points: 7,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      await tester.pumpWidget(
        harness.buildTestApp(home: const Scaffold(body: ProfileTab())),
      );
      await _pumpFrames(tester, 3);

      // Card de pontos (stream do UserRepository fake).
      expect(find.byIcon(Icons.stars), findsOneWidget);
      expect(find.text('7 pontos'), findsOneWidget);
      expect(
        find.text('Ganhe pontos publicando e confirmando ofertas.'),
        findsOneWidget,
      );

      // Logout acessível.
      expect(find.byType(SignOutButton), findsOneWidget);
    });
  });

  group('OfferRepository (Fase 4)', () {
    late FakeFirebaseFirestore db;

    setUp(() {
      db = FakeFirebaseFirestore();
    });

    OfferModel buildOffer(DateTime createdAt, String productName) =>
        OfferModel(
          productName: productName,
          price: 10,
          unit: 'un',
          storeId: 's1',
          authorUid: 'u1',
          createdAt: createdAt,
        );

    test('watchRecent respeita limite estrito (somente os N mais recentes)', ()
        async {
      final repository = OfferRepository(db, MockFirebaseAuth());
      await repository.createOffer(buildOffer(DateTime.utc(2026, 8, 1), 'A'));
      await repository.createOffer(buildOffer(DateTime.utc(2026, 8, 2), 'B'));
      await repository.createOffer(buildOffer(DateTime.utc(2026, 8, 3), 'C'));

      final resultado = await repository.watchRecent(limit: 2).first;

      expect(resultado, hasLength(2));
      // Ordenado por createdAt desc: os dois mais novos apenas.
      expect(resultado.map((o) => o.productName).toList(), <String>['C', 'B']);
    });

    test('deleteOffer sem usuário autenticado lança StateError e mantém doc', ()
        async {
      final signedOutAuth = MockFirebaseAuth(); // sem currentUser
      expect(signedOutAuth.currentUser, isNull);
      final repository = OfferRepository(db, signedOutAuth);

      await db.collection('offers').doc('of-1').set(<String, dynamic>{
        'productName': 'Arroz 5kg',
        'price': 19.9,
        'unit': 'un',
        'storeId': 's1',
        'authorUid': 'u1',
        'createdAt': DateTime.utc(2026, 8, 1),
        'confirmCount': 0,
        'status': 'active',
      });

      await expectLater(repository.deleteOffer('of-1'), throwsStateError);
      expect((await db.collection('offers').doc('of-1').get()).exists, isTrue);
    });
  });
}

/// ImagePicker falso que retorna um [XFile] fixo, sem tocar em canais de
/// plataforma (impossíveis no ambiente de widget test).
class _StubImagePicker extends ImagePicker {
  _StubImagePicker(this.result);

  final XFile? result;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async =>
      result;
}
