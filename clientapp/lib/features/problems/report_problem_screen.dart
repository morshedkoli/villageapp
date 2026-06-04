import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/motion.dart';
import '../../data_service.dart';

class ReportProblemScreen extends ConsumerStatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  ConsumerState<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends ConsumerState<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'রাস্তা';
  File? _selectedImage;
  bool _submitting = false;

  final _categories = ['রাস্তা', 'পানি', 'বিদ্যুৎ', 'শিক্ষা', 'স্বাস্থ্য', 'অন্যান্য'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(delay: 0, child: _buildAppBar()),
                AppSpacing.hXxl,
                FadeSlideIn(delay: 80, child: _buildTitleField()),
                AppSpacing.hXxl,
                FadeSlideIn(delay: 120, child: _buildCategorySelector()),
                AppSpacing.hXxl,
                FadeSlideIn(delay: 160, child: _buildDescriptionField()),
                AppSpacing.hXxl,
                FadeSlideIn(delay: 200, child: _buildImagePicker()),
                AppSpacing.hXxl,
                FadeSlideIn(delay: 240, child: _buildLocationField()),
                AppSpacing.hXxl,
                FadeSlideIn(delay: 280, child: _buildSubmitButton()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        PressScale(
          scale: 0.92,
          onTap: () => context.pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.close_rounded, size: 22),
          ),
        ),
        AppSpacing.wMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'নতুন রিপোর্ট',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'সমস্যার বিবরণ দিন',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'সমস্যার শিরোনাম',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.hMd,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextFormField(
            controller: _titleController,
            style: context.textTheme.bodyMedium?.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'যেমন: রাস্তা ভেঙে গেছে',
              hintStyle: context.textTheme.bodyMedium?.copyWith(color: context.textTertiary),
              filled: true,
              fillColor: context.isDark ? AppColors.darkCard : AppColors.lightBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'শিরোনাম দিন' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'বিভাগ',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.hMd,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (val) {
                  if (val) setState(() => _selectedCategory = cat);
                },
                labelStyle: context.textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.primary : context.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundColor: context.isDark ? AppColors.darkCard : AppColors.lightBackground,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'বর্ণনা',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.hMd,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            minLines: 4,
            style: context.textTheme.bodyMedium?.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'সমস্যার বিস্তারিত বর্ণনা দিন...',
              hintStyle: context.textTheme.bodyMedium?.copyWith(color: context.textTertiary),
              filled: true,
              fillColor: context.isDark ? AppColors.darkCard : AppColors.lightBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              alignLabelWithHint: true,
            ),
            validator: (v) => v == null || v.isEmpty ? 'বর্ণনা দিন' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'ছবি',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.hMd,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.darkCard : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: context.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 36,
                          color: context.textTertiary,
                        ),
                        AppSpacing.hSm,
                        Text(
                          'ছবি যুক্ত করুন',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppSpacing.hXs,
                        Text(
                          'সমস্যার ছবি আপলোড করুন',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_selectedImage!, fit: BoxFit.cover),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: IconButton(
                                onPressed: () => setState(() => _selectedImage = null),
                                icon: const Icon(Icons.close_rounded, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'অবস্থান',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.hMd,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextFormField(
            controller: _locationController,
            style: context.textTheme.bodyMedium?.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'ঠিকানা বা অবস্থান দিন',
              hintStyle: context.textTheme.bodyMedium?.copyWith(color: context.textTertiary),
              prefixIcon: Icon(Icons.location_on_outlined, size: 20, color: context.textTertiary),
              filled: true,
              fillColor: context.isDark ? AppColors.darkCard : AppColors.lightBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _submitting ? null : _handleSubmit,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'রিপোর্ট জমা দিন',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (image == null) {
      return;
    }
    setState(() => _selectedImage = File(image.path));
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await DataService.instance.reportProblem(
        title: '[${_selectedCategory.trim()}] ${_titleController.text.trim()}',
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        photo: _selectedImage,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('রিপোর্ট সফলভাবে জমা দেওয়া হয়েছে'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
