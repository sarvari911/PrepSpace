import 'package:material_ui/material_ui.dart';
import '../../domain/models/module.dart';
import '../../domain/models/subject.dart';
import '../../domain/models/topic.dart';
import '../../domain/models/topic_status.dart';
import '../../domain/models/study_stats.dart';

class SeedData {
  SeedData._();

  static StudyStats get defaultStudyStats {
    return const StudyStats(
      dayStreak: 0,
      lastActiveDate: null,
      totalCompletedCount: 0,
    );
  }

  static List<Subject> get defaultSubjects {
    final now = DateTime.now();

    return [
      // 1. Data Structures & Algorithms
      Subject(
        id: 'subject_dsa',
        title: 'Data Structures & Algorithms',
        subtitle: 'Arrays, Trees, Graphs and more',
        iconCodePoint: Icons.code.codePoint,
        iconFontFamily: Icons.code.fontFamily,
        colorValue: 0xFF6558D3,
        modules: [
          Module(
            id: 'mod_dsa_1',
            title: 'Arrays & Strings',
            description: 'Two pointers, sliding window, and prefix sums',
            topics: [
              Topic(
                id: 'top_dsa_1',
                title: 'Two Sum & Sorted Array Search',
                description: 'Hash map lookups and two-pointer technique',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 10)),
                completedAt: now.subtract(const Duration(days: 8)),
              ),
              Topic(
                id: 'top_dsa_2',
                title: 'Sliding Window Maximum & Min Subarray',
                description: 'Fixed and dynamic sliding window patterns',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 9)),
                completedAt: now.subtract(const Duration(days: 7)),
              ),
              Topic(
                id: 'top_dsa_3',
                title: 'Trapping Rainwater',
                description: 'Monotonic stack and two-pointer approaches',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 8)),
                completedAt: now.subtract(const Duration(days: 6)),
              ),
            ],
          ),
          Module(
            id: 'mod_dsa_2',
            title: 'Trees & Graphs',
            description: 'Traversals, BFS, DFS, and shortest paths',
            topics: [
              Topic(
                id: 'top_dsa_4',
                title: 'Binary Tree Level Order Traversal',
                description: 'BFS queue-based traversal',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 7)),
                completedAt: now.subtract(const Duration(days: 5)),
              ),
              Topic(
                id: 'top_dsa_5',
                title: 'Lowest Common Ancestor in BST & BT',
                description: 'Recursive path search and BST property',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 6)),
                completedAt: now.subtract(const Duration(days: 4)),
              ),
              Topic(
                id: 'top_dsa_6',
                title: 'Topological Sort & Cycle Detection',
                description: 'Kahn algorithm and DFS color marking',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 5)),
                completedAt: now.subtract(const Duration(days: 3)),
              ),
              Topic(
                id: 'top_dsa_7',
                title: 'Dijkstra & Shortest Path in Weighted Graphs',
                description: 'Priority queue with adjacency list',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 4)),
                completedAt: now.subtract(const Duration(days: 2)),
              ),
              Topic(
                id: 'top_dsa_8',
                title: 'Number of Islands & Flood Fill',
                description: 'Matrix DFS and BFS flood fill',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 3)),
                completedAt: now.subtract(const Duration(days: 1)),
              ),
            ],
          ),
          Module(
            id: 'mod_dsa_3',
            title: 'Dynamic Programming',
            description: '1D & 2D memoization and tabulation',
            topics: [
              Topic(
                id: 'top_dsa_9',
                title: '0/1 Knapsack & Subset Sum',
                description: 'Core bounded decision DP',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 3)),
                completedAt: now.subtract(const Duration(days: 1)),
              ),
              Topic(
                id: 'top_dsa_10',
                title: 'Longest Common Subsequence (LCS)',
                description: '2D grid transitions and string alignment',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 2)),
                completedAt: now.subtract(const Duration(hours: 14)),
              ),
              Topic(
                id: 'top_dsa_11',
                title: 'Coin Change & Unbounded Knapsack',
                description: 'Minimum coins and combination count',
                status: TopicStatus.inProgress,
                createdAt: now.subtract(const Duration(days: 1)),
              ),
              Topic(
                id: 'top_dsa_12',
                title: 'Edit Distance & String Matching',
                description: 'Insertion, deletion, and replacement matrix',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
            ],
          ),
        ],
      ),

      // 2. Database Management
      Subject(
        id: 'subject_dbms',
        title: 'Database Management',
        subtitle: 'SQL, Normalization, Transactions',
        iconCodePoint: Icons.storage_rounded.codePoint,
        iconFontFamily: Icons.storage_rounded.fontFamily,
        colorValue: 0xFF279D80,
        modules: [
          Module(
            id: 'mod_dbms_1',
            title: 'Relational Model & SQL',
            description: 'Queries, joins, subqueries, and views',
            topics: [
              Topic(
                id: 'top_dbms_1',
                title: 'Complex Joins (INNER, LEFT, FULL, CROSS)',
                description: 'Join strategies and query optimization',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 9)),
                completedAt: now.subtract(const Duration(days: 6)),
              ),
              Topic(
                id: 'top_dbms_2',
                title: 'Window Functions (ROW_NUMBER, RANK, DENSE_RANK)',
                description: 'Analytical partitioning and rolling sums',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 8)),
                completedAt: now.subtract(const Duration(days: 5)),
              ),
              Topic(
                id: 'top_dbms_3',
                title: 'Indexing & B-Tree Structure',
                description: 'Clustered vs Non-clustered indexing',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 7)),
                completedAt: now.subtract(const Duration(days: 4)),
              ),
              Topic(
                id: 'top_dbms_4',
                title: 'Query Optimization & EXPLAIN ANALYZE',
                description: 'Execution plans, scan types, cost model',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
            ],
          ),
          Module(
            id: 'mod_dbms_2',
            title: 'Transactions & Normalization',
            description: 'ACID guarantees, concurrency, and normal forms',
            topics: [
              Topic(
                id: 'top_dbms_5',
                title: 'ACID Properties & Isolation Levels',
                description: 'Read uncommitted, committed, repeatable, serializable',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 6)),
                completedAt: now.subtract(const Duration(days: 3)),
              ),
              Topic(
                id: 'top_dbms_6',
                title: 'Concurrency Control & 2-Phase Locking',
                description: 'Shared locks, exclusive locks, and deadlocks',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 5)),
                completedAt: now.subtract(const Duration(days: 2)),
              ),
              Topic(
                id: 'top_dbms_7',
                title: 'Normalization (1NF, 2NF, 3NF, BCNF)',
                description: 'Functional dependencies and anomaly elimination',
                status: TopicStatus.inProgress,
                createdAt: now.subtract(const Duration(days: 2)),
              ),
              Topic(
                id: 'top_dbms_8',
                title: 'Write-Ahead Logging (WAL) & Crash Recovery',
                description: 'ARIES algorithm and checkpointing',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
            ],
          ),
        ],
      ),

      // 3. Operating Systems
      Subject(
        id: 'subject_os',
        title: 'Operating Systems',
        subtitle: 'Processes, Memory, Scheduling',
        iconCodePoint: Icons.computer_rounded.codePoint,
        iconFontFamily: Icons.computer_rounded.fontFamily,
        colorValue: 0xFFE28C43,
        modules: [
          Module(
            id: 'mod_os_1',
            title: 'Processes & Concurrency',
            description: 'Process state, IPC, and thread synchronization',
            topics: [
              Topic(
                id: 'top_os_1',
                title: 'Process vs Thread & Context Switching',
                description: 'PCB, TCB, CPU registers and kernel overhead',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 7)),
                completedAt: now.subtract(const Duration(days: 4)),
              ),
              Topic(
                id: 'top_os_2',
                title: 'CPU Scheduling Algorithms',
                description: 'Round Robin, SJF, Multilevel Feedback Queues',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 6)),
                completedAt: now.subtract(const Duration(days: 3)),
              ),
              Topic(
                id: 'top_os_3',
                title: 'Deadlock Conditions & Banker Algorithm',
                description: 'Mutual exclusion, hold & wait, no preemption, circular wait',
                status: TopicStatus.inProgress,
                createdAt: now.subtract(const Duration(days: 2)),
              ),
              Topic(
                id: 'top_os_4',
                title: 'Mutexes, Semaphores & Condition Variables',
                description: 'Classic synchronization: Producer-Consumer, Readers-Writers',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
            ],
          ),
          Module(
            id: 'mod_os_2',
            title: 'Memory Management & File Systems',
            description: 'Virtual memory, paging, and inode structures',
            topics: [
              Topic(
                id: 'top_os_5',
                title: 'Virtual Memory & Demand Paging',
                description: 'Page tables, TLB cache, and page fault handling',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
              Topic(
                id: 'top_os_6',
                title: 'Page Replacement Algorithms (LRU, FIFO, Clock)',
                description: 'Belady anomaly and optimal replacement',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
              Topic(
                id: 'top_os_7',
                title: 'File System Architecture & Inodes',
                description: 'Directory entries, hard vs soft links, buffer cache',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
            ],
          ),
        ],
      ),

      // 4. System Design
      Subject(
        id: 'subject_sd',
        title: 'System Design',
        subtitle: 'Scalability, Caching, Microservices',
        iconCodePoint: Icons.hub_rounded.codePoint,
        iconFontFamily: Icons.hub_rounded.fontFamily,
        colorValue: 0xFF514A86,
        modules: [
          Module(
            id: 'mod_sd_1',
            title: 'Foundations of Distributed Systems',
            description: 'CAP theorem, consistent hashing, and load balancing',
            topics: [
              Topic(
                id: 'top_sd_1',
                title: 'Load Balancing & Reverse Proxies',
                description: 'L4 vs L7 load balancing and algorithms',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 5)),
                completedAt: now.subtract(const Duration(days: 2)),
              ),
              Topic(
                id: 'top_sd_2',
                title: 'Consistent Hashing & Virtual Nodes',
                description: 'Distributed caching ring partition',
                status: TopicStatus.completed,
                createdAt: now.subtract(const Duration(days: 4)),
                completedAt: now.subtract(const Duration(days: 1)),
              ),
              Topic(
                id: 'top_sd_3',
                title: 'Caching Strategies (Write-Through, Write-Back)',
                description: 'Redis/Memcached, cache eviction, dogpiling prevention',
                status: TopicStatus.inProgress,
                createdAt: now.subtract(const Duration(days: 1)),
              ),
              Topic(
                id: 'top_sd_4',
                title: 'Message Queues & Event Streaming',
                description: 'Kafka partition model, RabbitMQ routing, idempotency',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
