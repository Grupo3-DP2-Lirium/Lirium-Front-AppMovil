import 'package:flutter/material.dart';
import '../widgets/memorial_videos_feed.dart';

class VideosTab extends StatefulWidget {
  final String memorialId;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const VideosTab({
    super.key,
    required this.memorialId,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return  VideosFeedTab(memorialId: widget.memorialId);
  }
}
