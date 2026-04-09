import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double blurSigma;
  final double opacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = const EdgeInsets.all(16),
    this.blurSigma = 14,
    this.opacity = 0.14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: opacity),
                Colors.white.withValues(alpha: opacity * 0.55),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Reusable card component matching modern dark theme
class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool glassy;
  final double glassBlurSigma;
  final double glassOpacity;
  final bool animateIn;
  final Duration animateInDelay;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.glassy = true,
    this.glassBlurSigma = 14,
    this.glassOpacity = 0.14,
    this.animateIn = true,
    this.animateInDelay = Duration.zero,
  }) : super(key: key);

  const ModernCard.glass({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.glassBlurSigma = 14,
    this.glassOpacity = 0.14,
    this.animateIn = true,
    this.animateInDelay = Duration.zero,
  })  : glassy = true,
        super(key: key);

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  bool _pressed = false;
  double _appear = 1;

  @override
  void initState() {
    super.initState();
    if (widget.animateIn) {
      _appear = 0;
      Future.delayed(widget.animateInDelay, () {
        if (!mounted) return;
        setState(() => _appear = 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final cardColor = widget.backgroundColor ?? const Color(0xFF2A2A2A);

    final content = widget.glassy
        ? GlassContainer(
            borderRadius: borderRadius,
            padding: widget.padding,
            blurSigma: widget.glassBlurSigma,
            opacity: widget.glassOpacity,
            child: widget.child,
          )
        : ClipRRect(
            borderRadius: borderRadius,
            child: ColoredBox(
              color: cardColor,
              child: Padding(padding: widget.padding, child: widget.child),
            ),
          );

    final card = AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: borderRadius,
            splashColor: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.12),
            highlightColor: Colors.white.withValues(alpha: 0.03),
            child: content,
          ),
        ),
      ),
    );

    if (!widget.animateIn) return card;

    return AnimatedOpacity(
      opacity: _appear,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: Offset(0, (1 - _appear) * 0.035),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: card,
      ),
    );
  }
}

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const AnimatedListItem({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final totalMs = (duration + delay).inMilliseconds;
        final shift = totalMs == 0 ? 0.0 : delay.inMilliseconds / totalMs;
        final denom = (1 - shift).clamp(0.0001, 1.0);
        final t = ((value - shift) / denom).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
    );
  }
}

/// Post card for social feed
class PostCard extends StatelessWidget {
  final String userName;
  final String userInitial;
  final String content;
  final int likes;
  final int comments;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    Key? key,
    required this.userName,
    required this.userInitial,
    required this.content,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard.glass(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'قبل ساعة',
                      style: TextStyle(fontSize: 12, color: Color(0xFF808080)),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF43A047),
                  child: Text(
                    userInitial,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              content,
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(height: 16),
          // Actions
          Divider(color: Color(0xFF404040), height: 1),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onComment,
                    icon: Icon(Icons.comment, size: 20),
                    label: Text('$comments'),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF43A047),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onLike,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isLiked ? Color(0xFFCF6679) : Color(0xFF43A047),
                    ),
                    label: Text('$likes'),
                    style: TextButton.styleFrom(
                      foregroundColor: isLiked
                          ? Color(0xFFCF6679)
                          : Color(0xFF43A047),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onShare,
                    icon: Icon(Icons.share, size: 20),
                    label: Text('شارك'),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF43A047),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stadium card component
class StadiumCard extends StatelessWidget {
  final String name;
  final String location;
  final double rating;
  final String price;
  final String? image;
  final List<String> photos;
  final VoidCallback? onTap;

  const StadiumCard({
    Key? key,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    this.image,
    this.photos = const [],
    this.onTap,
  }) : super(key: key);

  ImageProvider _photoProvider(String value) {
    final v = value.trim();
    if (v.isEmpty) return const AssetImage('assets/images/studim.jpeg');
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }
    try {
      final cleaned = v.startsWith('data:image')
          ? v.substring(v.indexOf('base64,') + 'base64,'.length)
          : v;
      final bytes = base64.decode(cleaned);
      return MemoryImage(bytes);
    } catch (_) {
      return const AssetImage('assets/images/studim.jpeg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = image ?? (photos.isNotEmpty ? photos.first : '');
    return ModernCard.glass(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image(
                  image: _photoProvider(displayImage),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF9800), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF808080)),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF43A047)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$price ج.م / ساعة',
                        style: const TextStyle(
                          color: Color(0xFF43A047),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Text(
                      'احجز الآن',
                      style: TextStyle(
                        color: Color(0xFF43A047),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// User profile card
class UserCard extends StatelessWidget {
  final String name;
  final String position;
  final double rating;
  final int matches;
  final VoidCallback? onTap;

  const UserCard({
    Key? key,
    required this.name,
    required this.position,
    required this.rating,
    required this.matches,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard.glass(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF43A047),
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        position,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Color(0xFF404040), height: 1),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_soccer, size: 16, color: Color(0xFF43A047)),
                  SizedBox(width: 4),
                  Text('$matches', style: TextStyle(color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Color(0xFFFF9800)),
                  SizedBox(width: 4),
                  Text(
                    '$rating',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom AppBar for consistency
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final VoidCallback? onNotificationTap;
  final bool glassy;

  const ModernAppBar({
    Key? key,
    required this.title,
    this.showNotification = true,
    this.onNotificationTap,
    this.glassy = true,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: glassy ? Colors.transparent : const Color(0xFF1E1E1E),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      flexibleSpace: glassy
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      actions: showNotification
          ? [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: onNotificationTap,
                    child: Badge(
                      child: Icon(
                        Icons.notifications,
                        color: Color(0xFF43A047),
                      ),
                    ),
                  ),
                ),
              ),
            ]
          : [],
    );
  }
}

/// Loading indicator
class ModernLoading extends StatelessWidget {
  final String? message;

  const ModernLoading({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF43A047)),
          ),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(message!, style: TextStyle(color: Color(0xFF808080))),
          ],
        ],
      ),
    );
  }
}

/// Empty state
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color(0xFF808080), size: 48),
          SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
          if (subtitle != null) ...[
            SizedBox(height: 8),
            Text(subtitle!, style: TextStyle(color: Color(0xFF808080))),
          ],
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.add),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
