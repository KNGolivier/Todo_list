import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:todapi/file/TodoPage.dart';

class Connexionpage extends StatefulWidget {
  Connexionpage({super.key});

  @override
  State<Connexionpage> createState() => _ConnexionpageState();
}

class _ConnexionpageState extends State<Connexionpage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    // Récupérer les informations stockées dans SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('userEmail');
    String? storedPassword = prefs.getString('userPassword');

    // Vérifiez si les informations correspondent à celles stockées
    if (email == storedEmail && password == storedPassword) {
      // Utilisez l'API pour authentifier l'utilisateur
      final String apiUrl =
          'https://todolist-api-production-1e59.up.railway.app/auth/login';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email, "password": password}),
        );

        if (response.statusCode == 200) {
          // Authentification réussie
          final data = jsonDecode(response.body);

          // Stockez le token ou d'autres informations si nécessaire
          await prefs.setString('userToken', data['token']);

          // Naviguez vers la page d'accueil
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Todopage()),
          );
        } else {
          // Gérer les erreurs de connexion
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de la connexion')),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion')),
        );
      }
    } else {
      // Si les informations ne correspondent pas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email ou mot de passe incorrect')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Todolist",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Email"),
              TextField(
                controller: emailController,
              ),
              const SizedBox(height: 30),
              const Text("Mot de passe"),
              TextField(
                controller: passwordController,
                obscureText: true, // cache le mot de passe
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: login, // Appelle la fonction de connexion
                  child: const Text("Connexion"),
                ),
              ),
            ],
          ),
        ));
  }
}
