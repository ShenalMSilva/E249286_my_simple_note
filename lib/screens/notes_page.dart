import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/note.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Note> notes = [];
  List<Note> filteredNotes = []; // List to hold filtered notes
  String searchQuery = ""; // To hold the search query

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    final List<Map<String, dynamic>> noteMaps = await dbHelper.getNotes();
    setState(() {
      notes = noteMaps.map((map) => Note.fromMap(map)).toList();
      filteredNotes = notes; // Initially, filtered notes are the same as all notes
    });
  }

  _filterNotes(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredNotes = notes; // If the query is empty, show all notes
      } else {
        filteredNotes = notes.where((note) {
          return note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.content.toLowerCase().contains(query.toLowerCase());
        }).toList(); // Filter notes based on title or content
      }
    });
  }

  _showNoteDialog({Note? note}) {
    final titleController = TextEditingController(text: note?.title);
    final contentController = TextEditingController(text: note?.content);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 640,
            height: 400,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  note == null ? 'Add Note' : 'Edit Note',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Check if the title is empty
                        if (titleController.text.isEmpty) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Title cannot be empty!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return; // Exit the function if the title is empty
                        }

                        if (note == null) {
                          await dbHelper.insertNote({
                            'title': titleController.text,
                            'content': contentController.text,
                          });
                        } else {
                          await dbHelper.updateNote({
                            'id': note.id,
                            'title': titleController.text,
                            'content': contentController.text,
                          });
                        }
                        _loadNotes();
                        Navigator.of(context).pop();
                      },
                      child: Text(note == null ? 'Add' : 'Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _deleteNote(int id) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User pressed Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User pressed Delete
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await dbHelper.deleteNote(id);
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Simple Note'),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 25,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            child: TextField(
              onChanged: _filterNotes,
              decoration: InputDecoration(
                hintText: 'Search your note...',
                hintStyle: const TextStyle(color: Colors.blueGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: const Color.fromRGBO(229, 245, 242, 1),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredNotes.length, // Use filtered notes
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              title: Text(note.title,
                style: const TextStyle(
                fontWeight: FontWeight.bold),),
              subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.fade),
              onTap: () => _showNoteDialog(note: note),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteNote(note.id!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}