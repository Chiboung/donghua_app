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
import '../../home/models/product.dart';
import '../../home/services/product_service.dart';

/// Add tab: form for cataloging a new donghua/anime entry.
///
/// On submit: the picked cover image goes to Cloudinary first (unsigned
/// upload), then the entry — including the URL Cloudinary returns — is
/// written to Firestore. Nothing is saved until both steps succeed, so
/// a failed upload never leaves an entry with a broken cover.
class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleEnController = TextEditingController();
  final _titleKhController = TextEditingController();
  final _seasonController = TextEditingController();
  final _episodeController = TextEditingController();
  final _totalEpisodesController = TextEditingController();
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _submitting = false;

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
        const SnackBar(content: Text('Please add a cover image.')),
      );
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before adding an entry.')),
      );
      return;
    }

    setState(() => _submitting = true);
    EasyLoading.show(status: 'Uploading...');
    try {
      final imageUrl = await CloudinaryService.instance.uploadImage(
        _pickedImageBytes!,
        filename: _pickedImage!.name,
        folder: 'products',
      );

      EasyLoading.show(status: 'Publishing entry...');
      final role = await UserService.instance.fetchRole(user.uid);
      final product = Product(
        id: '',
        titleEn: _titleEnController.text.trim(),
        titleKh: _titleKhController.text.trim(),
        season: int.parse(_seasonController.text.trim()),
        episode: int.parse(_episodeController.text.trim()),
        totalEpisodes: int.parse(_totalEpisodesController.text.trim()),
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        uploaderId: user.uid,
        uploaderName: user.displayName?.isNotEmpty == true
            ? user.displayName!
            : (user.email ?? 'Uploader'),
        uploaderRole: role.toString(),
      );
      await ProductService.instance.addProduct(product);

      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showSuccess('Added "${product.titleKh}"');
      _formKey.currentState!.reset();
      _titleEnController.clear();
      _titleKhController.clear();
      _seasonController.clear();
      _episodeController.clear();
      _totalEpisodesController.clear();
      _descController.clear();
      setState(() {
        _pickedImage = null;
        _pickedImageBytes = null;
      });
    } catch (e) {
      EasyLoading.dismiss();
      if (!mounted) return;
      EasyLoading.showError('Couldn\'t add this entry: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'Add an Entry'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingM,
          AppDimensions.paddingM,
          AppDimensions.paddingM,
          96,
        ),
        child: GlassContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _VisibilityHint(uid: AuthService.instance.currentUser?.uid),
                const SizedBox(height: AppDimensions.paddingS),
                GestureDetector(
                  onTap: _submitting ? null : _pickImage,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
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
                                    'Cover image (2:3)',
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(color: AppColors.textHint(context)),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
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
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
                  ),
                  child: Text(
                    _submitting ? 'Adding...' : 'Add Entry',
                    style: AppTextStyles.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _VisibilityHint extends StatelessWidget {
  final String? uid;

  const _VisibilityHint({required this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<UserRole>(
      stream: UserService.instance.watchRole(uid!),
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.user;
        final isAdmin = role == UserRole.admin;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingS,
            vertical: AppDimensions.paddingXS,
          ),
          decoration: BoxDecoration(
            color: (isAdmin ? AppColors.success : AppColors.primary)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          ),
          child: Row(
            children: [
              Icon(
                isAdmin ? Icons.public : Icons.lock_outline,
                size: 16,
                color: isAdmin ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.paddingXS),
              Expanded(
                child: Text(
                  isAdmin
                      ? 'Visible to everyone once added.'
                      : 'Only visible to you once added.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isAdmin ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
