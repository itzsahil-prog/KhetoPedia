import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'social_btn_model.dart';
export 'social_btn_model.dart';

class SocialBtnWidget extends StatefulWidget {
  const SocialBtnWidget({
    super.key,
    String? icon,
  }) : icon = icon ?? 'https://cdn.simpleicons.org/google/1a1c19.svg';

  final String icon;

  @override
  State<SocialBtnWidget> createState() => _SocialBtnWidgetState();
}

class _SocialBtnWidgetState extends State<SocialBtnWidget> {
  late SocialBtnModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SocialBtnModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: FlutterFlowTheme.of(context).alternate, width: 1),
      ),
      alignment: Alignment.center,
      child: SvgPicture.network(
        widget.icon,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
