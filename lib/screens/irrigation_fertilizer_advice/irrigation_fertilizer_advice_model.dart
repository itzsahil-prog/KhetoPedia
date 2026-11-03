import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../components/advice_banner/advice_banner_model.dart';
import '../../components/bottom_nav/bottom_nav_model.dart';
import '../../components/bottom_nav_child2/bottom_nav_child2_model.dart';
import '../../components/button/button_model.dart';
import '../../components/recommendation_item/recommendation_item_model.dart';
import '../../components/tab_group/tab_group_model.dart';

class IrrigationFertilizerAdviceModel extends FlutterFlowModel<StatefulWidget> {
  late TabGroupModel tabGroupModel;
  late AdviceBannerModel adviceBannerModel1;
  late AdviceBannerModel adviceBannerModel2;
  late RecommendationItemModel recommendationItemModel1;
  late RecommendationItemModel recommendationItemModel2;
  late RecommendationItemModel recommendationItemModel3;
  late RecommendationItemModel recommendationItemModel4;
  late ButtonModel buttonModel;
  late BottomNavModel bottomNavModel;
  late BottomNavChild2Model bottomNavChild2Model;

  @override
  void initState(BuildContext context) {
    tabGroupModel = createModel(context, () => TabGroupModel());
    adviceBannerModel1 = createModel(context, () => AdviceBannerModel());
    adviceBannerModel2 = createModel(context, () => AdviceBannerModel());
    recommendationItemModel1 = createModel(context, () => RecommendationItemModel());
    recommendationItemModel2 = createModel(context, () => RecommendationItemModel());
    recommendationItemModel3 = createModel(context, () => RecommendationItemModel());
    recommendationItemModel4 = createModel(context, () => RecommendationItemModel());
    buttonModel = createModel(context, () => ButtonModel());
    bottomNavModel = createModel(context, () => BottomNavModel());
    bottomNavChild2Model = createModel(context, () => BottomNavChild2Model());
  }

  @override
  void dispose() {
    tabGroupModel.maybeDispose();
    adviceBannerModel1.maybeDispose();
    adviceBannerModel2.maybeDispose();
    recommendationItemModel1.maybeDispose();
    recommendationItemModel2.maybeDispose();
    recommendationItemModel3.maybeDispose();
    recommendationItemModel4.maybeDispose();
    buttonModel.maybeDispose();
    bottomNavModel.maybeDispose();
    bottomNavChild2Model.maybeDispose();
  }
}
