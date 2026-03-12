import 'package:flutter/material.dart';

/// Reusable card component matching modern dark theme
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const ModernCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: padding, child: child),
      ),
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
    return ModernCard(
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
  final VoidCallback? onTap;

  const StadiumCard({
    Key? key,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Color(0xFF43A047), size: 16),
                  SizedBox(width: 4),
                  Text(
                    '$rating',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF43A047),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  name,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.location_on, size: 14, color: Color(0xFF808080)),
              SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(fontSize: 12, color: Color(0xFF808080)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: Color(0xFF404040), height: 1),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: Color(0xFF43A047),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                'ساعة',
                style: TextStyle(fontSize: 12, color: Color(0xFF808080)),
              ),
            ],
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
    return ModernCard(
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

  const ModernAppBar({
    Key? key,
    required this.title,
    this.showNotification = true,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
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
