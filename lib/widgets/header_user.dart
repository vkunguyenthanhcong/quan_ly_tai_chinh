import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

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
            CircleAvatar(
              radius: 24,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              backgroundColor: Colors.blueAccent,
              child: user.avatarUrl == null
                  ? Text(
                      user.fullName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Xin chào 👋",
                  style: TextStyle(color: Colors.white54),
                ),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
      children: const [
        CircleAvatar(radius: 24, backgroundColor: Colors.white24),
        SizedBox(width: 12),
        SizedBox(
          height: 14,
          width: 120,
          child: LinearProgressIndicator(),
        ),
      ],
    );
  }
}
