
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'task_model.dart' as model;
import 'auth_service.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();

  Future<void> _addTaskDialog() async {
    final titleController = TextEditingController();
    bool completed = false;
    bool shared = false;
    XFile? imageFile;
    DateTime? selectedDate;
    bool loading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final buttonTextStyle = const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5);
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.add_task, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text('Nueva tarea'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: completed,
                          activeColor: Colors.deepPurple,
                          onChanged: (v) => setState(() => completed = v ?? false),
                        ),
                        const Text('Completada'),
                        const SizedBox(width: 16),
                        Checkbox(
                          value: shared,
                          activeColor: Colors.deepPurple,
                          onChanged: (v) => setState(() => shared = v ?? false),
                        ),
                        const Text('Compartida'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            textStyle: buttonTextStyle,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) setState(() => imageFile = picked);
                          },
                          icon: const Icon(Icons.photo),
                          label: const Text('Galería'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            textStyle: buttonTextStyle,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.camera);
                            if (picked != null) setState(() => imageFile = picked);
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Cámara'),
                        ),
                      ],
                    ),
                    if (imageFile != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: FutureBuilder<Widget>(
                          future: () async {
                            final bytes = await imageFile?.readAsBytes();
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(bytes!, height: 80),
                            );
                          }(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return snapshot.data!;
                            }
                            return const SizedBox(height: 80);
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.deepPurple, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              textStyle: buttonTextStyle,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: now,
                                firstDate: DateTime(now.year - 5),
                                lastDate: DateTime(now.year + 5),
                              );
                              if (picked != null) setState(() => selectedDate = picked);
                            },
                            child: Text(selectedDate == null ? 'Seleccionar fecha' : selectedDate.toString().split(' ')[0]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          textStyle: buttonTextStyle,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          setState(() => loading = true);
                          String? imageBase64;
                          if (imageFile != null) {
                            final bytes = await imageFile!.readAsBytes();
                            imageBase64 = base64Encode(bytes);
                          }
                          await _firestore.collection('tasks').add({
                            'title': titleController.text,
                            'completed': completed,
                            'imageBase64': imageBase64,
                            'createdAt': selectedDate != null ? Timestamp.fromDate(selectedDate!) : Timestamp.now(),
                            'ownerId': _auth.currentUser!.uid,
                            'ownerEmail': _auth.currentUser!.email ?? '',
                            'shared': shared,
                            'completedBy': completed ? (_auth.currentUser!.email ?? '') : null,
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                      ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Stream<List<model.Task>> get _tasksStream async* {
    final uid = _auth.currentUser!.uid;
    await for (final _ in _firestore.collection('tasks').snapshots()) {
      final ownSnap = await _firestore
          .collection('tasks')
          .where('ownerId', isEqualTo: uid)
          .get();
      final sharedSnap = await _firestore
          .collection('tasks')
          .where('shared', isEqualTo: true)
          .get();
      final own = ownSnap.docs.map((d) => model.Task.fromMap(d.id, d.data())).toList();
      final shared = sharedSnap.docs.map((d) => model.Task.fromMap(d.id, d.data())).toList();
      final ids = own.map((e) => e.id).toSet();
      yield [...own, ...shared.where((e) => !ids.contains(e.id))];
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userEmail = _auth.currentUser?.email;
    int ownCount = 0;
    int sharedCount = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              onPressed: () async {
                await AuthService().signOut();
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE1BEE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userEmail != null)
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 8),
                child: Text(
                  '¡Bienvenido, $userEmail!',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                ),
              ),
            Expanded(
              child: StreamBuilder<List<model.Task>>(
                stream: _tasksStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tasks = snapshot.data ?? [];
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No hay tareas', style: TextStyle(fontSize: 20, color: Colors.deepPurple)));
                  }
                  final ownTasks = tasks.where((t) => t.ownerEmail == userEmail).toList();
                  final sharedTasks = tasks.where((t) => t.shared && t.ownerEmail != userEmail).toList();
                  ownCount = ownTasks.length;
                  sharedCount = sharedTasks.length;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (ownTasks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, left: 4),
                          child: Text('Tus tareas ($ownCount)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        ),
                      ...ownTasks.map((t) => _buildTaskCard(t, true)).toList(),
                      if (sharedTasks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                          child: Text('Tareas compartidas ($sharedCount)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                        ),
                      ...sharedTasks.map((t) => _buildTaskCard(t, false)).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard(model.Task t, bool isOwn) {
    Widget? leading;
    if (t.imageBase64 != null) {
      final bytes = base64Decode(t.imageBase64!);
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(bytes, width: 56, height: 56, fit: BoxFit.cover),
      );
    }
    return Dismissible(
      key: ValueKey(t.id),
      direction: isOwn ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: isOwn
          ? (direction) async {
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Eliminar tarea'),
                  content: const Text('¿Estás seguro de eliminar esta tarea?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
          : null,
      onDismissed: isOwn
          ? (direction) async {
              await _firestore.collection('tasks').doc(t.id).delete();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
            }
          : null,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: leading ?? const Icon(Icons.task_alt, color: Colors.deepPurple, size: 40),
          title: Text(
            t.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    t.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: t.completed ? Colors.green : Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.completed ? 'Completada' : 'Pendiente',
                    style: TextStyle(
                      color: t.completed ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text('Fecha: ${t.createdAt.toDate().toString().split(' ')[0]}', style: const TextStyle(fontSize: 13)),
              Text('Creada por: ${t.ownerEmail}', style: const TextStyle(fontSize: 13)),
              if (t.completed && t.completedBy != null)
                Text('Completada por: ${t.completedBy}', style: const TextStyle(fontSize: 13)),
            ],
          ),
          trailing: Checkbox(
            value: t.completed,
            activeColor: Colors.deepPurple,
            onChanged: (v) async {
              await _firestore.collection('tasks').doc(t.id).update({
                'completed': v,
                'completedBy': v == true ? (_auth.currentUser!.email ?? '') : null,
              });
            },
          ),
        ),
      ),
    );
  }
}
