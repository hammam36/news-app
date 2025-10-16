import 'package:flutter/material.dart';
import 'package:news_app/utils/app_colors.dart';

class LoadingShimmer extends StatefulWidget {
  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                        ? Colors.black.withOpacity(0.4)
                        : AppColors.shadow.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark 
                        ? AppColors.cardGradientDark 
                        : AppColors.cardGradient,
                      border: Border.all(
                        color: isDark 
                          ? AppColors.borderDark.withOpacity(0.3)
                          : AppColors.border.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image placeholder with animated shimmer
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                    ? [
                                        Color(0xFF2D3339),
                                        Color(0xFF3D4349),
                                      ]
                                    : [
                                        Color(0xFFE5E7EB),
                                        Color(0xFFF3F4F6),
                                      ],
                                ),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(_animation.value * 400, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                    gradient: LinearGradient(
                                      colors: isDark
                                        ? [
                                            Color(0xFF2D3339).withOpacity(0),
                                            Color(0xFF4D5359).withOpacity(0.5),
                                            Color(0xFF2D3339).withOpacity(0),
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
                            // Pulsating overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(28),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      (isDark ? Colors.black : Colors.white)
                                        .withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time badge shimmer
                              _buildShimmerBox(
                                width: 80,
                                height: 24,
                                borderRadius: 12,
                                isDark: isDark,
                              ),
                              SizedBox(height: 16),
                              
                              // Title shimmer
                              _buildShimmerBox(
                                width: double.infinity,
                                height: 20,
                                borderRadius: 8,
                                isDark: isDark,
                              ),
                              SizedBox(height: 8),
                              _buildShimmerBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 20,
                                borderRadius: 8,
                                isDark: isDark,
                              ),
                              SizedBox(height: 16),
                              
                              // Description shimmer
                              _buildShimmerBox(
                                width: double.infinity,
                                height: 14,
                                borderRadius: 6,
                                isDark: isDark,
                              ),
                              SizedBox(height: 6),
                              _buildShimmerBox(
                                width: double.infinity,
                                height: 14,
                                borderRadius: 6,
                                isDark: isDark,
                              ),
                              SizedBox(height: 6),
                              _buildShimmerBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: 14,
                                borderRadius: 6,
                                isDark: isDark,
                              ),
                              SizedBox(height: 20),
                              
                              // Button shimmer
                              Row(
                                children: [
                                  _buildShimmerBox(
                                    width: 120,
                                    height: 36,
                                    borderRadius: 12,
                                    isDark: isDark,
                                    gradient: true,
                                  ),
                                  Spacer(),
                                  _buildShimmerBox(
                                    width: 60,
                                    height: 28,
                                    borderRadius: 10,
                                    isDark: isDark,
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
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
    required bool isDark,
    bool gradient = false,
  }) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: gradient 
              ? (isDark 
                  ? LinearGradient(
                      colors: [
                        Color(0xFF3D4349),
                        Color(0xFF4D5359),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Color(0xFFFF6B35).withOpacity(0.2),
                        Color(0xFF00D9A3).withOpacity(0.2),
                      ],
                    ))
              : null,
            color: gradient 
              ? null 
              : (isDark ? Color(0xFF2D3339) : Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_animation.value * width, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  colors: isDark
                    ? [
                        Color(0xFF2D3339).withOpacity(0),
                        Color(0xFF5D6369).withOpacity(0.3),
                        Color(0xFF2D3339).withOpacity(0),
                      ]
                    : [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0),
                      ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}