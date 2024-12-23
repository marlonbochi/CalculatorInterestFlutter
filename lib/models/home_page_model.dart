import 'package:flutterflow_ui/flutterflow_ui.dart';
import '/pages/home_page.dart' show HomePageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textMoneyController;
  String? Function(BuildContext, String?)? textMoneyControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textInterestController;
  String? Function(BuildContext, String?)? textInterestControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textMonthsController;
  String? Function(BuildContext, String?)? textMonthsControllerValidator;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<dynamic>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textMoneyController?.dispose();

    textFieldFocusNode2?.dispose();
    textInterestController?.dispose();

    textFieldFocusNode3?.dispose();
    textMonthsController?.dispose();

    paginatedDataTableController.dispose();
  }
}
