import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      Helpers.triggerHapticLight();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1.0 - _controller.value;

    final theme = Theme.of(context);
    final buttonColor = widget.backgroundColor ?? theme.primaryColor;
    final contentColor = widget.textColor ?? (widget.isOutlined ? theme.primaryColor : Colors.white);

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(contentColor),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: contentColor),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: theme.textTheme.titleMedium?.copyWith(
            color: contentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        if (widget.onPressed != null && !widget.isLoading) {
          _controller.reverse();
        }
      },
      onTap: () {
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.onPressed == null
                ? Colors.grey.shade300
                : (widget.isOutlined ? Colors.transparent : buttonColor),
            border: widget.isOutlined
                ? Border.all(width: 1.5, color: buttonColor)
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: widget.isOutlined || widget.onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: buttonColor.withOpacity(0.24),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
