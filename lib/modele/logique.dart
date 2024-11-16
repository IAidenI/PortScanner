import 'dart:math';

class Avocat {
  // Définition de l'instance unique du singleton
  static final Avocat _instance = Avocat._internal();

  // Variables de l'instance
  String _nom = "";
  String _etat =
      ""; // Etat possible : Excellent, Bon, Moyen, Mauvais, Pitoyable
  int _status = 0; // Niveau de développement (ira de 0 à 100)
  int _niveauEau = 0;
  late DateTime? _dateCreation;
  int _joursVie = 0;

  // Variables pour le jeu
  int _bonNiveau = 0;
  late DateTime? _lastDay;
  int _joursEcoule = 0; // Temps écoulé depuis la dernière connection (en jours)
  int _probaPourri = 0; // La probabilité que l'avocat soit pourri
  int _lastProbleme = 0; // Le nombres de jours sans incidents
  bool _isProbleme = false;
  bool _pourri = false;

  // Constructeur privé
  Avocat._internal() {
    // Initialisation des variables si nécessaire
    _initialize();
  }

  // Reinitialiser l'instance
  void supprimer() {
    _initialize();
  }

  // Initialise toutes les variables
  void _initialize() {
    _nom = "";
    _etat = "Excellent";
    _status = 0;
    _niveauEau = 0;
    _dateCreation = DateTime.now();
    _joursVie = 0;

    _bonNiveau = getRandomBonNiveau();
    _lastDay = null;
    _joursEcoule = 0;
    _probaPourri = 0;
    _lastProbleme = 0;
    _isProbleme = false;
  }

  void displayDebuggeur() {
    print("################################");
    print("#### Nom : '$_nom' ####");
    print("#### Etat : '$_etat' ####");
    print("#### Status : '$_status' ####");
    print("#### Niveau d'Eau : '$_niveauEau' ####");

    print(
        "#### Date de Création : '${_dateCreation?.toIso8601String() ?? 'null'}' ####");
    print("#### Jours de Vie : '$_joursVie' ####");

    print("#### Bon Niveau : '$_bonNiveau' ####");
    print(
        "#### Dernier Jour : '${_lastDay?.toIso8601String() ?? 'null'}' ####");
    print("#### Jours Ecoulé : '$_joursEcoule' ####");
    print("#### Probabilité de Pourrissement : '$_probaPourri' ####");
    print(
        "#### Nombre de jours depuis dernier problème : '$_lastProbleme' ####");
    print("#### Il y a un problème : '$_isProbleme' ####");
    print("################################");
  }

  // Méthode d'accès à l'instance unique
  static Avocat get instance => _instance;

  // Getters
  String getNom() => _nom;
  String getEtat() => _etat;
  int getStatus() => _status;
  int getNiveauEau() => _niveauEau;
  DateTime? getDateCreation() => _dateCreation;
  int getJoursVie() => _joursVie;

  int getBonNiveau() => _bonNiveau;
  DateTime? getLastDay() => _lastDay;
  int getJoursEcoule() => _joursEcoule;
  int getProbaPourri() => _probaPourri;
  int getLastProbleme() => _lastProbleme;
  bool getIsProbleme() => _isProbleme;
  bool getPourri() => _pourri;

  // Setters
  void setNom(String nom) => _nom = nom;
  void setEtat(String etat) => _etat = etat;
  void setStatus(int status) => _status = status;
  void setNiveauEau(int niveauEau) => _niveauEau = niveauEau;
  void setDateCreation(DateTime? dateCreation) => _dateCreation = dateCreation;
  void setJoursVie(int joursVie) => _joursVie = joursVie;

  void setBonNiveau(int bonNiveau) => _bonNiveau = bonNiveau;
  void setLastDay(DateTime? lastDay) => _lastDay = lastDay;
  void setJoursEcoule(int joursEcoule) => _joursEcoule = joursEcoule;
  void setProbaPourri(int probaPourri) => _probaPourri = probaPourri;
  void setLastProbleme(int nombreProbleme) => _lastProbleme = nombreProbleme;
  void setIsProbleme(bool isProbleme) => _isProbleme = isProbleme;
  void setPourri(bool pourri) => _pourri = pourri;

