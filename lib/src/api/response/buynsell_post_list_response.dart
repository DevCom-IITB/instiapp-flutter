import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:json_annotation/json_annotation.dart';

part 'buynsell_post_list_response.g.dart';

@JsonSerializable()
class BuynSellPostListResponse {
  int? count;
  List<BuynSellPost>? data;

  BuynSellPostListResponse({
    this.count,
    this.data,
  });
  factory BuynSellPostListResponse.fromJson(Map<String, dynamic> json) =>
      _$BuynSellPostListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BuynSellPostListResponseToJson(this);
}
