import '../export.dart';

class Elevage extends StatefulWidget {
  const Elevage({super.key});

  @override
  ElevageState createState() => ElevageState();
}

class ElevageState extends State<Elevage> {
  final TextEditingController _textController = TextEditingController();

  /*
      =-=-=-=-=-=-=-=-=-
      = INITIALISATION =
      =-=-=-=-=-=-=-=-=-
  */

  @override
  void initState() {
    super.initState();
    _miseAJour();
  }

  // Charge les données et met a jours l'interface
  Future<void> _miseAJour() async {
    await Manager.loadAvocat(); // Charge les données
    setState(() {});
  }

  /*
      =-=-=-=-=-=-=-=-=-=-=-=
      = BOITES DE DIALOGUES =
      =-=-=-=-=-=-=-=-=-=-=-=
  */

  // Boite de dialogue pour la saisie du nom de l'avocat
  Future<String?> _getNom() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Saisir un nom'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: 'Saisissez votre texte ici',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Ferme la boîte de dialogue sans rien faire
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_textController
                    .text); // Retourne la saisie à la fermeture de la boîte de dialogue
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Boite de dialogue pour afficher un message
  void _afficheInfo(String titre, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titre),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le popup
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Boite de dialogue pour demander confirmation de suppression
  Future<bool?> _verificationSuppression() async {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirmation"),
            content: const Text("T'es sûr de vouloir l'assassiner ?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Renvoie false si le choix est non
                  },
                  child: const Text("Non")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Renvoie true si le choix est oui
                  },
                  child: const Text("Oui")),
            ],
          );
        });
  }

  /* 
      =-=-=-=-=-=-=
      = INTERFACE =
      =-=-=-=-=-=-=
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Elevage d'avocats"),
        backgroundColor:
            const Color.fromARGB(245, 245, 220, 186).withOpacity(0.0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
                Icons.refresh), // Bouton pour rafraichir les informations
            onPressed: () async {
              if (Avocat.instance.getNom().isNotEmpty) {
                await Manager.saveAvocat();
                Avocat.instance.supprimer();
                await Manager.loadAvocat();
                setState(() {});
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(245, 245, 220, 186),
              ),
              child: Text(
                "Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            /*
              * Bouton Adoption
            */
            ListTile(
              title: const Text("Adoption"),
              onTap: () {
                Navigator.pop(context);
                if (Avocat.instance.getNom().isEmpty) {
                  _adopte();
                } else {
                  _afficheInfo("Non Non Non", "Tu as déjà un avocat");
                }
              },
            ),
            /*
              * Bouton Ajout de l'eau
            */
            ListTile(
              title: const Text("Ajouter de l'eau"),
              onTap: () async {
                Navigator.pop(context);
                if (Avocat.instance.getNom().isEmpty) {
                  _afficheInfo(
                      "Bah t'as pas d'avocat", "Peu pas ajouter de l'eau moi");
                } else {
                  setState(() {
                    if (Avocat.instance.ajouterEau()) {
                      _afficheInfo("Bah ouais logique",
                          "T'as fait déborder le verre, c'est content ?");
                    }
                  });
                  await Manager.saveAvocat();
                }
              },
            ),
            /*
              * Bouton Enlever l'eau
            */
            ListTile(
              title: const Text("Enlever l'eau"),
              onTap: () async {
                Navigator.pop(context);
                if (Avocat.instance.getNom().isEmpty) {
                  _afficheInfo(
                      "Bah t'as pas d'avocat", "Peu pas enlever de l'eau moi");
                } else {
                  setState(() {
                    if (!Avocat.instance.enleverEau()) {
                      _afficheInfo("Huuum",
                          "Je retire quoi au juste ? Le verre ? La terre ?");
                    }
                  });
                  await Manager.saveAvocat();
                }
              },
            ),
            /*
              * Bouton mettre à niveau
            */
            ListTile(
              title: const Text("Mettre l'eau à niveau"),
              onTap: () async {
                Navigator.pop(context);
                if (Avocat.instance.getNom().isEmpty) {
                  _afficheInfo(
                      "Bah t'as pas d'avocat", "Peut pas ajouter de l'eau moi");
                } else {
                  setState(() {
                    if (!Avocat.instance.mettreAuNiveau()) {
                      _afficheInfo(
                          "Ah bah non", "C'est un peu trop tard pour faire ça");
                    }
                  });
                  await Manager.saveAvocat();
                }
              },
            ),
            /*
              * Bouton suppression de l'avocat
            */
            ListTile(
              title: const Text("L'assassiner"),
              onTap: () async {
                Navigator.pop(context);
                if (Avocat.instance.getNom().isEmpty) {
                  _afficheInfo("Bah ma belle",
                      "Il n'y a rien a assassiner pour me moment");
                } else {
                  bool? check = await _verificationSuppression();
                  if (check == true) {
                    setState(() {
                      Avocat.instance.supprimer();
                      currentImage = null;
                      Manager.delAvocat();
                    });
                  }
                }
              },
            ),
            ListTile(
              title: const Text("Debuggeur"),
              onTap: () {
                Navigator.pop(context);
                Avocat.instance.displayDebuggeur();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            /*
              * Insertion de l'image
            */
            child: Padding(
              padding: const EdgeInsets.only(top: 200),
              child: currentImage == null
                  ? const SizedBox.shrink()
                  : Image.asset(
                      currentImage!,
                      width: 110,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
            ),
            /*child: Padding(
              padding: const EdgeInsets.only(top: 200),
              child: currentImage == null
                  ? const SizedBox.shrink()
                  : FractionallySizedBox(
                      widthFactor: 0.6, // 40% de la largeur d'origine
                      heightFactor: 0.6, // 40% de la hauteur d'origine
                      child: Image.asset(
                        currentImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),*/
          ),
          /*
            * Insertion du bandeau d'informations sur l'avocat
          */
          if (Avocat.instance.getNom().isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nom: ${Avocat.instance.getNom()}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("État: ${Avocat.instance.getEtat()}"),
                    Text(
                        "Evolution de l'avocat: ${Avocat.instance.getStatus()}%"),
                    Text(
                        "Date de création: ${Avocat.instance.getDateCreation()?.toLocal().toString().split(' ')[0] ?? 'Inconnue'}"),
                    Text("Niveau d'eau: ${Avocat.instance.getNiveauEau()}%"),
                    Text("Bon niveau: ${Avocat.instance.getBonNiveau()}%"),
                    Text("Jours écoulé: ${Avocat.instance.getJoursEcoule()}"),
                    Text("temp: ${Avocat.instance.getLastDay()}"),
                    Text("Jours en vie: ${Avocat.instance.getJoursVie()}"),
                    Text("Proba Pourri: ${Avocat.instance.getProbaPourri()}"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /*
      =-=-=-=-=-
      = DIVERS =
      =-=-=-=-=-
  */

  // Pour adopter l'avocat
  void _adopte() async {
    String? nom = await _getNom();
    if (nom != null && nom.isNotEmpty) {
      setState(() {
        Avocat.instance.setNom(nom); // Définit le nom de l'avocat
        currentImage = imageVerreVide;
        Avocat.instance.setLastDay(Avocat.instance.getDateCreation());
      });
      await Manager
          .saveAvocat(); // Sauvegarde de l'avocat avec les nouvelles informations
    }
  }
}
