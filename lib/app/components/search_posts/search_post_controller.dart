import 'package:flutter/cupertino.dart';
import 'package:iwrqk/app/components/iwr_refresh/controller.dart';
import 'package:iwrqk/app/data/enums/result.dart';
import 'package:iwrqk/app/data/models/forum/thread.dart';
import 'package:iwrqk/app/data/providers/api_provider.dart';

import '../../data/enums/types.dart';

class SearchPostsController extends IwrRefreshController<ThreadModel>{

  final String keyword;
  final MediaType mediaType;
  final OrderType orderType;
  ScrollController scrollController=ScrollController();

  SearchPostsController(this.keyword, {required this.mediaType, required this.orderType});




  @override
  Future<GroupResult<ThreadModel>> getNewData(int currentPage) async{
    return Future.value((await ApiProvider.searchThreads(
        keyword: keyword,
        type: mediaType,
        pageNum: currentPage,
        orderType: orderType
    )).data);
  }

}