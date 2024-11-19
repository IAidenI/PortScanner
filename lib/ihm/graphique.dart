import '../export.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  bool isMenu = true;
  bool isScanning = false;
  bool showInfo = false;
  bool useCommonPort = false;
  String ipAddress = "192.168.194.4";
  int subNetMask = 24;
  String url = "https://www.google.com/";
  int portStart = 0;
  int portEnd = 65535;
  int segments = 20;
  List<String> dataToPrint = [];
  Device phone = Device();
  String scanType = "";

  /*
    =-=-=-=-=-=-=-=-=-=-=-=-=
    =-= BOITE DE DIALOGUE =-=
    =-=-=-=-=-=-=-=-=-=-=-=-=
  */
  Future<void> _showUserInfo() async {
    final userInfo = {
      "Nom": phone.getName(),
      "Modèle": phone.getModel(),
    };

    final networkInfo = {
      "IP privé": phone.getLocalIP(),
      "IP public": phone.getPublicIP(),
    };

    final systemInfo = {
      "RAM": "${phone.getRAM()}Go",
      "Nombre de coeurs": phone.getCoresNumber(),
      "Noyau":
          "${phone.getKernelName()} x${phone.getKernelBits()} - ${phone.getKernelVersion()}",
      "Username": phone.getUserName(),
    };

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Informations du téléphone"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...userInfo.entries.map(
                  (entry) => SelectableText("${entry.key} : ${entry.value}")),
              const SizedBox(height: 10), // Espace entre groupes
              ...networkInfo.entries.map(
                  (entry) => SelectableText("${entry.key} : ${entry.value}")),
              const SizedBox(height: 10), // Espace entre groupes
              ...systemInfo.entries.map(
                  (entry) => SelectableText("${entry.key} : ${entry.value}")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUrlToIPDialog() async {
    final ipController = TextEditingController();
    String currentURL = url;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Saisir l'URL de la machine"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ipController,
                    decoration: InputDecoration(
                      labelText: "URL",
                      hintText: currentURL,
                      hintStyle: const TextStyle(color: Colors.grey),
                      errorText: InputChecker.checkURL(currentURL)
                          ? null
                          : "URL invalide",
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        currentURL = value.isEmpty ? url : value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: InputChecker.checkURL(currentURL)
                      ? () async {
                          // Mettre à jour `url` avec la valeur saisie
                          url = ipController.text.isEmpty
                              ? url
                              : ipController.text;

                          String ipAddress = await Scanner.urlToIP(url);

                          // Fermez le Dialog actuel
                          Navigator.of(context).pop();

                          // Affichez un nouveau Dialog pour afficher et copier l'IP
                          _showIPDialog(context, ipAddress);
                        }
                      : null, // Désactivé si l'URL n'est pas valide
                  child: const Text("Envoyer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showIPDialog(BuildContext context, String ipAddress) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Résultat"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
            children: [
              Text(
                ipAddress.isNotEmpty
                    ? "L'IP de la machine est :"
                    : "L'IP de la machine est introuvable.",
                style: const TextStyle(fontSize: 16),
              ),
              if (ipAddress.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SelectableText(
                    ipAddress,
                    style: const TextStyle(
                      fontSize: 16, // Pas de gras
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            if (ipAddress.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Copier l'adresse IP dans le presse-papiers
                  Clipboard.setData(ClipboardData(text: ipAddress));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Adresse IP copiée dans le presse-papiers"),
                    ),
                  );
                },
                child: const Text("Copier"),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPingDialog() async {
    final ipController = TextEditingController();
    String currentIp = ipAddress;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Saisir l'IP de la machine"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ipController,
                    decoration: InputDecoration(
                      labelText: "Adresse IP",
                      hintText: currentIp,
                      hintStyle: const TextStyle(color: Colors.grey),
                      errorText: InputChecker.checkIP(currentIp)
                          ? null
                          : "Adresse IP invalide",
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        currentIp = value.isEmpty ? ipAddress : value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: InputChecker.checkIP(currentIp)
                      ? () async {
                          // Mettre à jour `ipAddress` avec la valeur saisie
                          ipAddress = ipController.text.isEmpty
                              ? ipAddress
                              : ipController.text;

                          bool isPresent = await Scanner.ping(ipAddress);

                          // Utilisez le `context` tant que le widget est actif
                          if (isPresent) {
                            _pingSnackbar(context, "L'appareil existe.");
                          } else {
                            _pingSnackbar(context, "L'appareil n'existe pas.");
                          }

                          // Fermez le Dialog après l'affichage du message
                          Navigator.of(context).pop();
                        }
                      : null, // Désactivé si l'IP n'est pas valide
                  child: const Text("Envoyer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pingSnackbar(BuildContext context, String message) {
    // Obtenir l'overlay
    OverlayState? overlayState = Overlay.of(context);

    // Créer une entrée overlay
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50, // Position verticale
        left: 20, // Marges horizontales
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20), // Bords arrondis
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Ajouter l'overlay
    overlayState.insert(overlayEntry);

    // Supprimer l'encadré après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _showIpPortDialog() async {
    final ipController = TextEditingController();
    final portStartController = TextEditingController();
    final portEndController = TextEditingController();
    final segmentsController = TextEditingController();
    bool showAdvancedOptions = false;

    String currentIp = ipAddress;
    String currentPortStart = portStart.toString();
    String currentPortEnd = portEnd.toString();
    String currentSegments = segments.toString();

    bool isIpValid = InputChecker.checkIP(currentIp);
    bool isPortStartValid = InputChecker.checkPort(currentPortStart);
    bool isPortEndValid = InputChecker.checkPort(currentPortEnd);
    bool isSegmentsValid = InputChecker.checkSegment(currentSegments);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Configurer le scan"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: ipController,
                      decoration: InputDecoration(
                        labelText: "Adresse IP",
                        hintText: currentIp,
                        hintStyle: const TextStyle(color: Colors.grey),
                        errorText: isIpValid ? null : "Adresse IP invalide",
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        setState(() {
                          currentIp = value.isEmpty ? ipAddress : value;
                          isIpValid = InputChecker.checkIP(currentIp);
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: useCommonPort,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                useCommonPort = true;
                                showAdvancedOptions = false;
                              } else {
                                useCommonPort = false;
                              }
                            });
                          },
                        ),
                        Flexible(
                          child: const Text(
                            "Utiliser les 1000 ports les plus communs",
                            softWrap: true,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: showAdvancedOptions,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                showAdvancedOptions = true;
                                useCommonPort = false;
                              } else {
                                showAdvancedOptions = false;
                              }
                            });
                          },
                        ),
                        const Text("Options avancées"),
                      ],
                    ),
                    if (showAdvancedOptions) ...[
                      TextField(
                        controller: portStartController,
                        decoration: InputDecoration(
                          labelText: "Port de départ (> 0)",
                          hintText: currentPortStart,
                          hintStyle: const TextStyle(color: Colors.grey),
                          errorText: isPortStartValid
                              ? null
                              : "Port de départ invalide",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            currentPortStart =
                                value.isEmpty ? portStart.toString() : value;
                            isPortStartValid =
                                InputChecker.checkPort(currentPortStart);
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: portEndController,
                        decoration: InputDecoration(
                          labelText: "Port de fin (< 65535)",
                          hintText: currentPortEnd,
                          hintStyle: const TextStyle(color: Colors.grey),
                          errorText:
                              isPortEndValid ? null : "Port de fin invalide",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            currentPortEnd =
                                value.isEmpty ? portEnd.toString() : value;
                            isPortEndValid =
                                InputChecker.checkPort(currentPortEnd);
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: segmentsController,
                        decoration: InputDecoration(
                          labelText: "Nombre de segments (0 < 100)",
                          hintText: currentSegments,
                          hintStyle: const TextStyle(color: Colors.grey),
                          errorText: isSegmentsValid
                              ? null
                              : "Nombre de segments invalide",
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            currentSegments =
                                value.isEmpty ? segments.toString() : value;
                            isSegmentsValid =
                                InputChecker.checkSegment(currentSegments);
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: isIpValid &&
                          (useCommonPort ||
                              (showAdvancedOptions &&
                                  isPortStartValid &&
                                  isPortEndValid &&
                                  isSegmentsValid))
                      ? () {
                          setState(() {
                            ipAddress = ipController.text.isEmpty
                                ? ipAddress
                                : ipController.text;
                            if (showAdvancedOptions) {
                              portStart =
                                  int.tryParse(portStartController.text) ??
                                      portStart;
                              portEnd = int.tryParse(portEndController.text) ??
                                  portEnd;
                              segments =
                                  int.tryParse(segmentsController.text) ??
                                      segments;
                            }
                          });
                          Navigator.of(context).pop();
                          _startScan();
                        }
                      : null,
                  child: const Text("Lancer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showListIpDialog() async {
    final ipController = TextEditingController();
    final segmentsController = TextEditingController();
    String currentSegments = segments.toString();
    bool isSegmentsValid = InputChecker.checkSegment(currentSegments);
    String currentIpMask = "$ipAddress/$subNetMask";

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Saisir l'IP et le masque de la machine"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ipController,
                    decoration: InputDecoration(
                      labelText: "Adresse IP et masque",
                      hintText: currentIpMask,
                      hintStyle: const TextStyle(color: Colors.grey),
                      errorText: InputChecker.checkIpMask(currentIpMask)
                          ? null
                          : "Adresse ou masque invalide",
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        currentIpMask =
                            value.isEmpty ? "$ipAddress/$subNetMask" : value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: segmentsController,
                    decoration: InputDecoration(
                      labelText: "Nombre de segments (0 < X < 100)",
                      hintText: currentSegments,
                      hintStyle: const TextStyle(color: Colors.grey),
                      errorText: isSegmentsValid
                          ? null
                          : "Nombre de segments invalide",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        currentSegments =
                            value.isEmpty ? segments.toString() : value;
                        isSegmentsValid =
                            InputChecker.checkSegment(currentSegments);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "(Facultatif) : 'Nombre de segments'",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: InputChecker.checkIpMask(currentIpMask)
                      ? () async {
                          Navigator.of(context).pop();
                          await _startListScan(currentIpMask, currentSegments);
                        }
                      : null,
                  child: const Text("Envoyer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAlreadyPresentDialog(Future<void> Function() onNew) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Données trouvées"),
          content: const Text(
            "Des données ont été trouvées. Voulez-vous les afficher ?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                dataToPrint.clear();
                Scanner.clear();
                Scanner.resetCancelRequest();
                onNew();
              },
              child: const Text("Nouveau"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isMenu = false;
                  showInfo = true;
                });
              },
              child: const Text("Afficher"),
            ),
          ],
        );
      },
    );
  }

  /*
    =-=-=-=-=-=-=-=-=-=
    =-= START SCANS =-=
    =-=-=-=-=-=-=-=-=-=
  */
  Future<void> _startScan() async {
    setState(() {
      scanType = "ipPort"; // Type de scan
      isMenu = false;
      isScanning = true;
      showInfo = false;
    });

    Scanner.resetCancelRequest();

    await Scanner.paralleleStart(
        ipAddress, portStart, portEnd, segments, useCommonPort);

    setState(() {
      isScanning = false;
      dataToPrint = Scanner.getPortOpen();
      dataToPrint = dataToPrint.toSet().toList();
      showInfo = true;
    });
  }

  Future<void> _startListScan(String ipMask, String segmentInput) async {
    setState(() {
      scanType = "listIp";
      isMenu = false;
      isScanning = true;
      showInfo = false;
    });

    Scanner.resetCancelRequest();

    final inputParts = ipMask.split('/');
    if (inputParts.length == 2) {
      ipAddress = inputParts[0];
      subNetMask = int.parse(inputParts[1]);
      segments = int.tryParse(segmentInput) ?? segments;

      await Scanner.balayageIPParallele(ipAddress, subNetMask, segments);

      setState(() {
        isScanning = false;
        dataToPrint = Scanner.getIpPresent();
        dataToPrint = dataToPrint.toSet().toList();
        showInfo = true;
      });
    }
  }

  /*
    =-=-=-=-=-=-=-=-=-=-=-
    =-= VUE PRINCIPALE =-=
    =-=-=-=-=-=-=-=-=-=-=-
  */
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: isMenu
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (dataToPrint.isNotEmpty) {
                          _showAlreadyPresentDialog(_showListIpDialog);
                        } else {
                          _showListIpDialog();
                        }
                      },
                      child: const Text("Liste de tous les appareils"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (dataToPrint.isNotEmpty) {
                          _showAlreadyPresentDialog(_showIpPortDialog);
                        } else {
                          _showIpPortDialog();
                        }
                      },
                      child: const Text("Scan d'une IP"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showPingDialog();
                      },
                      child: const Text("Est-ce qu'il existe ?"),
                    ),
                    /*const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showUrlToIPDialog();
                      },
                      child: const Text("URL to IP"),
                    ),*/
                  ],
                )
              : isScanning
                  ? Stack(
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                              color: Colors.deepPurpleAccent),
                        ),
                        Positioned(
                          top: 44,
                          left: 75,
                          right: 75,
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
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
                        const Positioned(
                          bottom: 40,
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                scanType == "ipPort"
                                    ? "Appareil : $ipAddress"
                                    : "Réseau : $ipAddress/$subNetMask",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 180,
                                height: 200,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.8),
                                        Colors.purple.withOpacity(0.5),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: dataToPrint.isNotEmpty
                                          ? dataToPrint
                                              .map((port) => Text(
                                                    port,
                                                    style: const TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ))
                                              .toList()
                                          : [
                                              Text(
                                                scanType == "ipPort"
                                                    ? "Aucun port ouvert."
                                                    : "Aucune IP trouvée.",
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
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
                              ),
                              Text(
                                scanType == "ipPort"
                                    ? "Nombres de ports scannés : ${Scanner.getPortNumber()}"
                                    : "Nombres d'IP scannées : ${Scanner.getIpNumber()}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
        ),
        if (!isMenu)
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                setState(() {
                  isMenu = true;
                  Scanner.cancelScan();
                  //dataToPrint.clear();
                  Scanner.clear();
                });
              },
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              child: const Icon(Icons.arrow_back),
            ),
          ),
        Positioned(
          top: 40,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            onPressed: _showUserInfo,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            child: const Icon(Icons.account_circle),
          ),
        ),
      ],
    );
  }
}
