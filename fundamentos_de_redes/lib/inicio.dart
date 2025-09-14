// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fundamentos_de_redes/ip_mask.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  String? networkResult;
  String? broadcastResult;
  String? rangeStart;
  String? rangeEnd;
  String? errorMessage;

  final TextEditingController ipController = TextEditingController();
  final TextEditingController maskController = TextEditingController();
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  @override
  void dispose() {
    ipController.dispose();
    maskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    final bool xLarge = MediaQuery.of(context).size.width > 1200;
    final bool lowHeigth =
        MediaQuery.of(context).size.height < 700 &&
        MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      body:
          isMobile
              ? _buildMobileLayout()
              : _buildDesktopLayout(xLarge: xLarge, lowHeigth: lowHeigth),
    );
  }

  // ---------------- Layouts ----------------

  Widget _buildMobileLayout() {
    return _DecoratedContainer(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const TitleSection(
              title: "Calculadora de Rede e Broadcast!",
              description:
                  "Descubra o endereço de rede e o endereço de broadcast de qualquer endereço IP e máscara de rede.",
              illustrationWidth: 250,
            ),
            const SizedBox(height: 32),
            _contentSwitcher(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout({required bool xLarge, bool lowHeigth = false}) {
    return _DecoratedContainer(
      padding: xLarge ? const EdgeInsets.all(80) : const EdgeInsets.all(64),
      margin: xLarge ? const EdgeInsets.all(48) : const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 38,
        children: [
          Expanded(
            child: TitleSection(
              lowHeigth: lowHeigth,
              title: "Calculadora de Rede",
              subtitle: "e Broadcast!",
              description:
                  "Descubra o endereço de rede e o endereço de broadcast de qualquer endereço IP e máscara de rede.",
              illustrationWidth: 300,
              alignStart: true,
            ),
          ),
          Expanded(child: _contentSwitcher()),
        ],
      ),
    );
  }

  // ---------------- Conteúdo ----------------

  Widget _contentSwitcher() {
    if (errorMessage != null ||
        networkResult != null ||
        broadcastResult != null) {
      return ResultSection(
        refreshApp: _refreshApp,
        networkResult: networkResult,
        broadcastResult: broadcastResult,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        errorMessage: errorMessage,
      );
    } else {
      return Form(
        key: keyForm,
        child: FormSection(
          ipController: ipController,
          maskController: maskController,
          onCalculate: _calculateNetworkAndBroadcast,
        ),
      );
    }
  }

  // ---------------- Lógica ----------------

  void _calculateNetworkAndBroadcast({
    required String ip,
    required String mask,
  }) {
    if (!keyForm.currentState!.validate()) {
      return;
    }
    final IpMask ipMask = IpMask(ip: ip, mask: mask);
    try {
      final validated = ipMask.validateMask(mask);
      final network = ipMask.calculateNetwork(ip, validated["mask"]);
      final broadcast = ipMask.calculateBroadcast(ip, validated["mask"]);
      final range = ipMask.calculateRange(
        network,
        broadcast,
        validated["prefix"],
      );

      setState(() {
        networkResult = network;
        broadcastResult = broadcast;
        if (range.length == 2) {
          rangeStart = range[0];
          rangeEnd = range[1];
        } else {
          rangeStart = null;
          rangeEnd = null;
        }
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        networkResult = null;
        broadcastResult = null;
        rangeStart = null;
        rangeEnd = null;
      });
    }
  }

  void _refreshApp() {
    setState(() {
      ipController.clear();
      maskController.clear();
      networkResult = null;
      broadcastResult = null;
      rangeStart = null;
      rangeEnd = null;
      errorMessage = null;
    });
  }
}

// ---------------- Widgets Reutilizáveis ----------------

class _DecoratedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const _DecoratedContainer({
    required this.child,
    required this.padding,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: padding,
      margin: margin,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.cyanAccent,
            blurRadius: 15,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TitleSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String description;
  final double illustrationWidth;
  final bool alignStart;
  final bool lowHeigth;

  const TitleSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.description,
    required this.illustrationWidth,
    this.alignStart = false,
    this.lowHeigth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 16),
        Text(
          description,
          softWrap: true,
          maxLines: 5,
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        ),
        const SizedBox(height: 32),
        if (!lowHeigth)
          SvgPicture.asset("assets/ilustration.svg", width: illustrationWidth),
      ],
    );
  }
}

class ResultSection extends StatelessWidget {
  final String? networkResult;
  final String? broadcastResult;
  final String? rangeStart;
  final String? rangeEnd;
  final String? errorMessage;
  final void Function()? refreshApp;

  const ResultSection({
    super.key,
    this.networkResult,
    this.broadcastResult,
    this.rangeStart,
    this.rangeEnd,
    this.errorMessage,
    this.refreshApp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:
                errorMessage != null
                    ? Colors.redAccent.withOpacity(0.5)
                    : Colors.cyan.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              (errorMessage != null)
                  ? Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Endereço de Rede: $networkResult",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Endereço de Broadcast: $broadcastResult",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rangeStart != null && rangeEnd != null
                            ? "Faixa de Hosts: $rangeStart - $rangeEnd"
                            : "Faixa de Hosts: Único host",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
        ),
        const SizedBox(height: 32),
        TextButton.icon(
          style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 18)),
          onPressed: refreshApp,
          label: const Text("Calcular novamente"),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class FormSection extends StatelessWidget {
  final TextEditingController ipController;
  final TextEditingController maskController;
  final void Function({required String ip, required String mask}) onCalculate;

  const FormSection({
    super.key,
    required this.ipController,
    required this.maskController,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Digite o endereço IP:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        TextFormField(
          inputFormatters: [IpOrCidrAutoFormatter()],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira um endereço IP';
            }
            return null;
          },
          controller: ipController,
          decoration: const InputDecoration(
            labelText: "Endereço IP",
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
        const Text(
          "Digite a máscara de rede:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira uma máscara de rede';
            }
            return null;
          },
          inputFormatters: [IpOrCidrAutoFormatter()],
          controller: maskController,
          decoration: const InputDecoration(
            labelText: "Máscara de Rede",
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onCalculate(ip: ipController.text, mask: maskController.text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyan,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            "Calcular",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class IpOrCidrAutoFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) return newValue;

    if (text.startsWith('/')) {
      final after = text.substring(1);

      if (after.isEmpty) return newValue;

      if (!RegExp(r'^\d{1,2}$').hasMatch(after)) return oldValue;

      final int? prefix = int.tryParse(after);
      if (prefix == null) return oldValue;

      if (prefix > 32) return oldValue;

      return newValue;
    }

    if (!RegExp(r'^[0-9.]+$').hasMatch(text)) return oldValue;

    if (text.startsWith('.')) return oldValue;

    final raw = text.replaceAll('.', '');
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      buffer.write(raw[i]);

      if ((i + 1) % 3 == 0 && i + 1 != raw.length && (i + 1) < 12) {
        buffer.write('.');
      }
    }

    String formatted = buffer.toString();

    final parts = formatted.split('.');
    if (parts.length > 4) return oldValue;
    for (final part in parts) {
      if (part.isEmpty) continue;
      final int? value = int.tryParse(part);
      if (value == null) return oldValue;
      if (value > 255) return oldValue;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
