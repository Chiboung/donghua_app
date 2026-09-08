import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/product.dart';
import '../services/product_service.dart';

/// Full detail view for a single catalog entry, pushed on top of the
/// tabbed shell when a card is tapped (Home or My List).
///
/// The uploader sees an edit icon in the app bar. Tapping it doesn't
/// jump straight into an edit form — it reveals a small edit button on
/// the cover image and another on the details card, so the owner picks
/// which one to change. Tapping the cover's button edits the image
/// only; tapping the details card's button edits the text fields only.
/// Each save writes just that piece plus a fresh `updatedAt` via
/// [ProductService.updateProduct], and the view then shows the entry's
/// last-edited date alongside its "Added by" line.
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;

  /// Revealed by the app-bar edit icon; shows the per-section edit
  /// buttons on the cover and the details card until the owner picks
  /// one (or backs out again).
  bool _showEditButtons = false;
  bool _editingImage = false;
  bool _editingData = false;
  bool _savingImage = false;
  bool _savingData = false;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleEnController;
  late final TextEditingController _titleKhController;
  late final TextEditingController _seasonController;
  late final TextEditingController _episodeController;
  late final TextEditingController _totalEpisodesController;
  late final TextEditingController _descController;

  final _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  /// Only the uploader can edit their own entry.
  bool get _isOwner =>
      AuthService.instance.currentUser?.uid == _product.uploaderId;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _titleEnController = TextEditingController(text: _product.titleEn);
    _titleKhController = TextEditingController(text: _product.titleKh);
    _seasonController = TextEditingController(text: _product.season.toString());
    _episodeController = TextEditingController(text: _product.episode.toString());
    _totalEpisodesController =
        TextEditingController(text: _product.totalEpisodes.toString());
    _descController = TextEditingController(text: _product.description);
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleKhController.dispose();
    _seasonController.dispose();
    _episodeController.dispose();
    _totalEpisodesController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _startEditingImage() {
    setState(() => _editingImage = true);
  }

  /// Discards a picked-but-unsaved image and drops back to the picker
  /// buttons.
  void _cancelEditingImage() {
    setState(() {
      _editingImage = false;
      _pickedImage = null;
      _pickedImageBytes = null;
    });
  }

  void _startEditingData() {
    setState(() => _editingData = true);
  }

  /// Discards any unsaved field changes and resets the form fields
  /// back to the entry's currently-saved values.
  void _cancelEditingData() {
    setState(() {
      _editingData = false;
      _titleEnController.text = _product.titleEn;
      _titleKhController.text = _product.titleKh;
      _seasonController.text = _product.season.toString();
      _episodeController.text = _product.episode.toString();
      _totalEpisodesController.text = _product.totalEpisodes.toString();
      _descController.text = _product.description;
    });
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _pickedImage = image;
      _pickedImageBytes = bytes;
    });
  }

  /// Saves the cover image only. If the owner opened the image editor
  /// but didn't actually pick a new photo, this just closes it back
  /// out instead of writing a no-op update.
  Future<void> _saveImage() async {
    if (_savingImage) return;
    if (_pickedImageBytes == null) {
      setState(() {
        _editingImage = false;
        _showEditButtons = false;
      });
      return;
    }

    setState(() => _savingImage = true);
    try {
      EasyLoading.show(status: 'Uploading...');
      final imageUrl = await CloudinaryService.instance.uploadImage(
        _pickedImageBytes!,
        filename: _pickedImage!.name,
        folder: 'products',
      );

      final updated = _product.copyWith(imageUrl: imageUrl);
      await ProductService.instance.updateProduct(updated);

      EasyLoading.dismiss();
      if (!mounted) return;
      setState(() {
        // The write above stamps `updatedAt` with the server clock;
        // showing "now" locally avoids waiting on a re-read just to
        // reflect a save that already succeeded.
        _product = updated.copyWith(updatedAt: DateTime.now());
        _editingImage = false;
        _showEditButtons = false;
        _pickedImage = null;
        _pickedImageBytes = null;
      });
      EasyLoading.showSuccess('Cover updated.');
    } catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t save changes: $e')),
      );
    } finally {
      if (mounted) setState(() => _savingImage = false);
    }
  }

  /// Saves the text fields only — the cover image is untouched.
  Future<void> _saveData() async {
    if (_savingData) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _savingData = true);
    try {
      EasyLoading.show(status: 'Saving changes...');
      final updated = _product.copyWith(
        titleEn: _titleEnController.text.trim(),
        titleKh: _titleKhController.text.trim(),
        season: int.parse(_seasonController.text.trim()),
        episode: int.parse(_episodeController.text.trim()),
        totalEpisodes: int.parse(_totalEpisodesController.text.trim()),
        description: _descController.text.trim(),
      );
      await ProductService.instance.updateProduct(updated);

      EasyLoading.dismiss();
      if (!mounted) return;
      setState(() {
        _product = updated.copyWith(updatedAt: DateTime.now());
        _editingData = false;
        _showEditButtons = false;
      });
      EasyLoading.showSuccess('Changes saved.');
    } catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showError('Couldn\'t save changes: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Couldn\'t save changes: $e')),
      // );
    } finally {
      if (mounted) setState(() => _savingData = false);
    }
  }

  String? _requiredText(String? v, String message) =>
      (v == null || v.trim().isEmpty) ? message : null;

  String? _requiredPositiveInt(String? v, String message) {
    if (v == null || v.trim().isEmpty) return message;
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return 'Enter a whole number';
    if (parsed < 0) return 'Must be 0 or more';
    return null;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} · $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Glass Header លូនចូល Status Bar ដោយស្វ័យប្រវត្ត
          GlassAppBar(
            title: _editingImage
                ? 'Edit Cover'
                : _editingData
                    ? 'Edit Details'
                    : _product.titleEn,
            actions: [
              if (_isOwner && !_showEditButtons && !_editingImage && !_editingData)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => setState(() => _showEditButtons = true),
                ),
              if (_showEditButtons && !_editingImage && !_editingData)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Done',
                  onPressed: () => setState(() => _showEditButtons = false),
                ),
              if (_editingImage) ...[
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancel',
                  onPressed: _savingImage ? null : _cancelEditingImage,
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: 'Save',
                  onPressed: _savingImage ? null : _saveImage,
                ),
              ],
              if (_editingData) ...[
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancel',
                  onPressed: _savingData ? null : _cancelEditingData,
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: 'Save',
                  onPressed: _savingData ? null : _saveData,
                ),
              ],
            ],
          ),

          // Content Area (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingM,
                AppDimensions.paddingM,
                AppDimensions.paddingM,
                AppDimensions.paddingXL,
              ),
              child: _buildDetail(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Whether the small per-section edit buttons should currently be
  /// visible — revealed by the app-bar edit icon, and hidden again the
  /// moment either section is actually being edited.
  bool get _showSectionEditButtons =>
      _showEditButtons && !_editingImage && !_editingData;

  Widget _buildDetail(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageSection(context),
        const SizedBox(height: AppDimensions.paddingM),
        _editingData ? _buildDataEditForm(context) : _buildDataView(context),
      ],
    );
  }

  /// The cover image. In its resting state it's just the picture; once
  /// the owner opens image-editing it becomes tappable to pick a new
  /// photo. The small pencil button in the corner only appears while
  /// the app-bar edit icon has revealed the section buttons.
  Widget _buildImageSection(BuildContext context) {
    return AspectRatio(
      // Same 9:16 ratio as the card thumbnail, just larger — the
      // full cover, not a cropped preview of it.
      aspectRatio: 2 / 3,
      child: GestureDetector(
        onTap: _editingImage && !_savingImage ? _pickImage : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              child: Container(
                color: AppColors.glassFill(context),
                child: _editingImage && _pickedImageBytes != null
                    ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                    : (_product.imageUrl.isNotEmpty
                        ? Image.network(
                            _product.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.textHint(context),
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: AppColors.textHint(context),
                            ),
                          )),
              ),
            ),
            if (_editingImage)
              Positioned(
                right: 8,
                bottom: 8,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                    onPressed: _savingImage ? null : _pickImage,
                  ),
                ),
              ),
            if (_showSectionEditButtons)
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon:
                        const Icon(Icons.edit, size: 18, color: Colors.white),
                    tooltip: 'Edit cover',
                    onPressed: _startEditingImage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The static (non-editing) title/season/description card, with a
  /// small edit button overlaid in its corner once the section buttons
  /// have been revealed.
  Widget _buildDataView(BuildContext context) {
    final product = _product;
    return Stack(
      children: [
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.titleKh,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                product.titleEn,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Wrap(
                spacing: AppDimensions.paddingS,
                runSpacing: AppDimensions.paddingXS,
                children: [
                  _Chip(label: 'Season ${product.season}', color: AppColors.secondary,),
                  _Chip(label: 'Episode ${product.episode}', color: AppColors.error,),
                  _Chip(label: '${product.totalEpisodes} episodes total', color: AppColors.success,),
                  _Chip(
                    label: product.isPublic ? 'Public' : 'Private',
                    icon: product.isPublic ? Icons.public : Icons.lock_outline,
                    color: product.isPublic ? AppColors.primary : AppColors.disabled,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Description',
                style: AppTextStyles.bodyLarge.copyWith(
                  //fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                product.description.isNotEmpty
                    ? product.description
                    : 'No description provided.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary(context)),
              ),
              if (product.uploaderName.isNotEmpty ||
                  product.updatedAt != null) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Divider(color: AppColors.divider(context)),
                const SizedBox(height: AppDimensions.paddingS),
                if (product.uploaderName.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 18, color: AppColors.textHint(context)),
                      const SizedBox(width: AppDimensions.paddingXS),
                      Text(
                        'Added by ${product.uploaderName}',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                // Only shown once an edit has actually happened —
                // freshly-added entries have no updatedAt yet.
                if (product.updatedAt != null) ...[
                  const SizedBox(height: AppDimensions.paddingXS),
                  Row(
                    children: [
                      Icon(Icons.edit_calendar_outlined,
                          size: 18, color: AppColors.textHint(context)),
                      const SizedBox(width: AppDimensions.paddingXS),
                      Text(
                        'Last edited ${_formatDate(product.updatedAt!)}',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
        if (_showSectionEditButtons)
          Positioned(
            right: 4,
            top: 4,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit details',
              onPressed: _startEditingData,
            ),
          ),
      ],
    );
  }

  /// The details form — title, season/episode, description. No image
  /// field here; the cover has its own editor via [_buildImageSection].
  Widget _buildDataEditForm(BuildContext context) {
    return GlassContainer(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleEnController,
              decoration: const InputDecoration(
                labelText: 'English title',
                border: OutlineInputBorder(),
              ),
              validator: (v) => _requiredText(v, 'Enter the English title'),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            TextFormField(
              controller: _titleKhController,
              decoration: const InputDecoration(
                labelText: 'Khmer title',
                border: OutlineInputBorder(),
              ),
              validator: (v) => _requiredText(v, 'Enter the Khmer title'),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _seasonController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Season',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _requiredPositiveInt(v, 'Enter season'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: TextFormField(
                    controller: _episodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Episode',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _requiredPositiveInt(v, 'Enter episode'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingS),
            TextFormField(
              controller: _totalEpisodesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Episodes for all seasons',
                border: OutlineInputBorder(),
              ),
              validator: (v) => _requiredPositiveInt(v, 'Enter total episode count'),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (v) => _requiredText(v, 'Enter a description'),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _savingData ? null : _cancelEditingData,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savingData ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
                    ),
                    child: Text(
                      _savingData ? 'Saving...' : 'Save',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const _Chip({required this.label, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: c, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
