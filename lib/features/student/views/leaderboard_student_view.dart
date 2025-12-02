import 'package:ciloka_app/core/theme/app_spacing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaderboardStudentView extends StatelessWidget {
  const LeaderboardStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Kamu belum login')));
    }

    final String currentUid = currentUser.uid;

    // Stream: cari student_index milik siswa yang login → dapet classId & teacherId
    final studentIndexStream = FirebaseFirestore.instance
        .collection('student_index')
        .where('studentId', isEqualTo: currentUid)
        .limit(1)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF29B6F6),
        automaticallyImplyLeading: false,
        title: const Text(
          'Peringkat Kelas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFB0DAFD),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: studentIndexStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Terjadi kesalahan mengambil data siswa',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Data siswa tidak ditemukan 😢',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final doc = snapshot.data!.docs.first;
              final data = doc.data() as Map<String, dynamic>;

              final String classId = data['classId'] ?? '';
              final String teacherId = data['teacherId'] ?? '';

              if (classId.isEmpty || teacherId.isEmpty) {
                return const Center(
                  child: Text(
                    'Data kelas belum lengkap',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // Stream leaderboard: semua siswa di kelas & guru yang sama
              // ⚠️ TANPA orderBy, jadi gak perlu composite index
              final leaderboardStream = FirebaseFirestore.instance
                  .collection('student_index')
                  .where('teacherId', isEqualTo: teacherId)
                  .where('classId', isEqualTo: classId)
                  .snapshots();

              return StreamBuilder<QuerySnapshot>(
                stream: leaderboardStream,
                builder: (context, lbSnapshot) {
                  if (lbSnapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Terjadi kesalahan mengambil leaderboard',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (lbSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!lbSnapshot.hasData || lbSnapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada peringkat di kelas ini',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  // Sort di client: currentLevel terbesar → teratas
                  final docs = lbSnapshot.data!.docs.toList()
                    ..sort((a, b) {
                      final da = a.data() as Map<String, dynamic>;
                      final db = b.data() as Map<String, dynamic>;
                      final la = (da['currentLevel'] ?? 1) as int;
                      final lb = (db['currentLevel'] ?? 1) as int;
                      return lb.compareTo(la);
                    });

                  return Column(
                    children: [
                      AppSpacing.vMd,
                      _buildHeaderTrophy(context),
                      AppSpacing.vSm,
                      _buildClassInfoBanner(classId),
                      AppSpacing.vSm,
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 12, thickness: 0.3),
                            itemBuilder: (context, index) {
                              final d =
                                  docs[index].data() as Map<String, dynamic>;

                              final String name =
                                  d['studentName'] ?? 'Tanpa Nama';
                              final int level = d['currentLevel'] ?? 1;
                              final String studentId = d['studentId'] ?? '';

                              final int rank = index + 1;
                              final bool isMe = studentId == currentUid;

                              return _buildLeaderboardRow(
                                context: context,
                                rank: rank,
                                name: name,
                                level: level,
                                isMe: isMe,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // 🏆 Header trophy
  Widget _buildHeaderTrophy(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.emoji_events, size: 110, color: Colors.amber.shade400),
            Positioned(
              top: 38,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Papan Peringkat Kelas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 🎓 Banner info kelas (sementara cuma tampilkan classId)
  Widget _buildClassInfoBanner(String classId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.class_, size: 16, color: Color(0xFF1976D2)),
          const SizedBox(width: 6),
          Text(
            'Kelas: $classId',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 🔢 1 baris leaderboard
  Widget _buildLeaderboardRow({
    required BuildContext context,
    required int rank,
    required String name,
    required int level,
    required bool isMe,
  }) {
    final Color baseColor = isMe ? const Color(0xFFE3F2FD) : Colors.white;
    final FontWeight nameWeight = isMe ? FontWeight.w800 : FontWeight.w600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildRankBadge(rank),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: nameWeight, fontSize: 14),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Text(
                        '(Kamu)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.videogame_asset,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Level $level',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  // 🥇 Badge rank (1,2,3 medali; lainnya bulat biasa)
  Widget _buildRankBadge(int rank) {
    Color bg;
    IconData? icon;

    if (rank == 1) {
      bg = Colors.amber.shade400;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      bg = Colors.grey.shade400;
      icon = Icons.emoji_events;
    } else if (rank == 3) {
      bg = Colors.brown.shade300;
      icon = Icons.emoji_events;
    } else {
      bg = Colors.blueGrey.shade100;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 20, color: Colors.white)
            : Text(
                '$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
