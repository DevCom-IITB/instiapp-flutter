import 'package:json_annotation/json_annotation.dart';
import 'buynsellPost.dart';

part 'buynsellPostsPage.g.dart';

/// Wraps the `{"results": [...]}` response from GET /buy/v2/products
/// (BuyAndSellViewSet.list_v2). Page size is fixed at 20 server-side.
@JsonSerializable()
class BuynSellPostsPage {
  @JsonKey(name: "results")
  List<BuynSellPost>? results;

  BuynSellPostsPage({this.results});

  factory BuynSellPostsPage.fromJson(Map<String, dynamic> json) =>
      _$BuynSellPostsPageFromJson(json);

  Map<String, dynamic> toJson() => _$BuynSellPostsPageToJson(this);
}
