import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:todapi/file/ConnexionPage.dart';

class Createpage extends StatefulWidget {
  const Createpage({super.key});

  @override
  State<Createpage> createState() => _CreatepageState();
}

class _CreatepageState extends State<Createpage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    final String username = usernameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    // Remplacez cette URL par l'URL de votre API
    final String apiUrl =
        'https://todolist-api-production-1e59.up.railway.app/auth/inscription';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        // Si l'inscription est réussie
        final data = jsonDecode(response.body);

        // Enregistrez les informations de l'utilisateur dans SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('userEmail', email);
        await prefs.setString('userToken', data['token']);

        // Naviguer vers la page de connexion
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Connexionpage()),
        );
      } else {
        // Gérer les erreurs d'inscription
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la création du compte')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de création du compte')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer un compte")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: Text(
                "Créer ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
