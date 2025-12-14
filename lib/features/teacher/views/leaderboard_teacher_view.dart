import 'package:cached_network_image/cached_network_image.dart';
import 'package:ciloka_app/features/teacher/models/class_teacher_model.dart';
import 'package:ciloka_app/features/teacher/viewmodels/auth_teacher_viewmodel.dart';
import 'package:ciloka_app/features/teacher/viewmodels/class_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeaderboardTeacherView extends StatelessWidget {
  const LeaderboardTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthTeacherViewmodel>(
      builder: (context, authVm, _) {
        final teacher = authVm.currentTeacher;

        if (teacher == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final teacherId = teacher.uid;

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
            child: SafeArea(child: _LeaderboardContent(teacherId: teacherId)),
          ),
        );
      },
    );
  }
}

class _LeaderboardContent extends StatefulWidget {
  final String teacherId;

  const _LeaderboardContent({required this.teacherId});

  @override
  State<_LeaderboardContent> createState() => _LeaderboardContentState();
}

class _LeaderboardContentState extends State<_LeaderboardContent> {
  String? _selectedClassId;

  @override
  Widget build(BuildContext context) {
    // Access ClassViewModel to get the list of classes
    final classVm = context.watch<ClassViewModel>();

    return StreamBuilder<List<ClassTeacherModel>>(
      stream: classVm.classStream,
      builder: (context, classSnapshot) {
        if (classSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final classes = classSnapshot.data ?? [];

        // Auto-select the first class if none is selected and classes exist
        if (_selectedClassId == null && classes.isNotEmpty) {
          // Use addPostFrameCallback to avoid state modification during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedClassId = classes.first.id;
              });
            }
          });
        }

        // Determine which class is selected for display text
        // (Optional check to ensure selected ID is still valid)
        final isValidSelection =
            _selectedClassId == 'all' ||
            classes.any((c) => c.id == _selectedClassId);

        if (!isValidSelection && _selectedClassId != null) {
          // Reset if invalid
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedClassId = classes.isNotEmpty ? classes.first.id : null;
              });
            }
          });
        }

        final selectedClassModel = classes.isEmpty
            ? null
            : classes.cast<ClassTeacherModel?>().firstWhere(
                (c) => c!.id == _selectedClassId,
                orElse: () => null,
              );

        // Firestore Query
        Query query = FirebaseFirestore.instance.collection('student_index');

        // Apply filters
        query = query.where('teacherId', isEqualTo: widget.teacherId);

        if (_selectedClassId != null && _selectedClassId != 'all') {
          query = query.where('classId', isEqualTo: _selectedClassId);
        }

        return StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            // Sort & Convert
            final entries = docs.map((d) {
              final m = d.data() as Map<String, dynamic>;
              return _StudentEntry(
                studentId: (m['studentId'] ?? '') as String,
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
                    _buildHeader(classes, selectedClassModel),
                    const SizedBox(height: 10),
                    if (entries.isEmpty)
                      Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      )
                    else
                      _Podium(topStudents: top3),
                    // Add some space at the bottom separate from the sheet
                    const SizedBox(height: 180),
                  ],
                ),

                // 2. Draggable Sheet
                DraggableScrollableSheet(
                  initialChildSize: 0.47,
                  minChildSize: 0.47,
                  maxChildSize: 0.92,
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
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
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
                                      return _buildListRow(student, rank);
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
      },
    );
  }

  Widget _buildHeader(
    List<ClassTeacherModel> classes,
    ClassTeacherModel? selectedClass,
  ) {
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
                  // Dropdown for Class Selection
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedClassId,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        dropdownColor: const Color(0xFF91CDFF),
                        borderRadius: BorderRadius.circular(12),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        hint: const Text(
                          "Pilih Kelas",
                          style: TextStyle(color: Colors.white),
                        ),
                        items: [
                          // All Classes Option
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('Semua Kelas'),
                          ),
                          ...classes.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text('Kelas ${c.grade} ${c.className}'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedClassId = val;
                            });
                          }
                        },
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
                  Icons.monitor_heart,
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

  Widget _buildListRow(_StudentEntry student, int rank) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<_StudentEntry> topStudents;

  const _Podium({required this.topStudents});

  @override
  Widget build(BuildContext context) {
    if (topStudents.isEmpty) return const SizedBox();

    final rank1 = topStudents.isNotEmpty ? topStudents[0] : null;
    final rank2 = topStudents.length > 1 ? topStudents[1] : null;
    final rank3 = topStudents.length > 2 ? topStudents[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2
          if (rank2 != null)
            Expanded(child: _PodiumItem(student: rank2, rank: 2, height: 140)),
          // Rank 1
          if (rank1 != null)
            Expanded(
              child: _PodiumItem(
                student: rank1,
                rank: 1,
                height: 180, // slightly taller
                isFirst: true,
              ),
            ),
          // Rank 3
          if (rank3 != null)
            Expanded(child: _PodiumItem(student: rank3, rank: 3, height: 120)),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatefulWidget {
  final _StudentEntry student;
  final int rank;
  final double height;
  final bool isFirst;

  const _PodiumItem({
    required this.student,
    required this.rank,
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

    // Different delays for each rank
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
                  Positioned(
                    top: -26,
                    child: const Icon(
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
                      boxShadow: [
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
                fontWeight: FontWeight.w600,
                fontSize: widget.isFirst ? 15 : 13,
                shadows: [
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
  final String studentName;
  final String photoUrl;
  final int level;
  final int totalPoints;

  _StudentEntry({
    required this.studentId,
    required this.studentName,
    required this.photoUrl,
    required this.level,
    this.totalPoints = 0,
  });
}
