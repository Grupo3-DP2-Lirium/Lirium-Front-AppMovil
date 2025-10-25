import 'package:flutter/material.dart';
import 'package:flutter_frontend/data/models/memorial_response.dart';
import 'package:flutter_frontend/data/models/memory_response.dart';
import 'package:flutter_frontend/data/services/memory_service.dart';
import 'package:intl/intl.dart';

class TimelineMemoriesScreen extends StatefulWidget {
  final MemorialResponseModel memorial;

  const TimelineMemoriesScreen({
    Key? key,
    required this.memorial,
  }) : super(key: key);

  @override
  State<TimelineMemoriesScreen> createState() => _TimelineMemoriesScreenState();
}

class _TimelineMemoriesScreenState extends State<TimelineMemoriesScreen> {
  final MemoryService _memoryService = MemoryService();
  bool _isLoading = false;
  List<MemoryResponse> _memories = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreMemories();
    }
  }

  Future<void> _loadMemories() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _memories = [];
      _hasMore = true;
    });

    try {
      final response = await _memoryService.getTimelineMemories(
        memorialId: widget.memorial.idMemorial,
        page: 0,
        size: 20,
      );

      setState(() {
        _memories = response;
        _hasMore = response.length >= 20;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar recuerdos: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreMemories() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await _memoryService.getTimelineMemories(
        memorialId: widget.memorial.idMemorial,
        page: _currentPage + 1,
        size: 20,
      );

      setState(() {
        _currentPage++;
        _memories.addAll(response);
        _hasMore = response.length >= 20;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar más recuerdos: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Línea de Tiempo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _memories.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memories.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timeline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay recuerdos en la línea de tiempo',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMemories,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _memories.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _memories.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final memory = _memories[index];
                      final showDateHeader = index == 0 ||
                          !_isSameMonth(
                              memory.photoDate, _memories[index - 1].photoDate);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) _buildDateHeader(memory.photoDate),
                          _buildTimelineItem(memory),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  bool _isSameMonth(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year && date1.month == date2.month;
  }

  Widget _buildDateHeader(DateTime? date) {
    if (date == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          'Sin fecha',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      );
    }

    final monthYear = DateFormat('MMMM yyyy', 'es').format(date);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            monthYear.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(MemoryResponse memory) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              Container(
                width: 2,
                height: 100,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Memory card
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  if (memory.firstImageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        memory.firstImageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 64),
                          );
                        },
                      ),
                    ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        if (memory.photoDate != null)
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy', 'es')
                                    .format(memory.photoDate!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        // Title
                        Text(
                          memory.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          memory.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Media indicators
                        Row(
                          children: [
                            if (memory.images.isNotEmpty)
                              _buildMediaIndicator(
                                Icons.image,
                                memory.images.length,
                              ),
                            if (memory.videos.isNotEmpty)
                              _buildMediaIndicator(
                                Icons.videocam,
                                memory.videos.length,
                              ),
                            if (memory.audios.isNotEmpty)
                              _buildMediaIndicator(
                                Icons.audiotrack,
                                memory.audios.length,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaIndicator(IconData icon, int count) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
