import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';
import 'package:quan_ly_chi_tieu/models/user_model.dart';
import 'package:quan_ly_chi_tieu/services/user_service.dart';

class HeaderUser extends StatelessWidget {
  const HeaderUser({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        if (snapshot.hasError) {
          return const Text(
            "Không tải được thông tin người dùng",
            style: TextStyle(color: Colors.red),
          );
        }

        final user = UserModel.fromMap(snapshot.data!);

        return Row(
          children: [
            /// ===== AVATAR =====
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accent.withOpacity(0.15),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            /// ===== TEXT =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Xin chào 👋",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _loading() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.textSecondary.withOpacity(0.1),
        ),
        const SizedBox(width: 12),
        Container(
          height: 14,
          width: 120,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}