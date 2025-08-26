import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DebitClientPage extends StatelessWidget {
  const DebitClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DebitClientPageContent();
  }
}

class DebitClientPageContent extends StatefulWidget {
  const DebitClientPageContent({super.key});

  @override
  State<DebitClientPageContent> createState() => _DebitClientPageContentState();
}

class _DebitClientPageContentState extends State<DebitClientPageContent> {
  late final List<PlutoColumn> columns;
  late final List<PlutoRow> rows;
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
