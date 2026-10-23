import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';

/// Yellow rounded square with the </> mark.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Text(
        '</>',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.codeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(code, style: codeTextStyle),
      ),
    );
  }
}

class YellowProgressBar extends StatelessWidget {
  const YellowProgressBar({super.key, required this.value, this.height = 8});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: AppColors.cardLight,
        color: AppColors.yellow,
      ),
    );
  }
}

/// Square tile with a short code for the course language.
class LanguageBadge extends StatelessWidget {
  const LanguageBadge({super.key, required this.language, this.size = 76});

  final String language;
  final double size;

  static const _short = {
    'Python': 'Py',
    'Dart': 'Dart',
    'JavaScript': 'JS',
    'HTML/CSS': '</>',
    'SQL': 'SQL',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(size * 0.14),
      ),
      child: Text(
        _short[language] ?? language.substring(0, min(3, language.length)),
        style: TextStyle(
          color: AppColors.yellow,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.28,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  static int min(int a, int b) => a < b ? a : b;
}

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              LanguageBadge(language: course.language),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(course.summary,
                        style: const TextStyle(
                            color: AppColors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    RatingText(rating: course.rating),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingText extends StatelessWidget {
  const RatingText({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.yellow),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1),
            style: const TextStyle(color: AppColors.grey, fontSize: 13)),
      ],
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 20,
    this.borderWidth = 0,
  });

  final AppUser? user;
  final double radius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: borderWidth > 0 ? AppColors.yellow : Colors.transparent,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.cardLight,
        child: Text(
          user?.initials ?? '?',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: radius * 0.7,
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped filter chip from the catalog wireframe.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.yellow : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
            color: selected ? AppColors.yellow : AppColors.border, width: 1.2),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : AppColors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small spinner used inside buttons while a request runs.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
