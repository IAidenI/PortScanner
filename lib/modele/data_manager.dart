import '../export.dart';

class Manager {
  static final List<String> _saveKey = [
    "avocat_nom", // 0
    "avocat_etat", // 1
    "avocat_status", // 2
    "avocat_niveau", // 3
    "avocat_creation", // 4
    "avocat_joursVie", // 5
  ];

  static final List<String> _checkers = [
    "checker_bonNiveau", // 0
    "checker_lastDay", // 1
    "checker_joursEcoule", // 2
    "checker_probaPourri", // 3
    "checker_lastProbleme", // 4
    "checker_isProbleme", // 5
    "checker_pourri", // 6
  ];

  static Future<void> saveAvocat() async {
    print("### Save en cours... ###\n");
    final data = await SharedPreferences.getInstance();

    // Sauvegarde des données de l'avocat
    data.setString(_saveKey[0], Avocat.instance.getNom());
    data.setString(_saveKey[1], Avocat.instance.getEtat());
    data.setInt(_saveKey[2], Avocat.instance.getStatus());
    data.setInt(_saveKey[3], Avocat.instance.getNiveauEau());
    data.setString(
        _saveKey[4], Avocat.instance.getDateCreation()!.toIso8601String());
    data.setInt(_saveKey[5], Avocat.instance.getJoursVie());

    // Sauvegarde des données du jeu
    data.setInt(_checkers[0], Avocat.instance.getBonNiveau());
    data.setString(
        _checkers[1], Avocat.instance.getLastDay()!.toIso8601String());
    data.setInt(_checkers[2], Avocat.instance.getJoursEcoule());
    data.setInt(_checkers[3], Avocat.instance.getProbaPourri());
    data.setInt(_checkers[4], Avocat.instance.getLastProbleme());
    data.setBool(_checkers[5], Avocat.instance.getIsProbleme());
    data.setBool(_checkers[6], Avocat.instance.getPourri());
    // print(
    //    "### Ici : ${Avocat.instance.getNom()} / ${Avocat.instance.getEtat()} / ${Avocat.instance.getStatus()} / ${Avocat.instance.getNiveauEau()} / ${Avocat.instance.getDateCreation()} / ${Avocat.instance.getJoursVie()} / ${Avocat.instance.getLastDay()} / ${Avocat.instance.getJoursEcoule()} ###\n");
    print("### Save terminé ###\n");
    Avocat.instance.displayDebuggeur();
  }

  static Future<void> loadAvocat() async {
    final data = await SharedPreferences.getInstance();

    // Récupération des données
    String? nom = data.getString(_saveKey[0]);
    String? etat = data.getString(_saveKey[1]);
    int? status = data.getInt(_saveKey[2]);
    int? niveau = data.getInt(_saveKey[3]);
    String? creation = data.getString(_saveKey[4]);
    int? joursVie = data.getInt(_saveKey[5]);

    // Récupération données jeu
    int? bonNiveau = data.getInt(_checkers[0]);
    String? lastDay = data.getString(_checkers[1]);
    int? joursEcoule = data.getInt(_checkers[2]);
    int? probaPourri = data.getInt(_checkers[3]);
    int? nombreProbleme = data.getInt(_checkers[4]);
    bool? isProbleme = data.getBool(_checkers[5]);
    bool? pourri = data.getBool(_checkers[6]);
    //print(
    //    "### Ici : ${nom} / ${etat} / ${status} / ${niveau} / ${creation} / ${joursVie} / ${lastDay} / ${joursEcoule} ###\n");

    // Vérifie si la donnée est présente
    if (nom != null &&
        etat != null &&
        status != null &&
        niveau != null &&
        creation != null &&
        joursVie != null &&
        bonNiveau != null &&
        lastDay != null &&
        joursEcoule != null &&
        probaPourri != null &&
        nombreProbleme != null &&
        isProbleme != null &&
        pourri != null) {
      DateTime dateNow = DateTime.now();
      // Récupération des données de l'avocat
      Avocat.instance.setNom(nom);
      Avocat.instance.setEtat(etat);
      Avocat.instance.setStatus(status);
      Avocat.instance.setNiveauEau(niveau);
      Avocat.instance.setDateCreation(DateTime.parse(creation));
      Avocat.instance
          .setJoursVie(dateNow.difference(DateTime.parse(creation)).inDays);

      Avocat.instance.setBonNiveau(bonNiveau);
      Avocat.instance
          .setJoursEcoule(dateNow.difference(DateTime.parse(lastDay)).inDays);
      Avocat.instance.setProbaPourri(probaPourri);
      Avocat.instance.setLastProbleme(nombreProbleme);
      Avocat.instance.setIsProbleme(isProbleme);
      Avocat.instance.setPourri(pourri);
      currentImage = imageVerreVide;

      _lookConnexion(DateTime.parse(lastDay));
      print("#### Last day : '$dateNow' ###");
      Avocat.instance.setLastDay(dateNow);

      Avocat.instance.displayDebuggeur();
    }
  }

  static Future<void> delAvocat() async {
    final data = await SharedPreferences.getInstance();

    for (String key in _saveKey) {
      data.remove(key);
    }
  }

  static void _lookConnexion(DateTime lastDay) {
    if (Avocat.instance.getJoursEcoule() != 0) {
      // Met une autre valeur random pour bonNiveau tout les deux jours en fonction de la date de création
      if (Avocat.instance.getJoursVie() >= 2 &&
              Avocat.instance.getJoursVie() % 2 == 0 ||
          Avocat.instance.getJoursEcoule() >= 2) {
        Avocat.instance.setBonNiveau(Avocat.instance.getRandomBonNiveau());
      }

      // Si 2 jours inactif, basser l'eau de 10%, 3j --> 20% etc ...
      int ecoule = Avocat.instance.getJoursEcoule();
      if (ecoule > 2) {
        for (int i = ecoule; i > 1; i -= 2) {
          if (Avocat.instance.getNiveauEau() == 0) {
            break;
          }
          Avocat.instance.setNiveauEau(Avocat.instance.getNiveauEau() - 10);
        }
      }

      // Vérification de l'état de l'avocat
      Avocat.instance.calculProbaPourri();
      if (Avocat.instance.isPourri()) {
        print("\n#################################\n");
        print("#################################\n");
        print("#####                        ####\n");
        print("##### IL EST POURRIIIII !!!! ####\n");
        print("#####                        ####\n");
        print("#################################\n");
        print("#################################\n\n");
        Avocat.instance.setPourri(true);
      }

      // Regarde depuis combien de temps il n'y a pas eu de problèmes
      if (Avocat.instance.getIsProbleme()) {
        Avocat.instance.setLastProbleme(0);
      } else {
        Avocat.instance.setLastProbleme(Avocat.instance.getLastProbleme() + 1);
      }
    }
  }
}
