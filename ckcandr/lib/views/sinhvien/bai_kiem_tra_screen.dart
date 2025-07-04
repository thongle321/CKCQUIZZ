import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'dart:async';

class BaiKiemTraScreen extends ConsumerStatefulWidget {
  const BaiKiemTraScreen({super.key});
  
  @override
  ConsumerState<BaiKiemTraScreen> createState() => _BaiKiemTraScreenState();
}

class _BaiKiemTraScreenState extends ConsumerState<BaiKiemTraScreen> {
  // Biến đếm thời gian làm bài
  Duration timeRemaining = const Duration(hours: 0, minutes: 0, seconds: 0);
  Timer? _timer;
  
  // Danh sách câu hỏi và đáp án mẫu
  final List<QuizQuestion> questions = [
    QuizQuestion(
      id: 1,
      question: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
      options: [
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
      ],
      selectedOption: null,
    ),
    QuizQuestion(
      id: 2,
      question: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
      options: [
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ullamcorper.',
      ],
      selectedOption: null,
    ),
    QuizQuestion(
      id: 3,
      question: 'Thuật ngữ "OOP" trong lập trình đề cập đến?',
      options: [
        'Object Oriented Programming - Lập trình hướng đối tượng',
        'Order Of Precedence - Thứ tự ưu tiên',
        'Output Oriented Procedures - Thủ tục định hướng đầu ra',
        'Operator Overloading Protocol - Giao thức nạp chồng toán tử',
      ],
      selectedOption: null,
    ),
    QuizQuestion(
      id: 4,
      question: 'Trong Flutter, Widget nào được sử dụng để tạo danh sách có thể cuộn?',
      options: [
        'Container',
        'ListView',
        'Row',
        'Column',
      ],
      selectedOption: null,
    ),
    QuizQuestion(
      id: 5,
      question: 'Mô hình MVC trong phát triển phần mềm viết tắt của?',
      options: [
        'Model-View-Component',
        'Model-View-Controller',
        'Modern-View-Component',
        'Multiple-View-Controller',
      ],
      selectedOption: null,
    ),
    QuizQuestion(
      id: 6,
      question: 'Ngôn ngữ lập trình nào được sử dụng trong Flutter?',
      options: [
        'JavaScript',
        'Java',
        'Kotlin',
        'Dart',
      ],
      selectedOption: null,
    ),
    QuizQuestion(
      id: 7,
      question: 'Trong lập trình hướng đối tượng, tính chất nào cho phép một lớp kế thừa thuộc tính và phương thức từ lớp khác?',
      options: [
        'Encapsulation - Tính đóng gói',
        'Inheritance - Tính kế thừa',
        'Polymorphism - Tính đa hình',
        'Abstraction - Tính trừu tượng',
      ],
      selectedOption: null,
    ),
  ];
  
