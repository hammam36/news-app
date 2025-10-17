import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';

class NewsDetailView extends StatefulWidget {
  @override
  State<NewsDetailView> createState() => _NewsDetailViewState();
}

class _NewsDetailViewState extends State<NewsDetailView>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  late ScrollController _pageScrollController;
  NewsArticle? article; // Jadikan nullable
  double _scrollOffset = 0.0;
  
  // STATE BARU: Untuk toggle like/dislike
  bool _isLiked = false;
  bool _isDisliked = false;

  @override
  void initState() {
    super.initState();
    
    // FIX: Handle null arguments dengan safe casting
    try {
      final arguments = Get.arguments;
      if (arguments != null && arguments is NewsArticle) {
        article = arguments as NewsArticle;
      } else {
        // Fallback ke article dummy atau handle error
        _showErrorSnackbar();
      }
    } catch (e) {
      print('Error parsing article: $e');
      _showErrorSnackbar();
    }
    
    _scrollController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _pageScrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _pageScrollController.offset;
        });
      });
  }

  // METHOD BARU: Show error snackbar
  void _showErrorSnackbar() {
    Future.delayed(Duration(milliseconds: 500), () {
      Get.snackbar(
        'Error',
        'Gagal memuat berita. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  // METHOD BARU: Handle Like
  void _handleLike() {
    setState(() {
      if (_isLiked) {
        // Jika sudah like, maka unlike (reset)
        _isLiked = false;
        _showUnlikeSnackbar();
      } else {
        // Jika belum like, set like dan reset dislike
        _isLiked = true;
        _isDisliked = false;
        _showLikeSnackbar();
      }
    });
  }

  // METHOD BARU: Handle Dislike
  void _handleDislike() {
    setState(() {
      if (_isDisliked) {
        // Jika sudah dislike, maka undislike (reset)
        _isDisliked = false;
        _showUndislikeSnackbar();
      } else {
        // Jika belum dislike, set dislike dan reset like
        _isDisliked = true;
        _isLiked = false;
        _showDislikeSnackbar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // FIX: Jika article null, tampilkan error screen
    if (article == null) {
      return Scaffold(
        backgroundColor: AppColors.getBackground(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
              SizedBox(height: 16),
              Text(
                'Gagal Memuat Berita',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Silakan kembali dan coba lagi',
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Stack(
        children: [
          // Parallax background
          _buildParallaxBackground(isDark),
          
          // Main content
          CustomScrollView(
            controller: _pageScrollController,
            physics: BouncingScrollPhysics(),
            slivers: [
              _buildEnhancedAppBar(context, isDark),
              _buildContentSection(context, isDark),
            ],
          ),
          
          // Floating action buttons (Share & Copy) - KANAN
          _buildFloatingActions(context, isDark),
          
          // Floating like/dislike buttons - KIRI (DENGAN TOGGLE BEHAVIOR)
          _buildLikeDislikeButtons(context, isDark),
        ],
      ),
    );
  }

  // ... (METHOD-METHOD LAINNYA TETAP SAMA, TAPI PASTIKAN SEMUA METHOD YANG PAKAI 'article!' DIPERIKSA)

  Widget _buildEnhancedAppBar(BuildContext context, bool isDark) {
    final opacity = (_scrollOffset / 200).clamp(0.0, 1.0);
    
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.getBackground(context).withOpacity(opacity),
      leading: Padding(
        padding: EdgeInsets.all(8),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.95),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.getBorder(context).withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                        ? Colors.black.withOpacity(0.5)
                        : AppColors.shadowDark.withOpacity(0.2),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.getTextPrimary(context),
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            );
          },
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'news_image_${article!.url}', // Gunakan article! karena sudah di-check null
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildHeaderImage(isDark),
              _buildGradientOverlay(isDark),
              _buildFloatingInfo(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage(bool isDark) {
    // FIX: Gunakan null-safe access
    if (article!.urlToImage != null) {
      return CachedNetworkImage(
        imageUrl: article!.urlToImage!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient.scale(0.1),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient.scale(0.2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Image not available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(
                Icons.newspaper_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'News Article',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Gradient overlay used on top of header image to improve readability
  Widget _buildGradientOverlay(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.65),
                ]
              : [
                  Colors.black.withOpacity(0.18),
                  Colors.transparent,
                ],
        ),
      ),
    );
  }

  Widget _buildFloatingInfo(bool isDark) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIX: Null-safe access untuk source
                  if (article!.source?.name != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            article!.source!.name!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // FIX: Null-safe access untuk publishedAt
                  if (article!.publishedAt != null) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            timeago.format(DateTime.parse(article!.publishedAt!)),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParallaxBackground(bool isDark) {
    return Positioned.fill(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.8),
                      Colors.white,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // NEW METHOD: Floating action buttons for share & copy (right side)
  Widget _buildFloatingActions(BuildContext context, bool isDark) {
    return Positioned(
      right: 20,
      bottom: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Share button
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _shareArticle,
                      customBorder: CircleBorder(),
                      child: Icon(Icons.share_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 12),

          // Copy link button
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.accent, AppColors.secondary]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.25),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _copyLink,
                      customBorder: CircleBorder(),
                      child: Icon(Icons.link_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.getCardGradient(context),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.getBorder(context).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                        ? Colors.black.withOpacity(0.5)
                        : AppColors.shadow.withOpacity(0.15),
                      blurRadius: 32,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FIX: Null-safe access untuk title
                      if (article!.title != null) ...[
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ).createShader(bounds);
                          },
                          child: Text(
                            article!.title!,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.3,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 5,
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],

                      // FIX: Null-safe access untuk description
                      if (article!.description != null) ...[
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.08),
                                AppColors.secondary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.format_quote_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  article!.description!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.getTextPrimary(context),
                                    height: 1.7,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28),
                      ],

                      // FIX: Null-safe access untuk content
                      if (article!.content != null) ...[
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 28,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            SizedBox(width: 14),
                            Text(
                              'Full Story',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.getTextPrimary(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          article!.content!,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getTextPrimary(context),
                            height: 1.8,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 32),
                      ],

                      // FIX: Null-safe access untuk url
                      if (article!.url != null) ...[
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 30,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _openInBrowser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.launch_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Read Full Article',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _shareArticle() {
    // FIX: Null-safe access untuk url
    if (article!.url != null) {
      Share.share(
        '${article!.title ?? 'Check out this news'}\n\n${article!.url!}',
        subject: article!.title,
      );
    }
  }

  void _copyLink() {
    // FIX: Null-safe access untuk url
    if (article!.url != null) {
      Clipboard.setData(ClipboardData(text: article!.url!));
      Get.snackbar(
        '',
        '',
        titleText: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Link Copied!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        messageText: Text(
          'Article link copied to clipboard',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.secondary,
        borderRadius: 20,
        margin: EdgeInsets.all(20),
      );
    }
  }

  void _openInBrowser() async {
    // FIX: Null-safe access untuk url
    if (article!.url != null) {
      final Uri url = Uri.parse(article!.url!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          '',
          '',
          titleText: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_rounded, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Error',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          messageText: Text(
            'Could not open the link',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          borderRadius: 20,
          margin: EdgeInsets.all(20),
        );
      }
    }
  }

  // ... (METHOD-METHOD LIKE/DISLIKE DAN LAINNYA TETAP SAMA)
  Widget _buildLikeDislikeButtons(BuildContext context, bool isDark) {
    return Positioned(
      left: 20,
      bottom: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TOMBOL LIKE - hanya tampil jika belum dislike
          if (!_isDisliked) 
            _buildLikeDislikeButton(
              icon: _isLiked ? Icons.thumb_up_off_alt_rounded : Icons.thumb_up_rounded,
              gradient: _isLiked 
                ? LinearGradient(colors: [Color(0xFF00D9A3), Color(0xFF2FFFBE)]) // Hijau solid ketika aktif
                : LinearGradient(colors: [Colors.grey[600]!, Colors.grey[500]!]), // Grey ketika tidak aktif
              onPressed: _handleLike,
              isActive: _isLiked,
            ),
          
          if (!_isDisliked && !_isLiked) SizedBox(height: 16),
          
          // TOMBOL DISLIKE - hanya tampil jika belum like
          if (!_isLiked)
            _buildLikeDislikeButton(
              icon: _isDisliked ? Icons.thumb_down_off_alt_rounded : Icons.thumb_down_rounded,
              gradient: _isDisliked
                ? LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)]) // Orange solid ketika aktif
                : LinearGradient(colors: [Colors.grey[600]!, Colors.grey[500]!]), // Grey ketika tidak aktif
              onPressed: _handleDislike,
              isActive: _isDisliked,
            ),
        ],
      ),
    );
  }

  Widget _buildLikeDislikeButton({
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: isActive ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ] : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                customBorder: CircleBorder(),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLikeSnackbar() {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00D9A3), Color(0xFF2FFFBE)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.thumb_up_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            'Suka Berita Ini!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
      messageText: Text(
        'Berita dengan tema seperti ini akan lebih banyak ditampilkan di beranda Anda',
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      backgroundColor: Color(0xFF00B589), // Hijau dark
      borderRadius: 20,
      margin: EdgeInsets.all(20),
      animationDuration: Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.elasticOut,
    );
  }

  void _showUnlikeSnackbar() {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.thumb_up_off_alt_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            'Tidak like Lagi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
      messageText: Text(
        'Preferensi berita Anda telah direset',
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.grey[700]!,
      borderRadius: 20,
      margin: EdgeInsets.all(20),
    );
  }

  void _showDislikeSnackbar() {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.thumb_down_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            'Tidak Suka Berita Ini',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
      messageText: Text(
        'Berita dengan tema seperti ini akan lebih sedikit ditampilkan di beranda Anda',
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      backgroundColor: Color(0xFFE55A2B), // Orange dark
      borderRadius: 20,
      margin: EdgeInsets.all(20),
      animationDuration: Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.elasticOut,
    );
  }

  void _showUndislikeSnackbar() {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.thumb_down_off_alt_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            'Tidak Dislike Lagi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
      messageText: Text(
        'Preferensi berita Anda telah direset',
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.grey[700]!,
      borderRadius: 20,
      margin: EdgeInsets.all(20),
    );
  }
}