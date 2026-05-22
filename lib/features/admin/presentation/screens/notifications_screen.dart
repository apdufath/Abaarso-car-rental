import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';

class BroadcastNotification {
  final String title;
  final String body;
  final String target;
  final DateTime sentAt;

  BroadcastNotification({
    required this.title,
    required this.body,
    required this.target,
    required this.sentAt,
  });
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedTarget = 'All Customers';

  final List<BroadcastNotification> _history = [
    BroadcastNotification(
      title: 'Kireyso Land Cruiser Cusub!',
      body: 'Hel qiimo dhimis dhan 15% maanta oo keliya Hargeisa. Buug garee hadda!',
      target: 'All Customers',
      sentAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BroadcastNotification(
      title: 'Darawalada: Fariin Degdeg Ah',
      body: 'Fadlan hubi in gaarigu nadiif yahay ka hor inta aanad ku wareejin macaamilka.',
      target: 'Drivers',
      sentAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BroadcastNotification(
      title: 'Weekend Special Discount',
      body: 'Rent any luxury vehicle and get free delivery anywhere in Hargeisa.',
      target: 'All Customers',
      sentAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendNotification() {
    if (!_formKey.currentState!.validate()) return;

    Helpers.triggerHapticMedium();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _SendingProgressDialog(
          onComplete: () {
            setState(() {
              _history.insert(
                0,
                BroadcastNotification(
                  title: _titleController.text.trim(),
                  body: _bodyController.text.trim(),
                  target: _selectedTarget,
                  sentAt: DateTime.now(),
                ),
              );
              _titleController.clear();
              _bodyController.clear();
            });
            
            // Show custom snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Text('FCM Notification broadcasted successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Broadcast / Farriimaha'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Push Notification Dispatcher',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Broadcast real-time push notifications to customer and driver applications across Somaliland directly through Firebase Cloud Messaging.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Form container
            Text(
              'NEW BROADCAST / FARRIIN CUSUB',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target selection
                    const Text(
                      'Target Audience / Kooxda Loo Dirayo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _AudienceChip(
                          label: 'All Customers',
                          isSelected: _selectedTarget == 'All Customers',
                          onSelected: (val) {
                            Helpers.triggerHapticLight();
                            setState(() => _selectedTarget = 'All Customers');
                          },
                        ),
                        const SizedBox(width: 8),
                        _AudienceChip(
                          label: 'Drivers',
                          isSelected: _selectedTarget == 'Drivers',
                          onSelected: (val) {
                            Helpers.triggerHapticLight();
                            setState(() => _selectedTarget = 'Drivers');
                          },
                        ),
                        const SizedBox(width: 8),
                        _AudienceChip(
                          label: 'Admins',
                          isSelected: _selectedTarget == 'Admins',
                          onSelected: (val) {
                            Helpers.triggerHapticLight();
                            setState(() => _selectedTarget = 'Admins');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'Notification Title / Ciwaanka Farriinta',
                        hintText: 'e.g. Qiimo dhimis fasaxa usbuuca',
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a notification title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Body
                    TextFormField(
                      controller: _bodyController,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: InputDecoration(
                        labelText: 'Notification Message / Nuxurka Farriinta',
                        hintText: 'Write details here...',
                        labelStyle: const TextStyle(fontSize: 14),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a notification message';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    CustomButton(
                      text: 'Broadcast Message Now',
                      icon: Icons.send_rounded,
                      onPressed: _sendNotification,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Dispatch History
            Text(
              'DISPATCH HISTORY / FARRIIMAHA LA DIRAY',
              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getAudienceColor(item.target).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.target.toUpperCase(),
                              style: TextStyle(
                                color: _getAudienceColor(item.target),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _formatSentTime(item.sentAt),
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getAudienceColor(String target) {
    switch (target) {
      case 'All Customers':
        return AppColors.primary;
      case 'Drivers':
        return AppColors.success;
      case 'Admins':
        return AppColors.secondary;
      default:
        return Colors.grey;
    }
  }

  String _formatSentTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}

class _AudienceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _AudienceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.shade200,
      elevation: 0,
      pressElevation: 0,
    );
  }
}

class _SendingProgressDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _SendingProgressDialog({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<_SendingProgressDialog> createState() => _SendingProgressDialogState();
}

class _SendingProgressDialogState extends State<_SendingProgressDialog> with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _checkScale = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);

    _startSimulation();
  }

  Future<void> _startSimulation() async {
    // 1. Simulate server time-out delay for Firebase API call
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // 2. Play Success Haptic feedback
    Helpers.triggerHapticSuccess();

    setState(() {
      _isSuccess = true;
    });

    _checkController.forward();

    // 3. Auto dismiss after checkmark anim completes
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.pop(context);
    widget.onComplete();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 90,
              width: 90,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !_isSuccess
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 4,
                      )
                    : ScaleTransition(
                        scale: _checkScale,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 54,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              !_isSuccess ? 'Dispatching Broadcast...' : 'Broadcast Sent Successfully!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              !_isSuccess
                  ? 'FCM server resolving target devices...'
                  : 'Message successfully pushed to clients.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
