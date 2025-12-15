import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_parent_viewmodel.dart';

class LeaderboardParentView extends StatelessWidget {
  const LeaderboardParentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthParentViewmodel>(
      builder: (context, authVm, _) {
        final parentData = authVm.currentParentData;

        if (parentData == null) {
          return const Scaffold(
            body: Center(child: Text('Data tidak ditemukan')),
          );
        }

        final String currentClassId = (parentData['classId'] ?? '') as String;
        final String currentTeacherId =
            (parentData['teacherId'] ?? '') as String;
        final String grade = (parentData['grade'] ?? '-') as String;
        final String className = (parentData['className'] ?? '-') as String;
        // Gunakan studentId dari data siswa yang sedang dipantau
        final String currentStudentId =
            (parentData['studentId'] ?? '') as String;

        // Jika studentId kosong (misal siswa belum pernah login), kita bisa fallback ke match NIS?
        // Tapi leaderboard query biasanya pakai teacherId.
        // Untuk highlight 'Anak Anda', kita butuh identifier unik.
        // Jika studentId kosong, kita bisa pakai 'nis'.
        final String currentNis = (parentData['nis'] ?? '') as String;

        if (currentClassId.isEmpty || currentTeacherId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Data kelas belum lengkap')),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 145, 205, 255), // Light Blue
                  Color(0xFFB0DAFD), // Deep Blue
                ],
              ),
            ),
            child: SafeArea(
              child: _LeaderboardContent(
                grade: grade,
                className: className,
                classId: currentClassId,
                teacherId: currentTeacherId,
                currentStudentId: currentStudentId,
                currentNis: currentNis,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  final String grade;
  final String className;
  final String classId;
  final String teacherId;
  final String currentStudentId;
  final String currentNis;

  const _LeaderboardContent({
    required this.grade,
    required this.className,
    required this.classId,
    required this.teacherId,
    required this.currentStudentId,
    required this.currentNis,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 Using Stack to overlay DraggableScrollableSheet
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('student_index')
          .where('teacherId', isEqualTo: teacherId)
          .where('classId', isEqualTo: classId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading leaderboard"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text("Belum ada data"));
        }

        // Sort & Convert
        final entries = docs.map((d) {
          final m = d.data() as Map<String, dynamic>;
          return _StudentEntry(
            studentId: (m['studentId'] ?? '') as String,
            nis: (m['nis'] ?? '') as String,
            studentName: (m['studentName'] ?? 'Siswa') as String,
            photoUrl: (m['photoUrl'] ?? '') as String,
            level: (m['currentLevel'] ?? 1) as int,
            totalPoints: (m['totalPoints'] ?? 0) as int,
          );
        }).toList();

        // Sort by Points DESC
        entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

        final top3 = entries.take(3).toList();
        final others = entries.skip(3).toList();

        return Stack(
          children: [
            // 1. Background Content (Header & Podium)
            Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                Podium(
                  topStudents: top3,
                  currentStudentId: currentStudentId,
                  currentNis: currentNis,
                ),
                // Add some space at the bottom so podium isn't hidden by default sheet position
                const SizedBox(height: 180),
              ],
            ),

            // 2. Draggable Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.47, // Covers about half screen initially
              minChildSize: 0.47,
              maxChildSize: 0.92, // Scrolled up almost to top
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // 📋 List Content
                      Expanded(
                        child: others.isEmpty
                            ? Center(
                                child: Text(
                                  "Belum ada siswa lain",
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              )
                            : ListView.separated(
                                controller:
                                    scrollController, // 🔑 Essential for drag sync
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                itemCount: others.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final student = others[index];
                                  final rank = index + 4;
                                  // Check by ID or NIS
                                  final isMyChild =
                                      (currentStudentId.isNotEmpty &&
                                          student.studentId ==
                                              currentStudentId) ||
                                      (student.nis == currentNis);
                                  return _buildListRow(
                                    student,
                                    rank,
                                    isMyChild,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Leaderboard",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'Kelas $grade $className',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(_StudentEntry student, int rank, bool isMyChild) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMyChild ? const Color(0xFFF0F4FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMyChild
            ? Border.all(color: const Color(0xFF4A00E0), width: 1.5)
            : Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(
              "$rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundImage: student.photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(student.photoUrl)
                : null,
            child: student.photoUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName,
                  style: TextStyle(
                    fontWeight: isMyChild ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Level ${student.level}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 14,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${student.totalPoints} pts",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isMyChild)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF4A00E0).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Anak Anda",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A00E0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Podium extends StatelessWidget {
  final List<_StudentEntry> topStudents;
  final String currentStudentId;
  final String currentNis;

  const Podium({
    super.key,
    required this.topStudents,
    required this.currentStudentId,
    required this.currentNis,
  });

  @override
  Widget build(BuildContext context) {
    if (topStudents.isEmpty) return const SizedBox();

    final rank1 = topStudents.isNotEmpty ? topStudents[0] : null;
    final rank2 = topStudents.length > 1 ? topStudents[1] : null;
    final rank3 = topStudents.length > 2 ? topStudents[2] : null;

    final isMyChild1 =
        rank1 != null &&
        ((currentStudentId.isNotEmpty && rank1.studentId == currentStudentId) ||
            rank1.nis == currentNis);
    final isMyChild2 =
        rank2 != null &&
        ((currentStudentId.isNotEmpty && rank2.studentId == currentStudentId) ||
            rank2.nis == currentNis);
    final isMyChild3 =
        rank3 != null &&
        ((currentStudentId.isNotEmpty && rank3.studentId == currentStudentId) ||
            rank3.nis == currentNis);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2
          if (rank2 != null)
            Expanded(
              child: _PodiumItem(
                student: rank2,
                rank: 2,
                isMyChild: isMyChild2,
                height: 140,
              ),
            ),
          // Rank 1
          if (rank1 != null)
            Expanded(
              child: _PodiumItem(
                student: rank1,
                rank: 1,
                isMyChild: isMyChild1,
                height: 180, // slightly taller
                isFirst: true,
              ),
            ),
          // Rank 3
          if (rank3 != null)
            Expanded(
              child: _PodiumItem(
                student: rank3,
                rank: 3,
                isMyChild: isMyChild3,
                height: 120,
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatefulWidget {
  final _StudentEntry student;
  final int rank;
  final bool isMyChild;
  final double height;
  final bool isFirst;

  const _PodiumItem({
    required this.student,
    required this.rank,
    required this.isMyChild,
    required this.height,
    this.isFirst = false,
  });

  @override
  State<_PodiumItem> createState() => _PodiumItemState();
}

class _PodiumItemState extends State<_PodiumItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Different delays for each rank: rank 1 appears first, then 2 and 3
    final delayMs = widget.rank == 1 ? 200 : (widget.rank == 2 ? 400 : 600);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1.5), // Start from below
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation after delay
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gold, Silver, Bronze
    final Color borderColor = widget.rank == 1
        ? const Color(0xFFFFD700)
        : (widget.rank == 2
              ? const Color(0xFFC0C0C0)
              : const Color(0xFFCD7F32));

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Avatar + Crown
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: widget.isFirst ? 3.5 : 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: widget.isFirst ? 40 : 30, // Larger avatars
                    backgroundImage: widget.student.photoUrl.isNotEmpty
                        ? CachedNetworkImageProvider(widget.student.photoUrl)
                        : null,
                    child: widget.student.photoUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: widget.isFirst ? 30 : 24,
                          )
                        : null,
                  ),
                ),
                if (widget.isFirst)
                  const Positioned(
                    top: -26,
                    child: Icon(
                      Icons.workspace_premium,
                      color: Color(0xFFFFD700),
                      size: 36,
                    ),
                  ),
                Positioned(
                  bottom: -10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: borderColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "${widget.rank}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              widget.student.studentName,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: widget.isMyChild
                    ? FontWeight.w800
                    : FontWeight.w600,
                fontSize: widget.isFirst ? 15 : 13,
                shadows: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
            Text(
              "Lvl ${widget.student.level}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Podium Box
            Container(
              height: widget.height - 60,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  left: BorderSide(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                  right: BorderSide(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${widget.student.totalPoints} PTS",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentEntry {
  final String studentId;
  final String nis;
  final String studentName;
  final String photoUrl;
  final int level;
  final int totalPoints;

  _StudentEntry({
    required this.studentId,
    required this.nis,
    required this.studentName,
    required this.photoUrl,
    required this.level,
    this.totalPoints = 0,
  });
}