  // Récupère un nombr aléatoire entre 60 et 80 qui va correspondre au niveau à atteindre
  int getRandomBonNiveau() {
    final Random random = Random();
    final int variation = random.nextInt(21) - 10;
    return 70 + variation;
  }

  // Méthodes de jeu
  bool enleverEau() {
    if (_niveauEau == 0) {
      return false; // Ne peut pas retirer plus d'eau
    } else {
      _niveauEau = 0; // Enlève toute l'eau
      return true;
    }
  }

  bool ajouterEau() {
    if (_niveauEau >= 100) {
      return false; // Ne peut pas ajouter plus d'eau
    }
    _niveauEau += 10;
    if (_niveauEau > 100) {
      _niveauEau = 100;
      return true; // L'eau a débordé
    }
    return false; // L'eau a été ajoutée sans déborder
  }

  bool mettreAuNiveau() {
    if (_niveauEau > _bonNiveau) {
      return false; // Ne peut pas mettre à jours la niveau de l'eau car le niveau de l'eau est trop haut
    } else {
      _niveauEau += (70 - _niveauEau); // Met le niveau de l'eau au bon niveau
      return true;
    }
  }

  bool isPourri() {
    // Si il y a eu un problème le jours même ou la veille
    if (_lastProbleme < 2 &&
        DateTime.now().difference(_dateCreation!).inDays > 2) {
      int random =
          Random().nextInt(101); // Prend un nombre au hasard entre 1 et 100
      print("### Random = '$random' ###\n");
      if (random < _probaPourri) {
        if (_probaPourri <= 10) {
          // Laisse une nouvelle chance si la probabilité est très faible
          random = Random().nextInt(101);
          return _probaPourri <= random
              ? false
              : true; // Si le nombre aléatoire est plus petit que _probaPourri alors l'avocat est pourri
        }
        return true;
      } else {
        return false;
      }
    } else {
      _probaPourri -=
          2; // Si aucun problème on enlève 2 en probabilité qui correspond au maximum si l'utilisateur se connecte régulièrement
      if (_probaPourri < 0) {
        _probaPourri = 0;
      }
      return false;
    }
  }

  void calculProbaPourri() {
    int variable = 0;
    _isProbleme = false;

    // Si l'utilisateur s'est absenté plus de 2 jours
    if (_incident()) {
      if (_incidentMineur()) {
        // Si il s'est absenté moins de 4 jours alors petite proba
        variable = 1;
        _isProbleme = true;
      } else if (_incidentMoyen()) {
        // Si il s'est absenté moins de 6 jours alors moyenne proba
        variable = 2;
        _isProbleme = true;
      } else if (_incidentMajeur()) {
        // Si il s'est absenté moins de 8 jours grosse proba
        variable = 3;
        _isProbleme = true;
      } else {
        // Si il s'est absenté plus de 8 jours 100% de proba
        _probaPourri = 101;
        _isProbleme = false;
      }
    } else {
      _probaPourri += _calculbonNiveau();
      if (_probaPourri > 100) {
        _probaPourri = 100;
      }
    }

    if (_isProbleme) {
      _probaPourri += (variable + _calculbonNiveau());
      if (_probaPourri > 100) {
        _probaPourri = 100;
      }
    }

    // Changement de l'état en fonction de la probabilité
    _changeEtat();
  }

