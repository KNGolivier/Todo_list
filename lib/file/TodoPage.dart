import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Todopage extends StatefulWidget {
  const Todopage({super.key});

  @override
  State<Todopage> createState() => _TodopageState();
}

class _TodopageState extends State<Todopage> {
  final TextEditingController _taskController = TextEditingController();
  List _tasks = [];

  // L'URL de base de l'API
  final String apiUrl = 'https://todolist-api-production-1e59.up.railway.app';

  // Fonction pour récupérer les tâches depuis l'API
  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse('$apiUrl/tasks'));
    if (response.statusCode == 200) {
      setState(() {
        _tasks = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Fonction pour ajouter une tâche
  Future<void> addTask(String title) async {
    final response = await http.post(
      Uri.parse('$apiUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title}),
    );
    if (response.statusCode == 201) {
      _taskController.clear();
      fetchTasks();
    } else {
      throw Exception('Ajout de tâche échoué');
    }
  }

  // Fonction pour modifier une tâche
  Future<void> updateTask(int id, String title) async {
    final response = await http.put(
      Uri.parse('$apiUrl/tasks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title}),
    );
    if (response.statusCode == 200) {
      fetchTasks();
    } else {
      throw Exception('Modification de tâche échoué');
    }
  }

  // Fonction pour supprimer une tâche
  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/tasks/$id'));
    if (response.statusCode == 200) {
      fetchTasks();
    } else {
      throw Exception('Suppression de la tâche échoué');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todolist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Nom de la tâche',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                addTask(_taskController.text);
              },
              child: Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Liste des tâches',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    leading: const Icon(Icons.circle, color: Colors.green),
                    title: Text(task['title']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.purple),
                          onPressed: () {
                            _taskController.text = task['title'];
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Modifier la tâche'),
                                content: TextField(
                                  controller: _taskController,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      updateTask(
                                          task['id'], _taskController.text);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Enregistrer'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteTask(task['id']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
