import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    
    
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        final doc = quill.Document.fromJson(jsonDecode(widget.note!.content));
        _quillController = quill.QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
      } catch (e) {
        _quillController = quill.QuillController.basic();
      }
    } else {
      _quillController = quill.QuillController.basic();
    }

    _titleController.addListener(_markAsChanged);
    _quillController.addListener(_markAsChanged);
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
  }

  Future<void> _insertImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final index = _quillController.selection.baseOffset;
      final length = _quillController.selection.extentOffset - index;
      _quillController.replaceText(index, length, quill.BlockEmbed.image(image.path), null);
    }
  }

  void _saveNote() {
    if (_titleController.text.isEmpty) return; 

    final provider = Provider.of<NoteProvider>(context, listen: false);
    final now = DateTime.now();
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    if (widget.note == null) {
      provider.addNote(Note(
        title: _titleController.text, content: contentJson,
        createdAt: now, updatedAt: now, colorHex: '', tags: '',
      ));
    } else {
      provider.updateNote(Note(
        id: widget.note!.id, title: _titleController.text, content: contentJson,
        colorHex: widget.note!.colorHex, tags: widget.note!.tags,
        createdAt: widget.note!.createdAt, updatedAt: now,
      ));
    }
    setState(() => _hasUnsavedChanges = false);
    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thay đổi chưa được lưu'),
        content: const Text('Bạn có muốn lưu lại các thay đổi trước khi rời đi không?'),
        
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        actions: [
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false), 
                  child: const Text('Bỏ qua', style: TextStyle(color: Colors.red, fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, null), 
                  child: const Text('Hủy', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _saveNote();
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F37C9),
                    padding: const EdgeInsets.symmetric(vertical: 8), // Ép padding nhỏ lại
                  ),
                  child: const Text('Lưu', style: TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          )
        ],
      ),
    );
    if (result == false) return true; 
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.maybePop(context)),
          title: Text(widget.note == null ? 'New Note' : 'Edit Note', style: const TextStyle(color: Colors.black)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F37C9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _saveNote,
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(DateFormat('MMMM dd, yyyy').format(DateTime.now()).toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                decoration: const InputDecoration(hintText: 'Enter Title...', hintStyle: TextStyle(color: Colors.black26), border: InputBorder.none),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              
                child: quill.QuillEditor.basic(
                  controller: _quillController,
                  config: const quill.QuillEditorConfig(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: quill.QuillSimpleToolbar(
                  controller: _quillController,
                  config: quill.QuillSimpleToolbarConfig(
                    showUndo: false, showRedo: false, showFontFamily: false, showFontSize: false, 
                    showStrikeThrough: false, showInlineCode: false, showColorButton: false, 
                    showBackgroundColorButton: false, showClearFormat: false, showHeaderStyle: false, 
                    showQuote: false, showCodeBlock: false, showIndent: false, showSearchButton: false, 
                    showSubscript: false, showSuperscript: false,
                    customButtons: [
                   quill.QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.image), 
                     onPressed: _insertImage,
                       )
                      ]
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