  int _calculbonNiveau() {
    /*
                                                  /\              /\
                                                  || Les Tranches ||
                                                  \/              \/
      [60 - 61 - 62 - 63 - 64] - [65 - 66 - 67 - 68 - 69] - [70 - 71 - 72 - 73 - 74] - [75 - 76 - 77 - 78 - 79 - 80]
             Tranche 1                   Tranche 2                   Tranche 3                    Tranche 4
      
      Valeurs possible pour _niveauEau :
      [60                                                70                                                      80]
    */

    // Si le bon niveau est dans la tranche 1
    if (_bonNiveau >= 60 && _bonNiveau <= 64) {
      // Si le niveau acctuel de l'eau est 60 donc dans la bonne tranche
      if (_niveauEau == 60) {
        return 0;
      }

      // Si le niveau acctuel de l'eau est 70 donc entre la tranche juste après
      if (_niveauEau == 70) {
        return 1;
      }

      // Si le niveau acctuel de l'eau est 80 donc dans la tranche la plus éloigné
      if (_niveauEau == 80) {
        return 2;
      }
    }

    // Si le bon niveau est dans la tranche 2
    if (_bonNiveau >= 65 && _bonNiveau <= 69) {
      // Si le niveau acctuel de l'eau est 60 donc dans la tranche juste avant
      if (_niveauEau == 60) {
        return 1;
      }

      // Si le niveau acctuel de l'eau est 70 donc dans la bonne tranche
      if (_niveauEau == 70) {
        return 0;
      }

      // Si le niveau acctuel de l'eau est 80 donc dans la tranche la plus éloigné
      if (_niveauEau == 80) {
        return 2;
      }
    }

    if (_bonNiveau == 70) {
      // Si le niveau acctuel de l'eau est 60 donc dans la tranche la plus éloigné
      if (_niveauEau == 60) {
        return 1;
      }

      // Si le niveau acctuel de l'eau est 70 donc dans la bonne tranche
      if (_niveauEau == 70) {
        return 0;
      }

      // Si le niveau acctuel de l'eau est 80 donc dans la tranche juste après
      if (_niveauEau == 80) {
        return 1;
      }
    }

    // Si le bon niveau est dans la tranche 3
    if (_bonNiveau >= 71 && _bonNiveau <= 74) {
      // Si le niveau acctuel de l'eau est 60 donc dans la tranche la plus éloigné
      if (_niveauEau == 60) {
        return 2;
      }

      // Si le niveau acctuel de l'eau est 70 donc dans la bonne tranche
      if (_niveauEau == 70) {
        return 0;
      }

      // Si le niveau acctuel de l'eau est 80 donc dans la tranche juste après
      if (_niveauEau == 80) {
        return 1;
      }
    }

    // Si le bon niveau est dans la tranche 4
    if (_bonNiveau >= 75 && _bonNiveau <= 80) {
      // Si le niveau acctuel de l'eau est 60 donc dans la tranche la plus éloigné
      if (_niveauEau == 60) {
        return 2;
      }

      // Si le niveau acctuel de l'eau est 80 donc dans la tranche juste avant
      if (_niveauEau == 70) {
        return 1;
      }

      // Si le niveau acctuel de l'eau est 80 donc dans la bonne tranche
      if (_niveauEau == 80) {
        return 0;
      }
    }

    // Si le niveau acctuel de l'eau est dans la même tranche
    return 10;
  }

  // Vérifie si l'utilisateur s'est absenté plus de 2 jours
  bool _incident() => _joursEcoule > 2;
  // Vérifie si l'utilisateur s'est absenté plus de 2 jours et moins de 4 jours
  bool _incidentMineur() => _joursEcoule > 2 && _joursEcoule <= 4;
  // Vérifie si l'utilisateur s'est absenté plus de 4 jours et moins de 6 jours
  bool _incidentMoyen() => _joursEcoule > 4 && _joursEcoule <= 6;
  // Vérifie si l'utilisateur s'est absenté plus de 6 jours et moins de 8 jours
  bool _incidentMajeur() => _joursEcoule > 6 && _joursEcoule <= 8;

  void _changeEtat() {
    if (_probaPourri >= 0 && _probaPourri <= 20) {
      _etat = "Excellent";
    } else if (_probaPourri > 20 && _probaPourri <= 40 && !_pourri) {
      _etat = "Bon";
    } else if (_probaPourri > 40 && _probaPourri <= 60 && !_pourri) {
      _etat = "Moyen";
    } else if (_probaPourri > 60 && _probaPourri <= 80 && !_pourri) {
      _etat = "Moyen";
    } else if (_probaPourri > 80 || _pourri) {
      _etat = "Pitoyable";
    }
  }
}
