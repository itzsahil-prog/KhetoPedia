import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../tab_item/tab_item_widget.dart';
import 'tab_group_model.dart';
export 'tab_group_model.dart';

class TabGroupWidget extends StatefulWidget {
  const TabGroupWidget({
    super.key,
    String? label1,
    String? label2,
    bool? label2Present,
    String? label3,
    bool? label3Present,
    String? label4,
    bool? label4Present,
    String? label5,
    bool? label5Present,
  })  : label1 = label1 ?? 'Tab 1',
        label2 = label2 ?? '',
        label2Present = label2Present ?? false,
        label3 = label3 ?? '',
        label3Present = label3Present ?? false,
        label4 = label4 ?? '',
        label4Present = label4Present ?? false,
        label5 = label5 ?? '',
        label5Present = label5Present ?? false;

  final String label1;
  final String label2;
  final bool label2Present;
  final String label3;
  final bool label3Present;
  final String label4;
  final bool label4Present;
  final String label5;
  final bool label5Present;

  @override
  State<TabGroupWidget> createState() => _TabGroupWidgetState();
}

class _TabGroupWidgetState extends State<TabGroupWidget> {
  late TabGroupModel _model;
  int _selectedIndex = 0;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TabGroupModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  List<String> get _labels {
    final labels = [widget.label1];
    if (widget.label2Present && widget.label2.isNotEmpty) labels.add(widget.label2);
    if (widget.label3Present && widget.label3.isNotEmpty) labels.add(widget.label3);
    if (widget.label4Present && widget.label4.isNotEmpty) labels.add(widget.label4);
    if (widget.label5Present && widget.label5.isNotEmpty) labels.add(widget.label5);
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final labels = _labels;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(labels.length, (i) {
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: wrapWithModel(
                  model: [
                    _model.tabItemModel1,
                    _model.tabItemModel2,
                    _model.tabItemModel3,
                    _model.tabItemModel4,
                    _model.tabItemModel5,
                  ][i],
                  updateCallback: () => safeSetState(() {}),
                  child: TabItemWidget(label: labels[i], selected: _selectedIndex == i),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
