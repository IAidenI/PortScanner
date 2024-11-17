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
  String ipAddress = "127.0.0.1";
  int portStart = 0;
  int portEnd = 65535;
  int segments = 4;
  List<String> portOpen = [];
  Device phone = Device();

  Future<void> _showUserInfo() async {
    final userInfo = {
      "Nom": phone.getName(),
      "Modèle": phone.getModel(),
    };

    final networkInfo = {
      "IP local": phone.getLocalIP(),
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
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        setState(() =>
                            currentIp = value.isEmpty ? ipAddress : value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: showAdvancedOptions,
                          onChanged: (bool? value) {
                            setState(() {
                              showAdvancedOptions = value ?? false;
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
                          labelText: "Port de départ",
                          hintText: currentPortStart,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() => currentPortStart =
                              value.isEmpty ? portStart.toString() : value);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: portEndController,
                        decoration: InputDecoration(
                          labelText: "Port de fin",
                          hintText: currentPortEnd,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() => currentPortEnd =
                              value.isEmpty ? portEnd.toString() : value);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: segmentsController,
                        decoration: InputDecoration(
                          labelText: "Nombre de segments",
                          hintText: currentSegments,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() => currentSegments =
                              value.isEmpty ? segments.toString() : value);
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
                  onPressed: () {
                    setState(() {
                      ipAddress = ipController.text.isEmpty
                          ? ipAddress
                          : ipController.text;
                      if (showAdvancedOptions) {
                        portStart =
                            int.tryParse(portStartController.text) ?? portStart;
                        portEnd =
                            int.tryParse(portEndController.text) ?? portEnd;
                        segments =
                            int.tryParse(segmentsController.text) ?? segments;
                      }
                    });
                    Navigator.of(context).pop();
                    _startScan();
                  },
                  child: const Text("Lancer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _startScan() async {
    setState(() {
      isMenu = false;
      isScanning = true;
      showInfo = false;
    });

    portOpen.clear();
    Scanner.clear();
    Scanner.resetCancelRequest();
    await Scanner.paralleleStart(ipAddress, portStart, portEnd, segments);

    setState(() {
      isScanning = false;
      portOpen = Scanner.getPortOpen();
      portOpen = portOpen.toSet().toList();
      showInfo = true;
    });
  }

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
                      onPressed: () {
                        setState(() {
                          isMenu = false;
                          isScanning = true;
                          showInfo = false;
                        });
                      },
                      child: const Text("Liste de tous les appareils"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showIpPortDialog,
                      child: const Text("Scan d'une IP"),
                    ),
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
                                "Appareil : $ipAddress",
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
                                        color: Colors
                                            .black26, // Ombre noire légère
                                        blurRadius: 8,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(
                                            0.8), // Blanc transparent
                                        Colors.purple.withOpacity(
                                            0.5), // Violet transparent
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: portOpen.isNotEmpty
                                          ? portOpen
                                              .map((port) => Text(
                                                    port,
                                                    style: const TextStyle(
                                                      color: Colors
                                                          .black87, // Texte noir/gris foncé
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ))
                                              .toList()
                                          : const [
                                              Text(
                                                "Aucun port ouvert.",
                                                style: TextStyle(
                                                  color: Colors
                                                      .black87, // Texte noir/gris foncé
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
                  portOpen.clear();
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
