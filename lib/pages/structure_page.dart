import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../models/structure_model.dart';
import '../../providers/structure_provider.dart';

class StructurePage extends StatefulWidget {
  final int groupId;

  const StructurePage({
    super.key,
    required this.groupId,
  });

  @override
  State<StructurePage> createState() => _StructurePageState();
}

class _StructurePageState extends State<StructurePage> {
  final StructureProvider _provider = StructureProvider();
  final TransformationController _transformationController =
  TransformationController();
  final GlobalKey _captureKey = GlobalKey();

  double _scale = 1.0;
  bool _isLandscape = false;

  final Set<StructureModel> _selectedNodes = {};

  @override
  void initState() {
    super.initState();
    _loadStructure();
  }

  Future<void> _loadStructure() async {
    await _provider.fetchStructure(widget.groupId);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _transformationController.dispose();
    _provider.dispose();

    super.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _onNodeTap(StructureModel node) {
    if (node.pair != null) {
      return;
    }

    if (!node.pairable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anggota ini belum dapat dipasangkan.'),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedNodes.contains(node)) {
        _selectedNodes.remove(node);
        return;
      }

      if (_selectedNodes.length >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maksimal 2 anggota untuk dipasangkan.'),
          ),
        );
        return;
      }

      _selectedNodes.add(node);
    });
  }

  Future<void> _pairSelectedMembers() async {
    if (_selectedNodes.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih 2 anggota untuk dipasangkan.'),
        ),
      );
      return;
    }

    final selectedList = _selectedNodes.toList();
    final first = selectedList[0];
    final second = selectedList[1];

    if (!first.pairable || !second.pairable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya anggota yang dapat dipasangkan yang bisa dipilih.'),
        ),
      );
      return;
    }

    final structureProvider = context.read<StructureProvider>();

    final success = await structureProvider.pairMembers(
      groupId: widget.groupId,
      leftMemberId: first.user.id,
      rightMemberId: second.user.id,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {
        _selectedNodes.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil memasangkan anggota. Bonus Rp500.000 berhasil dibuat.'),
        ),
      );
    } else {
      final message = structureProvider.error ?? 'Gagal memasangkan anggota.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  void _zoomIn() {
    _setScale((_scale + 0.2).clamp(0.2, 2.5));
  }

  void _zoomOut() {
    _setScale((_scale - 0.2).clamp(0.2, 2.5));
  }

  void _setScale(double scale) {
    final matrix = Matrix4.identity();
    matrix.scale(scale, scale, 1.0);
    _transformationController.value = matrix;

    setState(() {
      _scale = scale;
    });
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();

    setState(() {
      _scale = 1.0;
    });
  }

  Future<void> _downloadStructure() async {
    try {
      final boundary =
      _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        final granted = await Gal.requestAccess();

        if (!granted) {
          if (mounted) {
            _showMessage('Izin akses galeri diperlukan.');
          }
          return;
        }
      }

      final name =
          'struktur_aganda_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}';

      await Gal.putImageBytes(
        bytes,
        name: name,
      );

      if (mounted) {
        _showMessage('Struktur berhasil disimpan ke galeri.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal menyimpan struktur.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _provider.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.aganda500,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1,
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Struktur Group',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Visualisasi hierarki & bonus pasangan',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _downloadStructure,
              tooltip: 'Simpan Gambar',
              icon: const Icon(
                Icons.file_download_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(data),
    );
  }

  Widget _buildBody(StructureResponseModel? data) {
    if (_provider.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.aganda500,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat struktur...',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_provider.error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _provider.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadStructure,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.aganda500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (data == null || data.structure == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 48,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(height: 12),
            Text(
              'Struktur belum tersedia.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _CanvasGridPainter(
              dotColor: const Color(0xFFCBD5E1).withValues(alpha: 0.4),
            ),
          ),
        ),
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.1,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(2000),
            constrained: false,
            child: RepaintBoundary(
              key: _captureKey,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(80),
                child: _StructureTree(
                  root: data.structure!,
                  selectedNodes: _selectedNodes,
                  onNodeTap: _onNodeTap,
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          left: 20,
          right: 20,
          bottom: _selectedNodes.isNotEmpty ? 84 : -100,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.checklist_rtl_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Terpilih: ${_selectedNodes.length}/2',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _selectedNodes.length == 2
                        ? _pairSelectedMembers
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      disabledBackgroundColor:
                      Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white38,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.link_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Pasangkan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedNodes.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: _buildControls(),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _controlButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onPressed: _zoomOut,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(_scale * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                _controlButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onPressed: _zoomIn,
                ),
                Container(
                  height: 18,
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                ),
                _controlButton(
                  icon: Icons.center_focus_strong_rounded,
                  tooltip: 'Reset Tampilan',
                  onPressed: _resetView,
                ),
                _controlButton(
                  icon: _isLandscape
                      ? Icons.screen_lock_portrait_rounded
                      : Icons.screen_rotation_rounded,
                  tooltip: 'Ubah Orientasi',
                  onPressed: _toggleOrientation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        splashRadius: 18,
        icon: Icon(
          icon,
          size: 20,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}

class _CanvasGridPainter extends CustomPainter {
  final Color dotColor;

  _CanvasGridPainter({
    required this.dotColor,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = dotColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const double spacing = 28.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          1.2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}

class _StructureTree extends StatelessWidget {
  final StructureModel root;
  final Set<StructureModel> selectedNodes;
  final ValueChanged<StructureModel> onNodeTap;

  const _StructureTree({
    required this.root,
    required this.selectedNodes,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TreeNode(
      data: root,
      selectedNodes: selectedNodes,
      onNodeTap: onNodeTap,
    );
  }
}

class _TreeNode extends StatelessWidget {
  final StructureModel data;
  final Set<StructureModel> selectedNodes;
  final ValueChanged<StructureModel> onNodeTap;

  const _TreeNode({
    required this.data,
    required this.selectedNodes,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StructureNode(
          data: data,
          width: 230,
          height: 145,
          isSelected: selectedNodes.contains(data),
          onTap: () => onNodeTap(data),
        ),
        if (data.children.isNotEmpty) ...[
          Container(
            width: 2,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          _ChildrenRow(
            children: data.children,
            selectedNodes: selectedNodes,
            onNodeTap: onNodeTap,
          ),
        ],
      ],
    );
  }
}

class _ChildrenRow extends StatelessWidget {
  final List<StructureModel> children;
  final Set<StructureModel> selectedNodes;
  final ValueChanged<StructureModel> onNodeTap;

  const _ChildrenRow({
    required this.children,
    required this.selectedNodes,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    const double childWidth = 230;
    const double childGap = 28;

    final totalWidth = children.isEmpty
        ? 0.0
        : (children.length * childWidth) +
        ((children.length - 1) * childGap);

    final List<Map<String, dynamic>> pairs = [];

    for (int i = 0; i < children.length; i++) {
      final pair1 = children[i].pair;

      if (pair1 != null) {
        final targetIndex = children.indexWhere((c) {
          if (c == children[i]) {
            return false;
          }

          final pair2 = c.pair;

          if (pair2 != null &&
              pair1.id != 0 &&
              pair1.id == pair2.id) {
            return true;
          }

          return c.user.id == pair1.leftMemberId ||
              c.user.id == pair1.rightMemberId;
        });

        if (targetIndex > i) {
          pairs.add({
            'from': i,
            'to': targetIndex,
          });
        }
      }
    }

    return SizedBox(
      width: totalWidth,
      height: _calculateHeight(children),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(
              totalWidth,
              24,
            ),
            painter: _ChildrenConnectorPainter(
              childCount: children.length,
              childWidth: childWidth,
              childGap: childGap,
            ),
          ),
          for (final pair in pairs)
            Builder(
              builder: (context) {
                final int fromIndex = pair['from'];
                final int toIndex = pair['to'];

                final double x1 =
                    fromIndex * (childWidth + childGap) +
                        (childWidth / 2);

                final double x2 =
                    toIndex * (childWidth + childGap) +
                        (childWidth / 2);

                final double middleX = (x1 + x2) / 2;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: x1,
                      top: 12,
                      width: x2 - x1,
                      height: 2,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFF59E0B),
                              Color(0xFFD97706),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFF59E0B),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: middleX - 36,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF59E0B),
                              Color(0xFFD97706),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.shade900.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.link_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text(
                              '500RB',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          for (var index = 0; index < children.length; index++)
            Positioned(
              left: index * (childWidth + childGap),
              top: 24,
              width: childWidth,
              child: _TreeNode(
                data: children[index],
                selectedNodes: selectedNodes,
                onNodeTap: onNodeTap,
              ),
            ),
        ],
      ),
    );
  }

  double _calculateHeight(
      List<StructureModel> children,
      ) {
    if (children.isEmpty) {
      return 0;
    }

    double maxHeight = 0;

    for (final child in children) {
      final height = _treeHeight(child);

      if (height > maxHeight) {
        maxHeight = height;
      }
    }

    return 24 + maxHeight;
  }

  double _treeHeight(
      StructureModel node,
      ) {
    if (node.children.isEmpty) {
      return 145;
    }

    double maxChildHeight = 0;

    for (final child in node.children) {
      final height = _treeHeight(child);

      if (height > maxChildHeight) {
        maxChildHeight = height;
      }
    }

    return 145 + 24 + maxChildHeight;
  }
}

class _ChildrenConnectorPainter extends CustomPainter {
  final int childCount;
  final double childWidth;
  final double childGap;

  _ChildrenConnectorPainter({
    required this.childCount,
    required this.childWidth,
    required this.childGap,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    if (childCount == 0) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centers = <double>[];

    for (var index = 0; index < childCount; index++) {
      final left = index * (childWidth + childGap);

      centers.add(
        left + childWidth / 2,
      );
    }

    if (childCount == 1) {
      canvas.drawLine(
        Offset(centers.first, 0),
        Offset(centers.first, 24),
        paint,
      );

      return;
    }

    final firstCenter = centers.first;
    final lastCenter = centers.last;

    const middleY = 0.0;

    canvas.drawLine(
      Offset(firstCenter, middleY),
      Offset(lastCenter, middleY),
      paint,
    );

    for (final center in centers) {
      canvas.drawLine(
        Offset(center, 0),
        Offset(center, 24),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _ChildrenConnectorPainter oldDelegate,
      ) {
    return oldDelegate.childCount != childCount ||
        oldDelegate.childWidth != childWidth ||
        oldDelegate.childGap != childGap;
  }
}

class _StructureNode extends StatelessWidget {
  final StructureModel data;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback onTap;

  const _StructureNode({
    required this.data,
    required this.width,
    required this.height,
    this.isSelected = false,
    required this.onTap,
  });

  String _initial(String name) {
    if (name.trim().isEmpty) {
      return '?';
    }

    final parts = name.trim().split(' ');

    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  /// Helper untuk mengekstrak dan memformat URL Avatar secara aman
  String? _getValidAvatarUrl() {
    try {
      final dynamic user = data.user;
      if (user == null) return null;

      // Mencari properti avatar, avatarUrl, atau photo
      String? rawAvatar;

      try {
        rawAvatar = user.avatarUrl;
      } catch (_) {}

      if (rawAvatar == null || rawAvatar.isEmpty) {
        try {
          rawAvatar = user.avatar;
        } catch (_) {}
      }

      if (rawAvatar == null || rawAvatar.isEmpty) {
        return null;
      }

      final value = rawAvatar.toString().trim();

      if (value.isEmpty || value.toLowerCase() == 'null') {
        return null;
      }

      // Jika URL sudah merupakan URL lengkap (http/https)
      if (value.startsWith('http://') || value.startsWith('https://')) {
        return value;
      }

      // Jika path dari storage Laravel / API backend
      String baseUrl = AppConfig.storageUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      String cleanPath = value;
      if (cleanPath.startsWith('/storage/')) {
        cleanPath = cleanPath.substring(9);
      } else if (cleanPath.startsWith('storage/')) {
        cleanPath = cleanPath.substring(8);
      } else if (cleanPath.startsWith('/')) {
        cleanPath = cleanPath.substring(1);
      }

      final finalUrl = '$baseUrl/$cleanPath';
      return finalUrl;
    } catch (e) {
      debugPrint('Error parsing avatar URL: $e');
      return null;
    }
  }

  Widget _buildAvatar(List<Color> fallbackGradient) {
    final avatarUrl = _getValidAvatarUrl();

    // Print ke console untuk memeriksa apakah URL berhasil terbentuk
    if (avatarUrl != null) {
      debugPrint('Loading Avatar for ${data.user.name}: $avatarUrl');
    }

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            avatarUrl,
            width: 38,
            height: 38,
            fit: BoxFit.cover,
            // Header opsional jika server API membutuhkan Authorization/User-Agent
            headers: const {
              'Accept': 'image/*',
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFFF1F5F9),
                child: const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.aganda500,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Failed to load avatar image [$avatarUrl]: $error');
              return _buildDefaultAvatar(fallbackGradient);
            },
          ),
        ),
      );
    }

    return _buildDefaultAvatar(fallbackGradient);
  }

  Widget _buildDefaultAvatar(List<Color> gradientColors) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          _initial(data.user.name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = data.type == 'owner';
    final isUpline = data.type == 'upline';
    final isPaired = data.pair != null;

    final avatarGradient = isSelected
        ? [
      const Color(0xFF10B981),
      const Color(0xFF059669),
    ]
        : isOwner
        ? [
      const Color(0xFFF43F5E),
      Colors.red.shade600,
    ]
        : isUpline
        ? [
      Colors.indigo.shade400,
      Colors.indigo.shade600,
    ]
        : [
      const Color(0xFF475569),
      const Color(0xFF1E293B),
    ];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : isOwner
                ? const Color(0xFFFDA4AF)
                : isUpline
                ? Colors.indigo.shade200
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _buildAvatar(avatarGradient),
                    if (isSelected)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? Colors.redAccent.shade100.withValues(alpha: 0.2)
                              : isUpline
                              ? Colors.indigo.shade50
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOwner
                              ? 'Ketua Group'
                              : isUpline
                              ? 'Upline'
                              : 'Anggota',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: isOwner
                                ? Colors.redAccent.shade700
                                : isUpline
                                ? Colors.indigo.shade700
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 12,
              thickness: 1,
              color: Color(0xFFF1F5F9),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isPaired
                          ? Icons.link_rounded
                          : Icons.link_off_rounded,
                      size: 14,
                      color: isPaired
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaired ? 'Berpasangan' : 'Belum Berpasangan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isPaired
                            ? const Color(0xFF059669)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (data.pair != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.amber.shade200,
                      ),
                    ),
                    child: Text(
                      'Bonus Active',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
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