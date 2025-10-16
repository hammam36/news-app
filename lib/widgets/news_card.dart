import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';

class NewsCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsCard({Key? key, required this.article, required this.onTap})
      : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> 
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -4),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse().then((_) {
      widget.onTap();
    });
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  void _onHover(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _elevationAnimation,
          _slideAnimation,
          _shimmerController,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: _slideAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                        ? Colors.black.withOpacity(0.6 - (_elevationAnimation.value * 0.2))
                        : AppColors.shadow.withOpacity(0.15 + (_elevationAnimation.value * 0.15)),
                      blurRadius: 28 - (_elevationAnimation.value * 8),
                      offset: Offset(0, 12 - (_elevationAnimation.value * 6)),
                      spreadRadius: -8 + (_elevationAnimation.value * 4),
                    ),
                    if (_isHovered) ...[
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 32,
                        spreadRadius: -4,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: -2,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onTapDown: _onTapDown,
                    onTapUp: _onTapUp,
                    onTapCancel: _onTapCancel,
                    borderRadius: BorderRadius.circular(32),
                    splashColor: AppColors.primary.withOpacity(0.1),
                    highlightColor: AppColors.secondary.withOpacity(0.05),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isDark 
                          ? AppColors.cardGradientDark
                          : AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: _isHovered 
                            ? AppColors.primary.withOpacity(0.3)
                            : (isDark 
                                ? Colors.grey[700]!.withOpacity(0.3)
                                : AppColors.border.withOpacity(0.2)),
                          width: _isHovered ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Animated gradient overlay
                          if (_isHovered)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary.withOpacity(0.05),
                                      AppColors.secondary.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImageSection(context, isDark),
                              _buildContentSection(context, isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, bool isDark) {
    if (widget.article.urlToImage == null) {
      return _buildPlaceholderImage(isDark);
    }

    return Hero(
      tag: 'news_image_${widget.article.url}',
      child: Stack(
        children: [
          Container(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              child: CachedNetworkImage(
                imageUrl: widget.article.urlToImage!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildLoadingPlaceholder(isDark),
                errorWidget: (context, url, error) => _buildErrorPlaceholder(isDark),
              ),
            ),
          ),
          
          // Gradient overlay dengan parallax effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _elevationAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                        ? [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.2 + (_elevationAnimation.value * 0.2)),
                            Colors.black.withOpacity(0.4 + (_elevationAnimation.value * 0.2)),
                          ]
                        : [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.05 + (_elevationAnimation.value * 0.1)),
                            Colors.black.withOpacity(0.2 + (_elevationAnimation.value * 0.15)),
                          ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Source badge dengan glassmorphism
          if (widget.article.source?.name != null)
            Positioned(
              top: 16,
              left: 16,
              child: AnimatedBuilder(
                animation: _elevationAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_elevationAnimation.value * 0.05),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isHovered
                            ? AppColors.primary.withOpacity(0.5)
                            : (isDark
                                ? Colors.grey[600]!.withOpacity(0.5)
                                : Colors.white.withOpacity(0.8)),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 140),
                            child: Text(
                              widget.article.source!.name!,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time badge
          if (widget.article.publishedAt != null)
            AnimatedBuilder(
              animation: _elevationAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -2 * _elevationAnimation.value),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                        ? Colors.grey[800]!.withOpacity(0.8)
                        : AppColors.background.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                          ? Colors.grey[600]!.withOpacity(0.4)
                          : AppColors.border.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          timeago.format(DateTime.parse(widget.article.publishedAt!)),
                          style: TextStyle(
                            color: isDark
                              ? Colors.grey[400]!
                              : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          
          SizedBox(height: 16),
          
          // Title
          if (widget.article.title != null)
            AnimatedBuilder(
              animation: _elevationAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -3 * _elevationAnimation.value),
                  child: Text(
                    widget.article.title!,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          
          SizedBox(height: 12),
          
          // Description
          if (widget.article.description != null)
            AnimatedBuilder(
              animation: _elevationAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -2 * _elevationAnimation.value),
                  child: Text(
                    widget.article.description!,
                    style: TextStyle(
                      color: isDark
                        ? Colors.grey[400]!
                        : AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          
          SizedBox(height: 20),
          
          // Footer dengan CTA
          AnimatedBuilder(
            animation: _elevationAnimation,
            builder: (context, child) {
              return Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: _isHovered 
                        ? AppColors.heroGradient
                        : AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(
                            _isHovered ? 0.5 : 0.3
                          ),
                          blurRadius: _isHovered ? 16 : 10,
                          offset: Offset(0, _isHovered ? 6 : 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Read More',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: _isHovered ? 20 : 0,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  
                  // Reading time
                  if (widget.article.content != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                          ? Colors.grey[800]!.withOpacity(0.8)
                          : AppColors.background.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                            ? Colors.grey[600]!.withOpacity(0.4)
                            : AppColors.border.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 13,
                            color: isDark
                              ? Colors.grey[400]!
                              : AppColors.textHint,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '${(widget.article.content!.length / 200).ceil()} min',
                            style: TextStyle(
                              color: isDark
                                ? Colors.grey[400]!
                                : AppColors.textHint,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [Colors.grey[800]!, Colors.grey[700]!]
            : [
                AppColors.primary.withOpacity(0.05),
                AppColors.secondary.withOpacity(0.05),
              ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700]! : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : AppColors.shadow.withOpacity(0.1),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.article_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'News Article',
              style: TextStyle(
                color: isDark ? Colors.grey[400]! : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                ? [Colors.grey[800]!, Colors.grey[700]!]
                : [Color(0xFFE5E7EB), Color(0xFFF3F4F6)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(_shimmerController.value * 400 - 200, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                          ? [
                              Colors.grey[800]!.withOpacity(0),
                              Colors.grey[600]!.withOpacity(0.5),
                              Colors.grey[800]!.withOpacity(0),
                            ]
                          : [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0),
                            ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorPlaceholder(bool isDark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
            ? [Colors.grey[800]!, Colors.grey[700]!]
            : [
                AppColors.primary.withOpacity(0.05),
                AppColors.secondary.withOpacity(0.05),
              ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700]! : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : AppColors.shadow.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.image_not_supported_rounded,
                size: 32,
                color: isDark ? Colors.grey[400]! : AppColors.textHint,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Image unavailable',
              style: TextStyle(
                color: isDark ? Colors.grey[400]! : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}