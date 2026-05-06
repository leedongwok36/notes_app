import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import 'note_editor_screen.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Color> _noteColors = [
    Colors.transparent, Colors.indigo, Colors.redAccent, Colors.green, Colors.orange, Colors.blueGrey
  ];

  void _navigateToEditor([Note? note]) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NoteEditorScreen(note: note)));
  }

  // --- HÌNH 5: DIALOG XÁC NHẬN XÓA ---
  void _showDeleteDialog(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Icon(Icons.delete_outline, color: Colors.red)),
            SizedBox(height: 16),
            Text('Delete this note?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('This action cannot be undone. This note will be permanently removed from your library.', textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.indigo)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Provider.of<NoteProvider>(context, listen: false).deleteNote(note.id!);
              Navigator.pop(context); // Tắt dialog
              Navigator.pop(context); // Tắt bottom sheet
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- HÌNH 4: BOTTOM SHEET SETTINGS (Long Press) ---
  void _showNoteSettings(Note note) {
    String currentColorHex = note.colorHex ?? '';
    List<String> currentTags = note.tags?.isNotEmpty == true ? note.tags!.split(',') : [];
    TextEditingController tagController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Note Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('NOTE COLOR', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: _noteColors.map((color) {
                      String hex = color == Colors.transparent ? '' : '#${color.value.toRadixString(16).substring(2, 8)}';
                      bool isSelected = currentColorHex == hex;
                      return GestureDetector(
                        onTap: () => setState(() => currentColorHex = hex),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: color == Colors.transparent ? Colors.white : color,
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? Colors.indigo : Colors.grey.shade300, width: isSelected ? 2 : 1),
                          ),
                          child: color == Colors.transparent ? const Icon(Icons.format_color_reset, size: 20, color: Colors.grey) : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('TAGS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: currentTags.map((tag) => Chip(
                      label: Text('#$tag', style: const TextStyle(color: Colors.indigo)),
                      backgroundColor: Colors.indigo.shade50,
                      deleteIconColor: Colors.indigo,
                      onDeleted: () => setState(() => currentTags.remove(tag)),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagController,
                          decoration: InputDecoration(
                            hintText: 'Enter tag name...',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(color: Colors.indigo.shade100, borderRadius: BorderRadius.circular(8)),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.indigo),
                          onPressed: () {
                            if (tagController.text.isNotEmpty) {
                              setState(() => currentTags.add(tagController.text.trim()));
                              tagController.clear();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F37C9), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Apply Changes', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            final updatedNote = Note(
                              id: note.id, title: note.title, content: note.content,
                              createdAt: note.createdAt, updatedAt: DateTime.now(),
                              colorHex: currentColorHex, tags: currentTags.join(','),
                            );
                            Provider.of<NoteProvider>(context, listen: false).updateNote(updatedNote);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Delete Note', style: TextStyle(color: Colors.red)),
                          onPressed: () => _showDeleteDialog(note),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- GIAO DIỆN CHÍNH (HÌNH 1) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.indigo),
        title: const Text('Notes', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: const [Icon(Icons.search, color: Colors.indigo), SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search your thoughts...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Chip(label: const Text('Personal', style: TextStyle(color: Colors.indigo, fontSize: 12)), backgroundColor: Colors.indigo.shade50, side: BorderSide.none),
                    const SizedBox(width: 8),
                    Chip(label: const Text('Work', style: TextStyle(color: Colors.black54, fontSize: 12)), backgroundColor: Colors.grey.shade200, side: BorderSide.none),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Consumer<NoteProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.notes.length,
                  itemBuilder: (context, index) {
                    final note = provider.notes[index];
                    Color leftBorderColor = Colors.transparent;
                    if (note.colorHex != null && note.colorHex!.isNotEmpty) {
                      leftBorderColor = Color(int.parse(note.colorHex!.replaceFirst('#', '0xFF')));
                    }
                    List<String> tags = note.tags?.isNotEmpty == true ? note.tags!.split(',') : [];

                    return GestureDetector(
                      onTap: () => _navigateToEditor(note),
                      onLongPress: () => _showNoteSettings(note),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(width: 6, height: 120, decoration: BoxDecoration(color: leftBorderColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(note.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                        Text(DateFormat('MMM dd').format(note.updatedAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Mở để xem chi tiết...', style: const TextStyle(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis), // Quill data khó preview text thường
                                    if (tags.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: tags.map((t) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(4)),
                                          child: Text('#$t', style: const TextStyle(color: Colors.indigo, fontSize: 10, fontWeight: FontWeight.bold)),
                                        )).toList(),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F37C9),
        onPressed: () => _navigateToEditor(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Colors.indigo,
      ),
    );
  }
}