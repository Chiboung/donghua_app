import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/widgets/app_text_button.dart';
import '../../../config/widgets/glass_app_bar.dart';
import '../../../config/widgets/glass_container.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/item.dart';
import '../models/item_type.dart';
import '../services/item_service.dart';

/// Full detail view for a single item, pushed on top of the tabbed
/// shell when a card is tapped (Categories).
class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Item _item;
  late bool _isPublic;

  bool _showEditButtons = false;
  bool _editingImage = false;
  bool _editingData = false;
  bool _savingImage = false;
  bool _savingData = false;
  bool _deleting = false;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _descController;
  late String _selectedType;

  final _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;

  /// Only the uploader can edit or delete their own item.
  bool get _isOwner => AuthService.instance.currentUser?.uid == _item.uploaderId;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _titleController = TextEditingController(text: _item.title);
    _priceController = TextEditingController(text: _item.price.toStringAsFixed(2));
    _discountController = TextEditingController(text: _item.discount.toStringAsFixed(0));
    _descController = TextEditingController(text: _item.description);
    _selectedType = _item.type;
    _isPublic = _item.isPublic;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _startEditingImage() => setState(() => _editingImage = true);

  void _cancelEditingImage() {
    setState(() {
      _editingImage = false;
      _pickedImage = null;
      _pickedImageBytes = null;
    });
  }

  void _startEditingData() => setState(() => _editingData = true);

  void _cancelEditingData() {
    setState(() {
      _editingData = false;
      _titleController.text = _item.title;
      _priceController.text = _item.price.toStringAsFixed(2);
      _discountController.text = _item.discount.toStringAsFixed(0);
      _descController.text = _item.description;
      _selectedType = _item.type;
      _isPublic = _item.isPublic;
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
        folder: 'items',
      );

      final updated = _item.copyWith(imageUrl: imageUrl);
      await ItemService.instance.updateItem(updated);

      EasyLoading.dismiss();
      if (!mounted) return;
      setState(() {
        _item = updated.copyWith(updatedAt: DateTime.now());
        _editingImage = false;
        _showEditButtons = false;
        _pickedImage = null;
        _pickedImageBytes = null;
      });
      EasyLoading.showSuccess('Photo updated.');
    } catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showError('Couldn\'t save changes: $e');
    } finally {
      if (mounted) setState(() => _savingImage = false);
    }
  }

  Future<void> _saveData() async {
    if (_savingData) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _savingData = true);
    try {
      EasyLoading.show(status: 'Saving changes...');
      final updatedRole = _isPublic ? 'admin' : 'user';

      final updated = _item.copyWith(
        title: _titleController.text.trim(),
        type: _selectedType,
        price: double.parse(_priceController.text.trim()),
        discount: double.tryParse(_discountController.text.trim()) ?? 0,
        description: _descController.text.trim(),
        uploaderRole: updatedRole,
      );
      await ItemService.instance.updateItem(updated);

      EasyLoading.dismiss();
      if (!mounted) return;
      setState(() {
        _item = updated.copyWith(updatedAt: DateTime.now());
        _editingData = false;
        _showEditButtons = false;
      });
      EasyLoading.showSuccess('Changes saved.');
    } catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showError('Couldn\'t save changes: $e');
    } finally {
      if (mounted) setState(() => _savingData = false);
    }
  }

  Future<void> _confirmDelete() async {
    if (_deleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this item?'),
        content: Text('"${_item.title}" will be removed for everyone. This can\'t be undone.'),
        actions: [
          AppTextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            label: 'Cancel',
          ),
          AppTextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: 'Delete',
            color: AppColors.error,
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      EasyLoading.show(status: 'Deleting...');
      await ItemService.instance.deleteItem(_item.id);
      EasyLoading.dismiss();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showError('Couldn\'t delete this item: $e');
      setState(() => _deleting = false);
    }
  }

  String? _requiredText(String? v, String message) =>
      (v == null || v.trim().isEmpty) ? message : null;

  String? _requiredPositiveNumber(String? v, String message) {
    if (v == null || v.trim().isEmpty) return message;
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Must be 0 or more';
    return null;
  }

  String? _optionalPercent(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0 || parsed > 100) return 'Enter 0–100';
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

  bool get _showSectionEditButtons => _showEditButtons && !_editingImage && !_editingData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GlassAppBar(
            title: _editingImage
                ? 'Edit Photo'
                : _editingData
                    ? 'Edit Item'
                    : _item.title,
            actions: [
              if (_isOwner && !_showEditButtons && !_editingImage && !_editingData) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => setState(() => _showEditButtons = true),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  color: AppColors.error,
                  onPressed: _deleting ? null : _confirmDelete,
                ),
              ],
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
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingM,
                AppDimensions.paddingM,
                AppDimensions.paddingM,
                AppDimensions.paddingXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImageSection(context),
                  const SizedBox(height: AppDimensions.paddingM),
                  _editingData ? _buildDataEditForm(context) : _buildDataView(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
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
                    : (_item.imageUrl.isNotEmpty
                        ? Image.network(
                            _item.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Center(
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
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    tooltip: 'Edit photo',
                    onPressed: _startEditingImage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataView(BuildContext context) {
    final item = _item;
    return Stack(
      children: [
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Row(
                children: [
                  Text(
                    '\$${item.finalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.hasDiscount) ...[
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint(context),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Wrap(
                spacing: AppDimensions.paddingS,
                runSpacing: AppDimensions.paddingXS,
                children: [
                  _Chip(label: item.type, icon: ItemType.iconFor(item.type)),
                  if (item.hasDiscount)
                    _Chip(
                      label: '-${item.discount.toStringAsFixed(0)}% off',
                      color: AppColors.error,
                    ),
                  _Chip(
                    label: item.isPublic ? 'Public' : 'Private',
                    icon: item.isPublic ? Icons.public : Icons.lock_outline,
                    color: item.isPublic ? AppColors.primary : AppColors.disabled,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Description',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary(context)),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                item.description.isNotEmpty ? item.description : 'No description provided.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
              ),
              if (item.uploaderName.isNotEmpty || item.updatedAt != null) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Divider(color: AppColors.divider(context)),
                const SizedBox(height: AppDimensions.paddingS),
                if (item.uploaderName.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 18, color: AppColors.textHint(context)),
                      const SizedBox(width: AppDimensions.paddingXS),
                      Text(
                        'Added by ${item.uploaderName}',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                if (item.updatedAt != null) ...[
                  const SizedBox(height: AppDimensions.paddingXS),
                  Row(
                    children: [
                      Icon(Icons.edit_calendar_outlined,
                          size: 18, color: AppColors.textHint(context)),
                      const SizedBox(width: AppDimensions.paddingXS),
                      Text(
                        'Last edited ${_formatDate(item.updatedAt!)}',
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

  Widget _buildDataEditForm(BuildContext context) {
    return GlassContainer(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => _requiredText(v, 'Enter a title'),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            
            // Visibility Toggle (Public / Private)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _isPublic ? 'Public Item' : 'Private Item',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _isPublic
                    ? 'Visible to everyone on the platform'
                    : 'Visible only to you',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              secondary: Icon(
                _isPublic ? Icons.public : Icons.lock_outline,
                color: _isPublic ? AppColors.primary : AppColors.disabled,
              ),
              value: _isPublic,
              onChanged: (val) => setState(() => _isPublic = val),
            ),
            const SizedBox(height: AppDimensions.paddingS),

            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ItemType.all
                  .map((t) => DropdownMenuItem(
                        value: t.name,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(t.icon, size: 18, color: AppColors.textSecondary(context)),
                            const SizedBox(width: AppDimensions.paddingS),
                            Text(t.name),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedType = v);
              },
              validator: (v) => v == null ? 'Select a type' : null,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Price', prefixText: '\$'),
                    validator: (v) => _requiredPositiveNumber(v, 'Enter a price'),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Discount', suffixText: '%'),
                    validator: _optionalPercent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingS),
            TextFormField(
              controller: _descController,
              minLines: 3,
              maxLines: 8,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
              validator: (v) => _requiredText(v, 'Enter a description'),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _savingData ? null : _cancelEditingData,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.glassFill(context),
                      foregroundColor: AppColors.textSecondary(context),
                      side: BorderSide(color: AppColors.glassBorder(context)),
                      minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savingData ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.glassFill(context),
                      foregroundColor: AppColors.textSecondary(context),
                      elevation: 0,
                      side: BorderSide(color: AppColors.glassBorder(context)),
                      minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      _savingData ? 'Saving...' : 'Save',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
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