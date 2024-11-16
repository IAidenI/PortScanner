import '../export.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  bool isMenu = true; // Variable pour indiquer si on est dans le menu
  bool isScanning = false;
  bool showInfo = false;
  String ipAddress = "192.168.1.93";
  List<String> portOpen = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: isMenu
              ? Column(
                  mainAxisSize: MainAxisSize
                      .min, // Réduit la taille pour ajuster aux boutons
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isMenu = false; // Quitter le menu
                          isScanning = false; // Déclenchement du scan
                          showInfo = true;
                        });
                      },
                      child: const Text("Liste de tout les appareils"),
                    ),
                    const SizedBox(height: 20), // Espacement entre les boutons
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isMenu = false; // Quitter le menu
                          isScanning = true; // Déclenchement du scan
                          showInfo = false;
                        });

                        Scanner.reserCancelrequest();
                        //await Scanner.paralleleStart(ipAddress, 0, 65534, 20);
                        await Scanner.paralleleStart(ipAddress, 0, 500, 10);

                        setState(() {
                          isScanning = false;
                          portOpen = Scanner
                              .getPortOpen(); // Récupère la liste des ports ouvert
                          portOpen = portOpen
                              .toSet()
                              .toList(); // Supprime les doublons
                          showInfo = true;
                        });
                      },
                      child: const Text("Scan d'une IP"),
                    ),
                  ],
                )
              : isScanning
                  ? Stack(
                      children: [
                        // Rond de chargement centré
                        const Align(
                          alignment: Alignment
                              .center, // Garde le rond parfaitement centré
                          child: CircularProgressIndicator(
                              color: Colors.deepPurpleAccent),
                        ),
                        // Encadré blanc en haut avec le premier texte
                        Positioned(
                          top: 44,
                          left: 75,
                          right: 75,
                          child: Container(
                            height:
                                40, // Hauteur identique au FloatingActionButton mini
                            alignment: Alignment
                                .center, // Centre le contenu verticalement
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  20), // Bordure arrondie pour un style cohérent
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              "Scan en cours...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // Texte en bas de l'écran
                        const Positioned(
                          bottom: 40, // Positionnez le texte en bas
                          left: 16,
                          right: 16,
                          child: Text(
                            "Cette opération peut prendre du temps.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : showInfo
                      ? Center(
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min, // Ajuste la taille au contenu
                            children: [
                              Text(
                                "Appareil : $ipAddress",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ), // Texte au-dessus de l'encadré
                              const SizedBox(
                                  height:
                                      16), // Espacement entre le texte et l'encadré
                              SizedBox(
                                width: 180, // Largeur fixe
                                height: 200, // Hauteur fixe
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: SingleChildScrollView(
                                    // Ajout d'un défilement si nécessaire
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: portOpen.isNotEmpty
                                          ? portOpen
                                              .map((port) => Text(port))
                                              .toList()
                                          : const [Text("Aucun port ouverts.")],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Scan effectué en : ${((Scanner.getExecuteTime()?.inMinutes ?? 0) > 0) ? "${Scanner.getExecuteTime()?.inMinutes}m" : ((Scanner.getExecuteTime()?.inSeconds ?? 0) > 0) ? "${Scanner.getExecuteTime()?.inSeconds}s" : "${Scanner.getExecuteTime()?.inMilliseconds}ms"}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
        ),
        if (!isMenu) // Afficher le bouton de retour uniquement si on n'est pas dans le menu
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              mini: true, // Petit bouton
              onPressed: () {
                setState(() {
                  isMenu = true; // Revenir au menu
                  Scanner.cancelScan();
                });
              },
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              child: const Icon(Icons.arrow_back),
            ),
          ),
      ],
    );
  }
}
