import 'export.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Empêche l'orientation paysage
  ]).then((_) {
    runApp(const MyScanner());
  });
}

class MyScanner extends StatelessWidget {
  const MyScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Scanner",
      home: Scaffold(
        body: Stack(
          children: [
            // Image de fond
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/fond_violet.jpeg"),
                    fit: BoxFit.cover, // Coupe l'image et la centre
                  ),
                ),
              ),
            ),
            // Image superposée
            Center(
              child: Transform.translate(
                offset: const Offset(0, 8), // 50 pixels vers le bas
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage("assets/nmap_logo.png"), // Deuxième image
                      fit: BoxFit.contain, // Affiche l'image sans la déformer
                    ),
                  ),
                ),
              ),
            ),
            // Widget Scan ou autres widgets
            const Scan(),
          ],
        ),
      ),
    );
  }
}
