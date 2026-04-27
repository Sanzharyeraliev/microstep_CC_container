import 'package:flutter/material.dart';
import '../../design_system.dart';
import '../../core/services/database_service.dart';
import 'set_screen.dart';

class FolderScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const FolderScreen({super.key, this.onMenuTap});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final DatabaseService _db = DatabaseService();
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = true;
  String? _hoveredFolderId;
  bool _isAddingFolder = false;
  final TextEditingController _folderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);
    final foldersWithSets = await _db.getAllFoldersWithSets();
    setState(() {
      _folders = foldersWithSets;
      _isLoading = false;
    });
  }

  Future<void> _addFolder() async {
    setState(() => _isAddingFolder = true);
  }

  Future<void> _saveFolder() async {
    final name = _folderNameController.text.trim();
    if (name.isEmpty) return;

    await _db.insertFolder({
      'id': 'folder_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _loadFolders();
    setState(() {
      _isAddingFolder = false;
      _folderNameController.clear();
    });
  }

  void _openFolder(Map<String, dynamic> folder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SetScreen(folderId: folder['id'], folderName: folder['name']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          const SizedBox(height: 32),
          ..._folders.map((folder) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildFolderCard(folder),
          )),
          if (_isAddingFolder) _buildAddFolderCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    int totalSets = 0;
    int totalCards = 0;
    for (final folder in _folders) {
      final sets = folder['sets'] as List;
      totalSets += sets.length;
      for (final set in sets) {
        final cardIds = (set['card_ids'] as String).split(',');
        if (cardIds.isNotEmpty && cardIds[0].isNotEmpty) {
          totalCards += cardIds.length;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Collections',
          style: TextStyle(fontSize: 44, fontWeight: FontWeight.w200, letterSpacing: -0.5, color: Color(0xFF2D3338)),
        ),
        const SizedBox(height: 8),
        Text(
          '$totalSets sets • $totalCards flashcards',
          style: const TextStyle(fontSize: 16, color: Color(0xFF596065)),
        ),
      ],
    );
  }

  Widget _buildFolderCard(Map<String, dynamic> folder) {
    final sets = folder['sets'] as List;
    final totalCards = sets.fold(0, (sum, set) {
      final ids = (set['card_ids'] as String).split(',');
      if (ids.isNotEmpty && ids[0].isNotEmpty) return sum + ids.length;
      return sum;
    });
    final progress = totalCards > 0 ? 0.0 : 0.0; // можно вычислить позже

    final isHovered = _hoveredFolderId == folder['id'];

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredFolderId = folder['id']),
      onExit: (_) => setState(() => _hoveredFolderId = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, isHovered ? -4 : 0),
        child: GestureDetector(
          onTap: () => _openFolder(folder),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isHovered ? 0.08 : 0.04),
                  blurRadius: isHovered ? 20 : 12,
                  offset: Offset(0, isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📁', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        folder['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2D3338)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFACB3B8)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${sets.length} sets • $totalCards cards',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF596065)),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E9EE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}% mastered',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddFolderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _folderNameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Folder name...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF2F4F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isAddingFolder = false;
                      _folderNameController.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveFolder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}