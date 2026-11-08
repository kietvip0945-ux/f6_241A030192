import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F6_241A030192',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0468D7)),
      ),
      home: const HomeShell(),
    );
  }
}

// ===================================================================
// MODEL
// ===================================================================
class CongViec {
  /// id duy nhất, ổn định — dùng làm key cho Dismissible (NC2).
  final int id;
  final String tieuDe;
  final bool xong;

  const CongViec(this.id, this.tieuDe, {this.xong = false});

  CongViec copyWith({String? tieuDe, bool? xong}) =>
      CongViec(id, tieuDe ?? this.tieuDe, xong: xong ?? this.xong);
}

// ===================================================================
// KHUNG ỨNG DỤNG: Scaffold + Drawer + NavigationBar
// ===================================================================
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  bool _hienDaXong = true;
  int _idTiepTheo = 100;

  final List<CongViec> _ds = [
    const CongViec(1, 'Nộp bài Lab A11'),
    const CongViec(2, 'Ôn tập SQLite', xong: true),
    const CongViec(3, 'Họp nhóm đồ án'),
    const CongViec(4, 'Đọc tài liệu Flutter', xong: true),
    const CongViec(5, 'Quay video demo Lab F6'),
    const CongViec(6, 'Viết báo cáo Lab F6'),
    const CongViec(7, 'Chuẩn bị Lab F7 (sqflite)'),
    const CongViec(8, 'Ôn tập giữa kỳ', xong: true),
    const CongViec(9, 'Làm bài tập Cấu trúc dữ liệu'),
    const CongViec(10, 'Đăng ký học phần'),
    const CongViec(11, 'Cập nhật repo GitHub'),
    const CongViec(12, 'Đọc chương 5 giáo trình'),
    const CongViec(13, 'Gửi email cho giảng viên'),
  ];

  /// Dữ liệu hiển thị — lọc từ dữ liệu gốc `_ds`, không làm mất dữ liệu.
  List<CongViec> get _hienThi =>
      _hienDaXong ? _ds : _ds.where((c) => !c.xong).toList();

  static const _tieuDeTab = ['Công việc', 'Thống kê', 'Cài đặt'];

  // ---------------- Thao tác dữ liệu ----------------
  void _doiTrangThai(CongViec cv) {
    final i = _ds.indexWhere((c) => c.id == cv.id);
    if (i < 0) return; // phần tử đã bị xóa khỏi danh sách
    setState(() => _ds[i] = _ds[i].copyWith(xong: !_ds[i].xong));
  }

  /// Xóa kèm SnackBar có nút Hoàn tác.
  void _xoa(CongViec cv) {
    final i = _ds.indexWhere((c) => c.id == cv.id);
    if (i < 0) return;
    final daXoa = _ds[i];
    setState(() => _ds.removeAt(i));

    // Gỡ SnackBar đang hiện trước khi hiện cái mới, tránh xếp hàng chồng chất
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${daXoa.tieuDe}"'),
          action: SnackBarAction(
            label: 'HOÀN TÁC',
            onPressed: () {
              if (!mounted || _ds.any((c) => c.id == daXoa.id)) return;
              // clamp: nếu danh sách đã ngắn đi trong lúc SnackBar còn hiện
              // (ví dụ "Xóa các việc đã xong") thì không bị RangeError.
              setState(() => _ds.insert(i.clamp(0, _ds.length), daXoa));
            },
          ),
        ),
      );
  }

  // ---------------- Hộp thoại ----------------
  /// AlertDialog xác nhận. Trả về true nếu người dùng đồng ý.
  Future<bool> _xacNhanXoa(CongViec cv) async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${cv.tieuDe}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    // showDialog trả về null khi người dùng chạm ra ngoài để đóng
    return dongY ?? false;
  }

  /// Hộp thoại nhập liệu — trả về chuỗi người dùng gõ, hoặc null nếu hủy.
  Future<void> _themCongViec() async {
    final tieuDe = await showDialog<String>(
      context: context,
      builder: (context) => const ThemCongViecDialog(),
    );
    if (tieuDe == null || !mounted) return;
    setState(() => _ds.insert(0, CongViec(_idTiepTheo++, tieuDe)));
  }

  /// BottomSheet — bảng trượt lên từ cạnh dưới, hợp cho danh sách hành động.
  void _moBangHanhDong(CongViec cv) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(cv.tieuDe,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(cv.xong ? Icons.undo : Icons.check),
              title: Text(cv.xong ? 'Đánh dấu chưa xong' : 'Đánh dấu đã xong'),
              onTap: () {
                Navigator.pop(sheetContext);
                _doiTrangThai(cv);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(sheetContext);
                final dongY = await _xacNhanXoa(cv);
                if (dongY && mounted) _xoa(cv);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Giao diện ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tieuDeTab[_tab]),
        // Có Drawer thì AppBar tự thêm nút ba gạch bên trái
        actions: [
          // PopupMenuButton = menu ba chấm, tương đương options menu của Android
          PopupMenuButton<String>(
            onSelected: (chon) {
              if (chon == 'loc') {
                setState(() => _hienDaXong = !_hienDaXong);
              } else if (chon == 'xoa_xong') {
                setState(() => _ds.removeWhere((c) => c.xong));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Đã xóa các việc đã xong')),
                  );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'loc',
                child: Text(_hienDaXong ? 'Ẩn việc đã xong' : 'Hiện việc đã xong'),
              ),
              const PopupMenuItem(
                value: 'xoa_xong',
                child: Text('Xóa các việc đã xong'),
              ),
            ],
          ),
        ],
      ),
      // Drawer: ngăn kéo trượt từ cạnh trái
      drawer: NavigationDrawer(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          setState(() => _tab = i);
          Navigator.pop(context); // đóng ngăn kéo sau khi chọn
        },
        children: const [
          UserAccountsDrawerHeader(
            accountName: Text('Lê Hoàng Anh Kiệt'),
            accountEmail: Text('241A030192@vhu.edu.vn'),
            currentAccountPicture: CircleAvatar(child: Text('K')),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.checklist),
            label: Text('Công việc'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.bar_chart),
            label: Text('Thống kê'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.settings),
            label: Text('Cài đặt'),
          ),
        ],
      ),
      // NC1: IndexedStack giữ nguyên trạng thái (vị trí cuộn) của từng tab
      body: IndexedStack(
        index: _tab,
        children: [
          _tabCongViec(),
          _tabThongKe(),
          _tabCaiDat(),
        ],
      ),
      // NavigationBar: thanh điều hướng dưới (Material 3), thay cho BottomNavigationBar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Việc'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              tooltip: 'Thêm công việc',
              onPressed: _themCongViec,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _tabCongViec() {
    final ds = _hienThi;
    if (ds.isEmpty) {
      return const Center(child: Text('Không có công việc nào'));
    }
    return ListView.builder(
      key: const PageStorageKey('ds_cong_viec'),
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: ds.length,
      itemBuilder: (context, i) {
        final cv = ds[i];
        // NC2: vuốt sang trái để xóa, vẫn có Hoàn tác
        return Dismissible(
          key: ValueKey(cv.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _xoa(cv),
          child: ListTile(
            leading: Checkbox(
              value: cv.xong,
              onChanged: (_) => _doiTrangThai(cv),
            ),
            title: Text(
              cv.tieuDe,
              style: TextStyle(
                decoration: cv.xong ? TextDecoration.lineThrough : null,
                color: cv.xong ? Colors.grey : null,
              ),
            ),
            trailing: const Icon(Icons.more_vert),
            onTap: () => _moBangHanhDong(cv),
            onLongPress: () async {
              final dongY = await _xacNhanXoa(cv);
              if (dongY && mounted) _xoa(cv);
            },
          ),
        );
      },
    );
  }

  Widget _tabThongKe() {
    final xong = _ds.where((c) => c.xong).length;
    final tong = _ds.length;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$xong / $tong', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text('công việc đã hoàn thành'),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: LinearProgressIndicator(
              value: tong == 0 ? 0 : xong / tong,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabCaiDat() {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Hiện cả việc đã xong'),
          value: _hienDaXong,
          onChanged: (v) => setState(() => _hienDaXong = v),
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text('Xóa toàn bộ danh sách'),
          onTap: () async {
            final dongY = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xóa tất cả?'),
                content: Text('Toàn bộ ${_ds.length} công việc sẽ bị xóa.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Hủy'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Xóa hết'),
                  ),
                ],
              ),
            );
            if (dongY == true && mounted) {
              setState(() => _ds.clear());
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Đã xóa toàn bộ')),
                );
            }
          },
        ),
        const AboutListTile(
          icon: Icon(Icons.info_outline),
          applicationName: 'Lab F6',
          applicationVersion: '1.0',
          applicationLegalese: 'Lê Hoàng Anh Kiệt - 241A030192',
          child: Text('Giới thiệu'),
        ),
      ],
    );
  }
}

// ===================================================================
// HỘP THOẠI NHẬP LIỆU — tự quản lý controller trong vòng đời của nó
// ===================================================================
class ThemCongViecDialog extends StatefulWidget {
  const ThemCongViecDialog({super.key});

  @override
  State<ThemCongViecDialog> createState() => _ThemCongViecDialogState();
}

class _ThemCongViecDialogState extends State<ThemCongViecDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // dispose khi hộp thoại đã thật sự rời khỏi cây widget (sau hiệu ứng đóng)
    _controller.dispose();
    super.dispose();
  }

  void _xacNhan() {
    // Chỉ đóng hộp thoại khi dữ liệu hợp lệ
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm công việc'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _xacNhan(),
          decoration: const InputDecoration(
            labelText: 'Tên công việc',
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Không được để trống' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _xacNhan,
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
