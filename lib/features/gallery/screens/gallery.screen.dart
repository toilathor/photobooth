import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:th_photobooth/features/gallery/providers/gallery.provider.dart';
import 'package:th_photobooth/features/gallery/widgets/gallery_lightbox.dart';
import 'package:th_photobooth/features/gallery/widgets/gallery_message.dart';
import 'package:th_photobooth/i18n/strings.g.dart';

class GalleryScreen extends StatelessWidget {
  final String sectionId;
  final GalleryProvider? provider;

  const GalleryScreen({super.key, required this.sectionId, this.provider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => (provider ?? GalleryProvider())..load(sectionId),
      child: _GalleryView(sectionId: sectionId),
    );
  }
}

class _GalleryView extends StatelessWidget {
  final String sectionId;

  const _GalleryView({required this.sectionId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<GalleryProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          t.gallery.title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, GalleryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return GalleryMessage(
        icon: Icons.cloud_off_rounded,
        title: t.gallery.errorTitle,
        message: t.gallery.errorMessage,
        actionLabel: t.gallery.retry,
        onAction: () => provider.load(sectionId),
      );
    }
    if (provider.files.isEmpty) {
      return GalleryMessage(
        icon: Icons.photo_library_outlined,
        title: t.gallery.emptyTitle,
        message: t.gallery.emptyMessage,
      );
    }

    final horizontalPadding = MediaQuery.sizeOf(context).width < 600
        ? 12.0
        : 24.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 20),
      child: GalleryLightbox(
        files: provider.files,
        selectedIndex: provider.selectedIndex,
        onSelected: provider.select,
      ),
    );
  }
}
