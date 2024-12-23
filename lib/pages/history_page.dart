import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../functions/database_helper.dart';

import '../models/history_page_model.dart';
export '../models/history_page_model.dart';

import '/functions/flutter_flow_theme.dart';

class HistoryPageWidget extends StatefulWidget {
  const HistoryPageWidget({super.key});

  @override
  State<HistoryPageWidget> createState() => _HistoryPageWidgetState();
}

class _HistoryPageWidgetState extends State<HistoryPageWidget> {
  late HistoryPageModel _model;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<DataRow> rows = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HistoryPageModel());
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    final items = await _databaseHelper.getAllItems();
    setState(() {
      rows = items.map((item) {
        final deposit = double.parse(item['deposit']);
        final interest = double.parse(item['interest']);
        final months = int.parse(item['months']);
        final newValue = deposit * (1 + (interest / 100)) * months;

        return DataRow(
          cells: <DataCell>[
            DataCell(Text(months.toString())),
            DataCell(Text(deposit.toStringAsFixed(2))),
            DataCell(Text('${interest.toString()}%')),
            DataCell(Text(newValue.toStringAsFixed(2))),
          ],
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 14.0, 8.0, 0.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columnSpacing: 16,
                      dataRowMinHeight: 45,
                      headingRowColor: WidgetStateColor.resolveWith((states) =>
                          FlutterFlowTheme.of(context).secondaryBackground),
                      columns: const <DataColumn>[
                        DataColumn(
                            label: Text('Mês',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter'))),
                        DataColumn(
                            label: Text('Anterior',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter'))),
                        DataColumn(
                            label: Text('Add',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter'))),
                        DataColumn(
                            label: Text('Novo',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter'))),
                      ],
                      rows: rows.isEmpty
                          ? [
                              const DataRow(cells: <DataCell>[
                                DataCell(Text('-')),
                                DataCell(Text('-')),
                                DataCell(Text('-')),
                                DataCell(Text('-')),
                              ])
                            ]
                          : rows,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
