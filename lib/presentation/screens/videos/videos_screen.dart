import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_bar.dart';
import 'package:flutter_frontend/presentation/screens/videos/documentaries_tab.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/providers/documentary_provider.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar documentales después de montar el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentaryProvider>().loadMyDocumentaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.13;

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
          _buildCapsulesTab(),
          const DocumentariesTab(),
        ],
      ),
    );
  }

  Widget _buildCapsulesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Cápsulas',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Próximamente',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
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