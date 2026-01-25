import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat_learning_app/src/theme/app_theme.dart';

class BrandStyleGuideScreen extends StatelessWidget {
  const BrandStyleGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.sacredCream,
      appBar: AppBar(
        title: const Text('Brand Style Guide'),
        backgroundColor: AppTheme.sacredCream,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Typography (Ilm System)'),
            const SizedBox(height: 16),
            _buildTypographyDemo(context),
            const SizedBox(height: 32),
            
            _buildSectionTitle('2. Color Palette (Mishkat Palette)'),
            const SizedBox(height: 16),
            _buildColorPalette(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('3. Iconography'),
            const SizedBox(height: 16),
            _buildIconography(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('4. Components'),
            const SizedBox(height: 16),
            _buildComponents(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepEmerald,
          ),
        ),
        const Divider(color: AppTheme.deepEmerald, thickness: 2),
      ],
    );
  }

  Widget _buildTypographyDemo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Primary Heading (Montserrat Bold 32)',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Secondary Heading (Montserrat Bold 24)',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Body Text (Inter Regular 16) - The typography is designed to balance modern digital readability with the elegance of traditional Islamic scholarship.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.sacredCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.radiantGold.withValues(alpha: 0.3)),
              ),
              child: Text(
                '“The most complete gift of God is a life based on knowledge.” (Amiri 20)',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildColorSwatch('Deep Emerald', AppTheme.deepEmerald, '#06402B', Colors.white),
            _buildColorSwatch('Radiant Gold', AppTheme.radiantGold, '#D4AF37', Colors.black),
            _buildColorSwatch('Sacred Cream', AppTheme.sacredCream, '#F9F7F2', Colors.black, hasBorder: true),
            _buildColorSwatch('Slate Grey', AppTheme.slateGrey, '#2D3436', Colors.white),
          ],
        );
      },
    );
  }

  Widget _buildColorSwatch(String name, Color color, String hex, Color textColor, {bool hasBorder = false}) {
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: hasBorder ? Border.all(color: Colors.grey.shade300) : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(name, style: GoogleFonts.roboto(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(hex, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildIconography() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconSample(Icons.lightbulb_outline, 'Mishkat Icon'),
        _buildIconSample(Icons.book_outlined, 'Course Icon'),
        _buildIconSample(Icons.person_outline, 'User Icon'),
        _buildIconSample(Icons.play_circle_outline, 'Lesson Icon'),
      ],
    );
  }

  Widget _buildIconSample(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepEmerald.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppTheme.radiantGold, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.slateGrey)),
      ],
    );
  }

  Widget _buildComponents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Primary Button'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Secondary Button'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepEmerald.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.radiantGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card Component', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Soft shadows give a "lifted" feel.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
