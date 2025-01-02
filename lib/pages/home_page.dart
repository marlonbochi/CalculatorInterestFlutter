import 'package:calculadora_de_juros/pages/history_page.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import '/functions/flutter_flow_theme.dart';

import '../models/home_page_model.dart';
export '../models/home_page_model.dart';
import '../functions/database_helper.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  int _selectedIndex = 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final dbHelper = DatabaseHelper();

  final List<DataRow> rows = [];

  void initDatabase(String deposit, String interest, String months) async {
    // Insert an item
    await dbHelper.insertItem(deposit, interest, months);

    // Retrieve all items
    List<Map<String, dynamic>> items = await dbHelper.getAllItems();
    print('All Items: $items');

    // Update an item
    if (items.isNotEmpty) {
      int id = items[0]['id'];
      await dbHelper.updateItem(id, deposit, interest, months);
    }

    // Delete an item
    if (items.isNotEmpty) {
      int id = items[0]['id'];
      await dbHelper.deleteItem(id);
    }
  }

  void calculateInterests() async {
    // Get values from text controllers
    String deposit =
        _model.textMoneyController?.text.replaceAll(RegExp(r'[^\d]'), '') ??
            '0';
    String interest = _model.textInterestController.text;
    String months = _model.textMonthsController.text;

    // Validate inputs
    if (deposit.isEmpty || interest.isEmpty || months.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // try {
    //   // Convert deposit from cents to real value
    //   deposit = (double.parse(deposit) / 100).toString();

    //   // Store values in database
    //   await dbHelper.insertItem(deposit, interest, months);

    //   // Show success message
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Cálculo salvo com sucesso!'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // } catch (e) {
    //   // Show error message if something goes wrong
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Erro ao salvar o cálculo'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   print('Error saving to database: $e');
    // }

    double oldValue = double.parse(
        _model.textMoneyController?.text.replaceAll(RegExp(r'[^\d]'), '') ??
            '0');
    double newValue = double.parse(
        _model.textMoneyController?.text.replaceAll(RegExp(r'[^\d]'), '') ??
            '0');

    for (int i = 0; i < int.parse(months); i++) {
      double interest =
          double.parse(_model.textInterestController.text.replaceAll('%', ''));

      double added = (newValue * (interest / 100));
      newValue = (newValue + added);

      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text((i + 1).toString())),
          DataCell(Text((oldValue / 100).toString())),
          DataCell(Text((added / 100).toString())),
          DataCell(Text((newValue / 100).toString())),
        ],
      ));

      oldValue = newValue;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    _model.textMoneyController ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    // Add listener for currency formatting
    _model.textMoneyController?.addListener(() {
      String text = _model.textMoneyController?.text ?? '';
      text = text.replaceAll(RegExp(r'[^\d]'), '');

      if (text.isNotEmpty) {
        double value = double.parse(text) / 100;
        _model.textMoneyController?.value = TextEditingValue(
          text: 'R\$ ${value.toStringAsFixed(2)}',
          selection: TextSelection.collapsed(
              offset: value.toStringAsFixed(2).length + 3),
        );
      }
    });

    _model.textInterestController ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    // Add listener for interest percentage formatting
    _model.textInterestController?.addListener(() {
      String text =
          _model.textInterestController!.text.replaceAll(RegExp(r'[^\d]'), '');
      if (text.isNotEmpty) {
        double value = double.parse(text);
        if (value > 100) value = 100;
        _model.textInterestController?.value = TextEditingValue(
          text: '$value%',
          selection:
              TextSelection.collapsed(offset: value.toString().length + 1),
        );
      }
    });

    _model.textMonthsController ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content:
              const Text('Tem certeza que deseja apagar todo o histórico?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await dbHelper.deleteAllItems();
      setState(() {
        rows.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Histórico apagado com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Calculadora de Juros',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: _selectedIndex != 0
              ? [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: FFButtonWidget(
                      onPressed: clearHistory,
                      text: 'Limpar',
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ]
              : [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: _selectedIndex == 0
            ? SafeArea(
                top: true,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Text(
                            'Valor depositado',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                14.0, 0.0, 14.0, 0.0),
                            child: Container(
                              width: 200.0,
                              child: TextFormField(
                                controller: _model.textMoneyController,
                                focusNode: _model.textFieldFocusNode1,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelStyle:
                                      FlutterFlowTheme.of(context).labelMedium,
                                  hintStyle:
                                      FlutterFlowTheme.of(context).labelMedium,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      EdgeInsetsDirectional.fromSTEB(
                                          16.0, 12.0, 16.0, 12.0),
                                ),
                                style: FlutterFlowTheme.of(context).bodyMedium,
                                keyboardType: TextInputType.number,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                validator: _model.textMoneyControllerValidator
                                    .asValidator(context),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Text(
                            'Juros por mês %',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                14.0, 0.0, 14.0, 0.0),
                            child: Container(
                              width: 200.0,
                              child: TextFormField(
                                controller: _model.textInterestController,
                                focusNode: _model.textFieldFocusNode2,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelStyle:
                                      FlutterFlowTheme.of(context).labelMedium,
                                  hintStyle:
                                      FlutterFlowTheme.of(context).labelMedium,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      EdgeInsetsDirectional.fromSTEB(
                                          16.0, 12.0, 16.0, 12.0),
                                ),
                                style: FlutterFlowTheme.of(context).bodyMedium,
                                keyboardType: TextInputType.number,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                validator: _model
                                    .textInterestControllerValidator
                                    .asValidator(context),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Text(
                            'Meses para calcular',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                14.0, 0.0, 14.0, 0.0),
                            child: Container(
                              width: 200.0,
                              child: TextFormField(
                                controller: _model.textMonthsController,
                                focusNode: _model.textFieldFocusNode3,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelStyle:
                                      FlutterFlowTheme.of(context).labelMedium,
                                  hintStyle:
                                      FlutterFlowTheme.of(context).labelMedium,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  contentPadding:
                                      EdgeInsetsDirectional.fromSTEB(
                                          16.0, 12.0, 16.0, 12.0),
                                ),
                                style: FlutterFlowTheme.of(context).bodyMedium,
                                keyboardType: TextInputType.number,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                validator: _model.textMonthsControllerValidator
                                    .asValidator(context),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: FFButtonWidget(
                                onPressed: calculateInterests,
                                text: 'Calcular',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 50.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter Tight',
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                              columnSpacing: 16,
                              dataRowMinHeight: 45,
                              headingRowColor: WidgetStateColor.resolveWith(
                                  (states) => FlutterFlowTheme.of(context)
                                      .secondaryBackground),
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
                                  : rows),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const HistoryPageWidget(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Calculadora',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Histórico',
            ),
          ],
        ),
      ),
    );
  }
}
