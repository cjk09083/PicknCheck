import 'package:flutter/material.dart';
import 'package:loginenne/main.dart';

import 'package:fluttertoast/fluttertoast.dart';

enum ToastType {
  info,
  error,
  success,
  warn,
}

class ToastsColorProps {
  final Color textColor;
  final Color backgroundColor;
  ToastsColorProps(this.textColor, this.backgroundColor);
}

class ToastNotification {
  final FToast toast;

  ToastNotification(this.toast);

  /// Return text and background color for toasts type
  ToastsColorProps _getToastColor(ToastType type) {
    if (type == ToastType.success) {
      return ToastsColorProps(
        AppColors.successTextColor,
        AppColors.successBgColor,
      );
    } else if (type == ToastType.error) {
      return ToastsColorProps(
          AppColors.errorTextColor, AppColors.errorBgColor);
    } else if (type == ToastType.warn) {
      return ToastsColorProps(
          AppColors.warnTextColor, AppColors.warnBgColor);
    } else {
      return ToastsColorProps(
          AppColors.infoTextColor, AppColors.infoBgColor);
    }
  }

  /// Display the toast on the overlay
  void _showToast(ToastType type, String content, IconData icon) {
    toast.showToast(
      child: _buildToast(type, content, icon),
      gravity: ToastGravity.CENTER,
    );
  }

  /// Display Success toast
  void success(String content) {
    _showToast(ToastType.success, content, Icons.check);
  }

  /// Display Error toast
  void error(String content) {
    _showToast(ToastType.error, content, Icons.error);
  }

  /// Display Info toast
  void info(String content) {
    _showToast(ToastType.info, content, Icons.info);
  }

  /// Display Warning toast
  void warn(String content) {
    _showToast(ToastType.warn, content, Icons.warning);
  }

  /// Construct the toast notification Widget structure
  Widget _buildToast(
      ToastType type,
      String content,
      IconData icon,
      ) =>
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 560, maxWidth: 360),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _getToastColor(type).backgroundColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _getToastColor(type).textColor),
              SizedBox(width: 16),
              Flexible(
                child: Text(
                  content,
                  style: TextStyle(
                    color: _getToastColor(type).textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}