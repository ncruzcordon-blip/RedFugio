import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:redfugio_frontend2/features/authentication/providers/auth_provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const SizedBox.expand(),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            heightFactor: 1,

            child: ElevatedButton.icon(

              onPressed: () => context.read<AuthProvider>().logout(),
              
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 151, 151, 1),
                foregroundColor: Colors.white,
              ),

              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              
            ),
          ),
        ),
      ),
    );
  }
}
