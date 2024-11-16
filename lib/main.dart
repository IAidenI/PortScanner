import 'export.dart';
import 'ihm/graphique.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Empêche l'orientation paysage
  ]).then((_) {
    runApp(const MyAvocados());
  });
}

class MyAvocados extends StatelessWidget {
  const MyAvocados({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "First App",
      home: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "assets/accueil.jpg"), // Mets une image de fond
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Elevage(),
          ],
        ),
      ),
    );
  }
}
