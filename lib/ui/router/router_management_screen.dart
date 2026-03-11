import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_models/router_view_model.dart';
import '../../../domain/models/router_model.dart';
import '../core/widgets/desktop_page_wrapper.dart';
import '../core/widgets/responsive_layout.dart';
import '../core/widgets/responsive_max_width.dart';
import 'widgets/router_form_sheet.dart';

class RouterManagementScreen extends GetView<RouterViewModel> {
  const RouterManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A1118);
    const cardColor = Color(0xFF131E29);
    const accentColor = Color(0xFF00C2FF);

    return DesktopPageWrapper(
      child: Scaffold(
        backgroundColor: bgColor,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            controller.prepareCreate();
            Get.bottomSheet(
              const RouterFormSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
          backgroundColor: accentColor,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Tambah Router',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, accentColor),
              Expanded(
                child: ResponsiveMaxWidth(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildListHeader(accentColor),
                        const SizedBox(height: 16),
                        _buildRouterList(accentColor, cardColor),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (ResponsiveLayout.isMobile(context))
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Router',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'MIKROTIK CONFIGURATION',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: accentColor.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ROUTER TERSIMPAN',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              '${controller.routers.length} Unit',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouterList(Color accentColor, Color cardColor) {
    return Obx(() {
      if (controller.isLoading.value && controller.routers.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.routers.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Belum ada router tersimpan',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ),
        );
      }
      final isDesktop = ResponsiveLayout.isDesktop(Get.context!);
      if (isDesktop) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.routers.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 480,
            mainAxisExtent: 180,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final router = controller.routers[index];
            return _buildRouterCard(context, router, accentColor, cardColor);
          },
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.routers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final router = controller.routers[index];
          return _buildRouterCard(context, router, accentColor, cardColor);
        },
      );
    });
  }

  Widget _buildRouterCard(
    BuildContext context,
    RouterModel router,
    Color accentColor,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.router,
                  color: Color(0xFF00C2FF),
                  size: 24,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: router.statusRouter == 'aktif'
                        ? const Color(0xFF4ADE80)
                        : Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  router.namaRouter,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: ResponsiveLayout.isDesktop(context) ? null : 1,
                  overflow: ResponsiveLayout.isDesktop(context)
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  router.alamatIp,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: accentColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (router.keterangan.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"${router.keterangan}"',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildActionIcon(Icons.sensors_outlined, () {
            controller.pingRouter(router.id);
          }, const Color(0xFF00C2FF).withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          _buildActionIcon(Icons.edit_outlined, () {
            controller.prepareEdit(router);
            Get.bottomSheet(
              const RouterFormSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          }, Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: 8),
          _buildActionIcon(
            Icons.delete_outline,
            () => _showDeleteDialog(router),
            Colors.redAccent.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _showDeleteDialog(RouterModel router) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF131E29),
        title: const Text(
          'Hapus Router',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus router "${router.namaRouter}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteRouter(router.id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
