import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/screens/videos/documentaries_tab.dart';
import 'package:flutter_frontend/presentation/screens/videos/capsules_tab.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';
import 'package:flutter_frontend/providers/capsule_provider.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print('📹 VideosScreen initState');
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // cargar data después de que el widget se haya montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final capsules = context.read<CapsuleProvider>();
      final documentaries = context.read<DocumentaryProvider>();
      capsules.loadMyCapsules();
      documentaries.loadMyDocumentaries();

    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.13;
    final capsules = context.watch<CapsuleProvider>();
    final documentaries = context.watch<DocumentaryProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMemoryAppBar(
        title: 'Videos',
        onBack: () => Navigator.pop(context),
        tabController: _tabController,
        showBackButton: false,
        appBarHeight: appBarHeight,
        tabs: const [
          Tab(text: 'Cápsulas'),
          Tab(text: 'Documentales'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CapsulesTab(capsules),
          DocumentariesTab(documentaries),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}