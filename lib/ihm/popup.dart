import '../export.dart';

class Popup {
  static Future<void> showIpPortDialog(
      BuildContext context,
      String ipAddress,
      int portStart,
      int portEnd,
      int segments,
      bool useCommonPort,
      Function startScan) async {
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
                          startScan();
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

  static Future<void> showListIpDialog(BuildContext context, String ipAddress,
      int subNetMask, int segments, Function startScan) async {
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
                          await startScan(currentIpMask, currentSegments);
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

  static Future<void> showPingDialog(BuildContext context, String ipAddress,
      Function updatePingSection) async {
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
                          // Mettre à jour l'adresse IP
                          ipAddress = ipController.text.isEmpty
                              ? ipAddress
                              : ipController.text;

                          bool isPresent = await Scanner.ping(ipAddress);

                          // Appeler la fonction passée en paramètre pour mettre à jour l'état
                          String message = isPresent
                              ? "L'appareil existe."
                              : "L'appareil n'existe pas.";
                          updatePingSection(ipAddress, message);

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
}
