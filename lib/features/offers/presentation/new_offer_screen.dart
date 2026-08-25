import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../stores/data/store_repository.dart';
import '../../stores/domain/store_model.dart';
import '../data/offer_repository.dart';
import '../domain/offer_model.dart';

/// Aba/formulário de criação de uma nova oferta.
///
/// Fluxo: foto opcional -> dados do produto -> mercado (busca ou cadastro
/// inline) -> publicar. O upload da imagem acontece ANTES de criar o
/// documento da oferta; qualquer falha resulta em SnackBar amigável.
class NewOfferScreen extends ConsumerStatefulWidget {
  const NewOfferScreen({super.key, this.onOfferSaved, this.imagePicker});

  /// Invocado após publicar com sucesso (ex.: voltar à aba de feed).
  final VoidCallback? onOfferSaved;

  /// Picker injetável para testes automatizados (o plugin real depende de
  /// canal de plataforma indisponível no ambiente de teste). Em produção,
  /// permanece nulo e um [ImagePicker] padrão é criado.
  final ImagePicker? imagePicker;

  @override
  ConsumerState<NewOfferScreen> createState() => _NewOfferScreenState();
}

class _NewOfferScreenState extends ConsumerState<NewOfferScreen> {
  static const List<String> _units = <String>[
    'un',
    'kg',
    'g',
    'L',
    'ml',
    'pack',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _regularPriceController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _storeSearchController = TextEditingController();

  late final ImagePicker _imagePicker;

  String _unit = 'un';
  StoreModel? _selectedStore;
  List<StoreModel> _searchResults = const <StoreModel>[];
  bool _isSearching = false;
  bool _hasSearched = false;
  XFile? _imageFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _imagePicker = widget.imagePicker ?? ImagePicker();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _regularPriceController.dispose();
    _cityController.dispose();
    _storeSearchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Aceita tanto "9,90" quanto "9.90".
  double? _parseMoney(String raw) {
    final String normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _showFeedback(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? Theme.of(context).colorScheme.error : null,
          content: Text(message),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Foto opcional
  // ---------------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (!mounted || picked == null) return;
      setState(() => _imageFile = picked);
    } catch (_) {
      // image_picker não está disponível em todas as plataformas/desktop;
      // nunca devemos crashar por causa de um campo opcional.
      _showFeedback(
        source == ImageSource.camera
            ? 'Não foi possível abrir a câmera neste dispositivo.'
            : 'Não foi possível abrir a galeria neste dispositivo.',
        isError: true,
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Busca / seleção / cadastro de mercado
  // ---------------------------------------------------------------------------

  Future<void> _searchStores() async {
    final String city = _cityController.text.trim();
    final String query = _storeSearchController.text.trim();

    if (city.isEmpty) {
      _showFeedback('Informe a cidade antes de buscar mercados.', isError: true);
      return;
    }
    if (query.isEmpty) {
      _showFeedback(
        'Digite parte do nome do mercado para buscar.',
        isError: true,
      );
      return;
    }

    setState(() => _isSearching = true);
    try {
      final List<StoreModel> results =
          await ref.read(storeRepositoryProvider).searchByName(city, query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _hasSearched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searchResults = const <StoreModel>[];
        _hasSearched = true;
      });
      _showFeedback(
        'Não foi possível buscar mercados agora. Tente novamente.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectStore(StoreModel store) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selectedStore = store;
      _searchResults = const <StoreModel>[];
      _hasSearched = false;
      _storeSearchController.clear();
    });
  }

  Future<void> _openCreateStoreDialog() async {
    final StoreModel? created = await showDialog<StoreModel>(
      context: context,
      builder: (BuildContext dialogContext) =>
          _CreateStoreDialog(initialCity: _cityController.text.trim()),
    );
    if (!mounted || created == null) return;
    setState(() {
      _selectedStore = created;
      _searchResults = const <StoreModel>[];
      _hasSearched = false;
    });
    _showFeedback(
      'Mercado "${created.name}" cadastrado e selecionado!',
      isError: false,
    );
  }

  // ---------------------------------------------------------------------------
  // Salvamento
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final StoreModel? store = _selectedStore;
    if (store == null || (store.id ?? '').isEmpty) {
      _showFeedback(
        'Selecione ou cadastre um mercado antes de publicar.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final String? uid = ref.read(firebaseAuthProvider).currentUser?.uid;
      if (uid == null || uid.isEmpty) {
        throw StateError('Usuário não autenticado');
      }
      final OfferRepository offerRepository = ref.read(offerRepositoryProvider);

      // Upload da imagem ANTES de criar a oferta.
      String? imageUrl;
      final XFile? image = _imageFile;
      if (image != null) {
        final String path = '${DateTime.now().millisecondsSinceEpoch}_$uid.jpg';
        imageUrl = await offerRepository.uploadOfferImage(path, image);
      }

      final OfferModel offer = OfferModel(
        productName: _productNameController.text.trim(),
        price: _parseMoney(_priceController.text)!,
        regularPrice: _parseMoney(_regularPriceController.text),
        unit: _unit,
        storeId: store.id!,
        authorUid: uid,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        // status: OfferStatus.active e confirmCount: 0 são os defaults.
      );

      await offerRepository.createOffer(offer);

      if (!mounted) return;
      _resetForm();
      _showFeedback('Oferta publicada com sucesso!', isError: false);
      widget.onOfferSaved?.call();
    } catch (error) {
      debugPrint('[NewOfferScreen] Falha ao publicar oferta: $error');
      if (!mounted) return;
      _showFeedback(
        'Não foi possível publicar sua oferta. '
        'Verifique os dados e tente novamente.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _productNameController.clear();
    _priceController.clear();
    _regularPriceController.clear();
    _cityController.clear();
    _storeSearchController.clear();
    setState(() {
      _unit = 'un';
      _selectedStore = null;
      _searchResults = const <StoreModel>[];
      _hasSearched = false;
      _isSearching = false;
      _imageFile = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Validators (mensagens em PT-BR)
  // ---------------------------------------------------------------------------

  String? _validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome do produto.';
    }
    return null;
  }

  String? _validatePrice(String? value, {required bool isRequired}) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isRequired ? 'Informe o preço atual.' : null;
    }
    final double? parsed = _parseMoney(trimmed);
    if (parsed == null) {
      return 'Preço inválido.';
    }
    if (parsed <= 0) {
      return 'O preço deve ser maior que zero.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Foto', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildPhotoPicker(),
            const SizedBox(height: 24),

            Text('Dados da oferta', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('new_offer_product_name_field'),
              controller: _productNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome do produto *',
                hintText: 'Ex.: Café torrado 500 g',
                border: OutlineInputBorder(),
              ),
              validator: _validateProductName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('new_offer_price_field'),
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Preço atual *',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) =>
                  _validatePrice(value, isRequired: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('new_offer_regular_price_field'),
              controller: _regularPriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Preço normal (opcional)',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) =>
                  _validatePrice(value, isRequired: false),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('new_offer_unit_dropdown'),
              initialValue: _unit,
              decoration: const InputDecoration(
                labelText: 'Unidade',
                border: OutlineInputBorder(),
              ),
              items: _units
                  .map(
                    (String unit) => DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _unit = value);
                }
              },
            ),
            const SizedBox(height: 24),

            Text('Mercado', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('new_offer_city_field'),
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Cidade do mercado *',
                hintText: 'Ex.: Campinas',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    key: const Key('new_offer_store_search_field'),
                    controller: _storeSearchController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _searchStores(),
                    decoration: const InputDecoration(
                      labelText: 'Buscar mercado',
                      hintText: 'Nome ou início do nome',
                      prefixIcon: Icon(Icons.store_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  key: const Key('new_offer_search_stores_button'),
                  tooltip: 'Buscar mercados',
                  onPressed: _isSearching ? null : _searchStores,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildStoreStatusArea(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('new_offer_open_create_store_button'),
              onPressed: _openCreateStoreDialog,
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('+ Cadastrar novo mercado'),
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              key: const Key('new_offer_publish_button'),
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_isSubmitting ? 'Publicando...' : 'Publicar oferta'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    final XFile? image = _imageFile;

    if (image == null) {
      return OutlinedButton.icon(
        key: const Key('new_offer_add_photo_button'),
        onPressed: _showImageSourceSheet,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Adicionar foto (opcional)'),
      );
    }

    return Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(image.path),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            semanticLabel: 'Foto selecionada do produto',
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'Remover foto',
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _imageFile = null),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoreStatusArea() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(
          minHeight: 2,
          semanticsLabel: 'Buscando mercados',
        ),
      );
    }

    final StoreModel? selected = _selectedStore;
    if (selected != null) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(selected.name),
          subtitle: Text('${selected.neighborhood} • ${selected.city}'),
          trailing: IconButton(
            tooltip: 'Trocar mercado',
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _selectedStore = null),
          ),
        ),
      );
    }

    if (!_hasSearched) {
      return const SizedBox.shrink();
    }

    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Nenhum mercado encontrado. Você pode cadastrá-lo abaixo.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (final StoreModel store in _searchResults)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              key: ValueKey<String>('new_offer_store_option_${store.id}'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              leading: const Icon(Icons.store_outlined),
              title: Text(store.name),
              subtitle: Text('${store.neighborhood} • ${store.city}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectStore(store),
            ),
          ),
      ],
    );
  }
}