  // Câu hỏi hiện tại
  int currentQuestionIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  // Hàm bắt đầu đồng hồ đếm ngược
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemaining = timeRemaining + const Duration(seconds: 1);
      });
    });
  }
  
  // Format thời gian thành chuỗi hh:mm:ss
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
  
  // Xử lý khi nộp bài
  void _handleSubmit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: const Text('Bạn có chắc chắn muốn nộp bài?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Xử lý logic nộp bài
              context.go('/sinhvien/danh-muc-bai-kiem-tra');
            },
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
  }
  
  // Xử lý khi thoát bài thi
  void _handleExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thoát'),
        content: const Text('Bạn có chắc chắn muốn thoát khỏi bài thi? Dữ liệu bài làm sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context.go('/sinhvien/danh-muc-bai-kiem-tra');
            },
            child: const Text('Thoát', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem đang ở màn hình mobile hay desktop
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header của bài kiểm tra
            _buildHeader(),
            
            // Nội dung bài kiểm tra
            Expanded(
              child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget header
  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      constraints: BoxConstraints(
        minHeight: isSmallScreen ? 60 : 48,
        maxHeight: isSmallScreen ? 80 : 48,
      ),
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
      color: Colors.grey.shade200,
      child: isSmallScreen ? _buildMobileHeader() : _buildDesktopHeader(),
    );
  }

  // Header cho mobile
  Widget _buildMobileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hàng đầu: Thoát và Nộp bài
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: _handleExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: const Size(50, 24),
                  ),
                  child: const Text('THOÁT',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),

              // Thời gian
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      _formatTime(timeRemaining),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    minimumSize: const Size(50, 24),
                  ),
                  child: const Text('NỘP BÀI',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Hàng thứ hai: Tên thí sinh
          Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProvider);
              return Flexible(
                child: Text(
                  currentUser?.hoVaTen.toUpperCase() ?? 'THÍ SINH',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Header cho desktop
  Widget _buildDesktopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút thoát
        ElevatedButton(
          onPressed: _handleExit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            minimumSize: const Size(80, 32),
          ),
          child: const Text('THOÁT',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),

        // Tên thí sinh
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProvider);
              return Text(
                currentUser?.hoVaTen.toUpperCase() ?? 'THÍ SINH',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ),

        // Thời gian và nút nộp bài
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 16),
            const SizedBox(width: 4),
            Text(
              _formatTime(timeRemaining),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                minimumSize: const Size(80, 32),
              ),
              child: const Text('NỘP BÀI',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
  
  // Layout cho desktop
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Phần câu hỏi - chiếm 70% màn hình
        Expanded(
          flex: 7,
          child: _buildQuestionSection(),
        ),
        
        // Phần bảng số câu - chiếm 30% màn hình
        Expanded(
          flex: 3,
          child: _buildQuestionNavigator(),
        ),
      ],
    );
  }
  
  // Layout cho mobile
  Widget _buildMobileLayout() {
    return _buildQuestionSection();
  }
  
  // Widget hiển thị câu hỏi và đáp án
  Widget _buildQuestionSection() {
    final QuizQuestion question = questions[currentQuestionIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Số câu hỏi và nội dung
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${question.id}. ${question.question}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Đáp án A
                _buildQuestionOption('A', question.options[0]),
                const SizedBox(height: 12),

                // Đáp án B
                _buildQuestionOption('B', question.options[1]),
                const SizedBox(height: 12),

                // Đáp án C
                _buildQuestionOption('C', question.options[2]),
                const SizedBox(height: 12),

                // Đáp án D
                _buildQuestionOption('D', question.options[3]),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Phần chọn đáp án
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đáp án chọn:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Các nút chọn đáp án A, B, C, D
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: ['A', 'B', 'C', 'D'].map((option) => _buildAnswerOption(option, question)).toList(),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Nút điều hướng câu hỏi (chỉ hiển thị trên mobile)
          MediaQuery.of(context).size.width <= 800
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: currentQuestionIndex > 0
                              ? () => setState(() => currentQuestionIndex--)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Câu trước'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: currentQuestionIndex < questions.length - 1
                              ? () => setState(() => currentQuestionIndex++)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Câu sau'),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
  
  // Widget hiển thị đáp án
  Widget _buildQuestionOption(String label, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label. ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(content)),
      ],
    );
  }
  
  // Widget để chọn đáp án A, B, C, D
  Widget _buildAnswerOption(String option, QuizQuestion question) {
    final bool isSelected = question.selectedOption == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          question.selectedOption = option;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.grey.shade500 : Colors.grey.shade300,
        ),
        alignment: Alignment.center,
        child: Text(
          option,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  // Widget bảng chọn câu (1-20)
  Widget _buildQuestionNavigator() {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tạo lưới các số câu hỏi từ 1-20
          Expanded(
            flex: 3,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.2,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final questionNumber = index + 1;
                final isCurrentQuestion = questionNumber == currentQuestionIndex + 1;
                final hasAnswer = questions[index].selectedOption != null;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentQuestionIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentQuestion ? Colors.grey.shade300 : Colors.white,
                      border: Border.all(
                        color: hasAnswer ? Colors.green : Colors.grey.shade400,
                        width: hasAnswer ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      questionNumber.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrentQuestion || hasAnswer
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: hasAnswer ? Colors.green : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Chú thích - Compact version
          Flexible(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chú thích:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.green, 'Đã trả lời'),
                  const SizedBox(height: 2),
                  _buildLegendItem(Colors.grey.shade300, 'Câu hiện tại'),
                  const SizedBox(height: 2),
                  _buildLegendItem(Colors.white, 'Chưa trả lời'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget cho legend items
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color == Colors.white ? Colors.white : color,
            border: Border.all(
              color: color == Colors.white ? Colors.grey.shade400 : color,
              width: color == Colors.green ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Class đại diện cho một câu hỏi trắc nghiệm
class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  String? selectedOption; // A, B, C, D hoặc null nếu chưa chọn
  
  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.selectedOption,
  });
} 