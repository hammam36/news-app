import 'package:get/get.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/models/news_response.dart';

class NewsController extends GetxController {
  final NewsService newsService = NewsService();
  
  // VARIABEL EXISTING
  final RxList<dynamic> articles = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString selectedCategory = ''.obs;
  final List<String> categories = [
    'general', 'business', 'technology', 'sports', 'health', 
    'science', 'entertainment'
  ];

  // VARIABEL BARU UNTUK PAGINATION
  final RxInt _currentPage = 0.obs;
  final RxInt _pageSize = 10.obs;
  final RxBool _hasMore = true.obs;
  final List<dynamic> _allArticles = []; // Menyimpan semua artikel

  // GETTERS BARU
  int get currentPage => _currentPage.value;
  int get pageSize => _pageSize.value;
  bool get hasMore => _hasMore.value;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // METHOD BARU: Load initial data dengan semua artikel
  Future<void> loadInitialData() async {
    try {
      isLoading(true);
      error('');
      
      // Load semua artikel sekaligus (max 100 dari NewsAPI free plan)
      final NewsResponse response = await newsService.getTopHeadlines(
        pageSize: 100, // Ambil maksimal yang diizinkan
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value
      );
      
      _allArticles.clear();
      _allArticles.addAll(response.articles ?? []);
      
      // Tampilkan halaman pertama
      _showPaginatedArticles(0);
      
    } catch (e) {
      error('Failed to load news: $e');
    } finally {
      isLoading(false);
    }
  }

  // METHOD BARU: Tampilkan artikel terpaginate
  void _showPaginatedArticles(int page) {
    final startIndex = page * _pageSize.value;
    final endIndex = startIndex + _pageSize.value;
    
    if (startIndex >= _allArticles.length) {
      articles.clear();
      _hasMore.value = false;
      return;
    }
    
    final paginatedArticles = _allArticles.sublist(
      startIndex,
      endIndex.clamp(0, _allArticles.length)
    );
    
    articles.assignAll(paginatedArticles);
    _currentPage.value = page;
    _hasMore.value = endIndex < _allArticles.length;
  }

  // METHOD BARU: Next page
  void nextPage() {
    if (_hasMore.value) {
      _showPaginatedArticles(_currentPage.value + 1);
    }
  }

  // METHOD BARU: Previous page
  void previousPage() {
    if (_currentPage.value > 0) {
      _showPaginatedArticles(_currentPage.value - 1);
    }
  }

  // METHOD BARU: Reset pagination saat kategori berubah
  void resetPagination() {
    _currentPage.value = 0;
    _hasMore.value = true;
  }

  // METHOD EXISTING: selectCategory dengan penyesuaian
  void selectCategory(String category) {
    selectedCategory.value = category;
    resetPagination(); // Reset pagination
    loadInitialData(); // Load data baru dengan kategori
  }

  // METHOD EXISTING: refreshNews dengan penyesuaian
  Future<void> refreshNews() async {
    resetPagination();
    await loadInitialData();
  }

  // METHOD EXISTING: searchNews dengan penyesuaian SESUAI NEWS_SERVICE  
  Future<void> searchNews(String query) async {
    try {
      isLoading(true);
      error('');
      selectedCategory.value = '';
      resetPagination(); // Reset pagination saat search
      
      final NewsResponse response = await newsService.searchNews(
        query: query, 
        pageSize: 100
      );
      
      _allArticles.clear();
      _allArticles.addAll(response.articles ?? []);
      _showPaginatedArticles(0);
      
    } catch (e) {
      error('Search failed: $e');
    } finally {
      isLoading(false);
    }
  }

  // METHOD EXISTING: Kembali ke berita utama
  void clearSearch() {
    selectedCategory.value = '';
    resetPagination();
    loadInitialData();
  }
}