/// Diálogo inline para cadastrar um novo mercado e já retorná-lo selecionado.
class _CreateStoreDialog extends ConsumerStatefulWidget {
  const _CreateStoreDialog({this.initialCity = ''});

  final String initialCity;

  @override
  ConsumerState<_CreateStoreDialog> createState() => _CreateStoreDialogState();
}

class _CreateStoreDialogState extends ConsumerState<_CreateStoreDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _cityController = TextEditingController(
    text: widget.initialCity,
  );
  late final TextEditingController _neighborhoodController =
      TextEditingController();
  late final TextEditingController _addressController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);
    try {
      final String? uid = ref.read(firebaseAuthProvider).currentUser?.uid;
      if (uid == null || uid.isEmpty) {
        throw StateError('Usuário não autenticado');
      }

      final StoreModel created = StoreModel(
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        createdBy: uid,
      );

      // StoreModel.copyWith não altera o id; reconstruímos com o id gerado.
      final String id = await ref.read(storeRepositoryProvider).createStore(created);

      if (!mounted) return;
      Navigator.of(context).pop(
        StoreModel(
          id: id,
          name: created.name,
          city: created.city,
          neighborhood: created.neighborhood,
          address: created.address,
          createdBy: created.createdBy,
        ),
      );
    } catch (error) {
      debugPrint('[CreateStoreDialog] Falha ao cadastrar mercado: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text(
              'Não foi possível cadastrar o mercado. Tente novamente.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar novo mercado'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                key: const Key('create_store_name_field'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nome do mercado *',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Informe o nome do mercado.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('create_store_city_field'),
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cidade *',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Informe a cidade do mercado.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('create_store_neighborhood_field'),
                controller: _neighborhoodController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('create_store_address_field'),
                controller: _addressController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('create_store_save_button'),
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar mercado'),
        ),
      ],
    );
  }
}
