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
import '../../auth/services/user_service.dart';
import '../../auth/widgets/visibility_hint.dart';
import '../models/item.dart';
import '../models/item_type.dart';
import '../services/item_service.dart';

/// Form for adding a new shop item: photo, title, type, price,
/// discount, and description.
class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  String? _selectedType;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _submitting = false;

  /// Admin's chosen visibility for the item being created. Null means
  /// "use the role default" (public for an admin, private for a
  /// regular user) — set once they tap the visibility hint to override
  /// it for this item.
  bool? _isPublicOverride;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo.')),
      );
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before adding an item.')),
      );
      return;
    }

    setState(() => _submitting = true);
    EasyLoading.show(status: 'Uploading...');
    try {
      final imageUrl = await CloudinaryService.instance.uploadImage(
        _pickedImageBytes!,
        filename: _pickedImage!.name,
        folder: 'items',
      );

      EasyLoading.show(status: 'Publishing item...');
      final role = await UserService.instance.fetchRole(user.uid);
      final String finalRole = _isPublicOverride != null
    ? (_isPublicOverride! ? 'admin' : 'user')
    : (role == UserRole.admin ? 'admin' : 'user');
      final item = Item(
        id: '',
        title: _titleController.text.trim(),
        type: _selectedType!,
        price: double.parse(_priceController.text.trim()),
        discount: double.tryParse(_discountController.text.trim()) ?? 0,
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        uploaderId: user.uid,
        uploaderName: user.displayName?.isNotEmpty == true
            ? user.displayName!
            : (user.email ?? 'Uploader'),
        uploaderRole: finalRole,
        //isPublic: isPublic,
      );
      await ItemService.instance.addItem(item);

      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showSuccess('Added "${item.title}"');
      _formKey.currentState!.reset();
      _titleController.clear();
      _priceController.clear();
      _discountController.text = '0';
      _descController.clear();
      setState(() {
        _selectedType = null;
        _pickedImage = null;
        _pickedImageBytes = null;
        _isPublicOverride = null;
      });
    } catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showError('Couldn\'t add this item: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const GlassAppBar(title: 'Add an Item'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.paddingM,
                  AppDimensions.paddingM,
                  AppDimensions.paddingM,
                  110, // clears the floating bottom nav bar
                ),
                child: GlassContainer(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        VisibilityHint(
                          uid: AuthService.instance.currentUser?.uid,
                          isPublicOverride: _isPublicOverride,
                          onChanged: (v) => setState(() => _isPublicOverride = v),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        GestureDetector(
                          onTap: _submitting ? null : _pickImage,
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.glassFill(context),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                border: Border.all(color: AppColors.glassBorder(context)),
                              ),
                              child: _pickedImageBytes != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.memory(_pickedImageBytes!, fit: BoxFit.cover),
                                        Positioned(
                                          right: 8,
                                          bottom: 8,
                                          child: CircleAvatar(
                                            radius: 16,
                                            backgroundColor: Colors.black54,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              onPressed: _submitting ? null : _pickImage,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_outlined,
                                            size: 40,
                                            color: AppColors.textHint(context),
                                          ),
                                          const SizedBox(height: AppDimensions.paddingXS),
                                          Text(
                                            'Item photo',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.textHint(context),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (v) => _requiredText(v, 'Enter a title'),
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
                          onChanged: _submitting ? null : (v) => setState(() => _selectedType = v),
                          validator: (v) => v == null ? 'Select a type' : null,
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  prefixText: '\$',
                                ),
                                validator: (v) => _requiredPositiveNumber(v, 'Enter a price'),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            Expanded(
                              child: TextFormField(
                                controller: _discountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Discount',
                                  suffixText: '%',
                                ),
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
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                          ),
                          validator: (v) => _requiredText(v, 'Enter a description'),
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
                        ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
                          ),
                          child: Text(
                            _submitting ? 'Adding...' : 'Add Item',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
