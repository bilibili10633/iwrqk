import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:iwrqk/app/components/iwr_refresh/widget.dart';
import 'package:iwrqk/app/components/search_posts/search_post_controller.dart';
import 'package:iwrqk/app/data/enums/types.dart';
import 'package:iwrqk/app/data/models/forum/thread.dart';
import '../../utils/display_util.dart';
import '../network_image.dart';

class SearchPost extends StatefulWidget {
  final String tag = "search_post_controller";

  final String keyword;
  final OrderType orderType;

  const SearchPost({super.key, required this.keyword, required this.orderType});

  @override
  State<SearchPost> createState() => _SearchPostState();
}

class _SearchPostState extends State<SearchPost>
    with AutomaticKeepAliveClientMixin {
  late SearchPostsController _controller;

  @override
  void initState() {
    super.initState();
    Get.lazyPut(
      () => SearchPostsController(widget.keyword, mediaType: MediaType.thread, orderType: widget.orderType),
      tag: widget.tag,
    );
    _controller = Get.find<SearchPostsController>(tag: widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IwrRefresh(
      controller: _controller,
      scrollController: _controller.scrollController,
      builder: (data, scrollController) {
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                return Thread(thread: data[index]);
              }, childCount: data.length),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Thread extends StatelessWidget {
  final ThreadModel thread;
  final bodyMaxShowLength=200;
  const Thread({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Get.toNamed(
          "/thread?channelName=Search&threadId=${thread.id}",
          arguments: {'threadModel': thread},
        );
      },
      child: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: ClipOval(
                child: NetworkImg(
                  imageUrl: thread.user.avatarUrl,
                  width: 30,
                  height: 30,
                ),
              ),
              title: Text(
                thread.user.name,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                DisplayUtil.getDisplayTime(DateTime.parse(thread.createdAt)),
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.title,
                    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                  ),
                  Text(
                      (thread.lastPost?.body.length??0)<bodyMaxShowLength
                          ?(thread.lastPost?.body??"")
                          :"${thread.lastPost?.body.substring(0,bodyMaxShowLength)}..."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
