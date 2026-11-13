import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rahba_digital/domain/age_rules.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color rahbaGreen = Color(0xFF123F2B);
const Color rahbaDeepGreen = Color(0xFF0B2E20);
const Color rahbaGold = Color(0xFFD7B65D);
const Color rahbaCream = Color(0xFFF5F4ED);

const String supabaseUrl = 'https://oxmjqjiqtocmvvchiwbg.supabase.co';
const String supabasePublishableKey =
    'sb_publishable_vaVsUHLqFTA_5ZldtRGK3A_yBKYoZlD';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(const RahbaApp());
}

class RahbaApp extends StatelessWidget {
  const RahbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: rahbaGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: rahbaGreen,
      secondary: rahbaGold,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'أغنامي | منظومة الرحبة الرقمية',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: rahbaCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: rahbaGreen,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE1E4DA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE1E4DA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: rahbaGold, width: 1.7),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE8E6DB)),
          ),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _user;
  late final StreamSubscription<dynamic> _authSubscription;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    _user = client.auth.currentUser;
    _authSubscription = client.auth.onAuthStateChange.listen((state) {
      if (!mounted) return;
      setState(() => _user = state.session?.user);
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return user == null ? const LoginPage() : DashboardPage(user: user);
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _normalizePhone(String value) {
    var phone = value.replaceAll(RegExp(r'[\s()-]'), '');
    if (phone.startsWith('00')) {
      phone = '+${phone.substring(2)}';
    } else if (phone.startsWith('0')) {
      phone = '+218${phone.substring(1)}';
    } else if (phone.startsWith('218')) {
      phone = '+$phone';
    }
    return phone;
  }

  Future<void> _signIn() async {
    final phone = _normalizePhone(_phoneController.text.trim());
    final password = _passwordController.text;
    if (!RegExp(r'^\+218\d{9}$').hasMatch(phone)) {
      setState(() => _error = 'أدخل رقم هاتف ليبي صحيحًا.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'أدخل كلمة المرور.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        phone: phone,
        password: password,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'تعذر تسجيل الدخول: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: rahbaGreen,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: rahbaGold, width: 2),
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          color: rahbaGold,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'منظومة الرحبة الرقمية',
                        style: TextStyle(
                          color: rahbaGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'أغنامي',
                        style: TextStyle(
                          color: rahbaDeepGreen,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'إدارة قطيعك وسجلاته في مكان واحد.',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          hintText: '0912345678',
                          prefixIcon: Icon(Icons.phone_android),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onSubmitted: (_) => _busy ? null : _signIn(),
                        decoration: const InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFB3261E)),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _busy ? null : _signIn,
                        style: FilledButton.styleFrom(
                          backgroundColor: rahbaGreen,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('دخول إلى أغنامي'),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'الدخول للحسابات المنشأة مسبقًا فقط.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({required this.user, super.key});

  final User user;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _sheep = [];
  bool _loading = true;
  String? _loadError;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadSheep();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSheep() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final result = await Supabase.instance.client
          .from('rahba_sheep')
          .select(
            'id,owner_id,animal_code,name,sex,category,breed,birth_date,'
            'weight_kg,health_status,photo_path,notes,created_at',
          )
          .eq('owner_id', widget.user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _sheep = List<Map<String, dynamic>>.from(result);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _visibleSheep {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _sheep;

    return _sheep.where((sheep) {
      final searchable = [
        sheep['animal_code'],
        sheep['name'],
        sheep['breed'],
        sheep['notes'],
        _categoryLabel(sheep['category']?.toString()),
      ].whereType<Object>().join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  int get _activeCount => _sheep.where((sheep) {
        final status = sheep['health_status'];
        return status != 'sold' && status != 'deceased';
      }).length;

  int get _ramCount => _sheep.where((sheep) {
        final status = sheep['health_status'];
        return sheep['category'] == 'ram' &&
            status != 'sold' &&
            status != 'deceased';
      }).length;

  bool get _needsAttention => _sheep.any((sheep) {
        return const ['sick', 'treated', 'monitor']
            .contains(sheep['health_status']);
      });

  Future<void> _addSheep() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSheepSheet(ownerId: widget.user.id),
    );

    if (added == true && mounted) {
      await _loadSheep();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الرأس في سجل أغنامك.')),
      );
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  void _showDetails(Map<String, dynamic> sheep) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        final birthDate = DateTime.tryParse(
          sheep['birth_date']?.toString() ?? '',
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                sheep['name']?.toString().isNotEmpty == true
                    ? sheep['name'].toString()
                    : 'رأس دون اسم',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: rahbaGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text('المعرّف: ${sheep['animal_code'] ?? '—'}'),
              Text('التصنيف: ${_categoryLabel(sheep['category']?.toString())}'),
              Text('الجنس: ${_sexLabel(sheep['sex']?.toString())}'),
              Text('العمر: ${_ageLabel(birthDate)}'),
              Text('الوزن: ${sheep['weight_kg'] ?? '—'} كغ'),
              Text('السلالة: ${sheep['breed'] ?? '—'}'),
              Text('الحالة الصحية: ${_healthLabel(sheep['health_status']?.toString())}'),
              if ((sheep['notes'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('ملاحظات: ${sheep['notes']}'),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أغنامي',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث السجل',
            onPressed: _loadSheep,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSheep,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'إجمالي الأغنام',
                    value: _activeCount.toString(),
                    icon: Icons.pets_rounded,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _StatCard(
                    label: 'الفحول',
                    value: _ramCount.toString(),
                    icon: Icons.shield_moon_outlined,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _StatCard(
                    label: 'حالة القطيع',
                    value: _sheep.isEmpty
                        ? '—'
                        : (_needsAttention ? 'متابعة' : 'جيدة'),
                    icon: Icons.health_and_safety_outlined,
                    compact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _addSheep,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('إضافة رأس جديد'),
              style: FilledButton.styleFrom(
                backgroundColor: rahbaGold,
                foregroundColor: rahbaDeepGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'بحث في أغنامي بالاسم أو الرقم أو السلالة',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'سجل أغنامي',
                    style: TextStyle(
                      color: rahbaDeepGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${_visibleSheep.length} رأس',
                  style: const TextStyle(
                    color: rahbaGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(
                  child: CircularProgressIndicator(color: rahbaGreen),
                ),
              )
            else if (_loadError != null)
              _ErrorPanel(message: _loadError!, onRetry: _loadSheep)
            else if (_visibleSheep.isEmpty)
              _EmptyPanel(
                searching: _query.isNotEmpty,
                onAdd: _addSheep,
              )
            else
              ..._visibleSheep.map(
                (sheep) => _SheepTile(
                  sheep: sheep,
                  onTap: () => _showDetails(sheep),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [rahbaGreen, rahbaDeepGreen],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: rahbaGold, width: 1.2),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة قطيعك بثقة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'كل رأس وسجلاته في مكان واحد',
                  style: TextStyle(color: Color(0xFFE8E3D1)),
                ),
              ],
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: rahbaGold,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8E6DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: rahbaGold, size: 21),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: rahbaGreen,
              fontSize: compact ? 17 : 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheepTile extends StatelessWidget {
  const _SheepTile({required this.sheep, required this.onTap});

  final Map<String, dynamic> sheep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final birthDate = DateTime.tryParse(
      sheep['birth_date']?.toString() ?? '',
    );
    final subtitle = [
      _categoryLabel(sheep['category']?.toString()),
      _sexLabel(sheep['sex']?.toString()),
      _ageLabel(birthDate),
      if (sheep['weight_kg'] != null) '${sheep['weight_kg']} كغ',
      _healthLabel(sheep['health_status']?.toString()),
    ].join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFECE8D9),
          child: const Icon(Icons.pets_rounded, color: rahbaGreen),
        ),
        title: Text(
          sheep['name']?.toString().isNotEmpty == true
              ? sheep['name'].toString()
              : 'رأس دون اسم',
          style: const TextStyle(
            color: rahbaDeepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          '${sheep['animal_code'] ?? 'دون رقم'}\n$subtitle',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(height: 1.5, fontSize: 12),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_left, color: rahbaGold),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.searching, required this.onAdd});

  final bool searching;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.pets_outlined, size: 42, color: rahbaGold),
            const SizedBox(height: 10),
            Text(
              searching
                  ? 'لا توجد نتائج مطابقة للبحث.'
                  : 'لا توجد رؤوس مسجلة بعد.',
              style: const TextStyle(
                color: rahbaGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!searching) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('إضافة أول رأس'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, color: Colors.redAccent),
            const SizedBox(height: 8),
            const Text(
              'تعذر الاتصال بسجل أغنامك.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddSheepSheet extends StatefulWidget {
  const AddSheepSheet({required this.ownerId, super.key});

  final String ownerId;

  @override
  State<AddSheepSheet> createState() => _AddSheepSheetState();
}

class _AddSheepSheetState extends State<AddSheepSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  String _sex = 'female';
  String _category = 'lamb';
  DateTime? _birthDate;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'اختر تاريخ الميلاد',
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate = DateTime(picked.year, picked.month, picked.day);
        _error = null;
      });
    }
  }

  void _onCategoryChanged(String? value) {
    if (value == null) return;
    setState(() {
      _category = value;
      if (value == 'ram' || value == 'ram_lamb') _sex = 'male';
      if (value == 'ewe' || value == 'ewe_lamb') _sex = 'female';
      _error = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if ((_category == 'ram' || _category == 'ewe') &&
        !canBeBreedingAdult(_birthDate, DateTime.now())) {
      setState(() {
        _error =
            'ممنوع اعتماد الرأس فحلًا أو نعجة قبل إكمال 13 شهرًا. '
            'يلزم إدخال تاريخ ميلاد صحيح والتأكد من بلوغ السن.';
      });
      return;
    }

    if ((_category == 'ram' || _category == 'ram_lamb') && _sex != 'male') {
      setState(() => _error = 'هذا التصنيف يتطلب اختيار ذكر.');
      return;
    }
    if ((_category == 'ewe' || _category == 'ewe_lamb') &&
        _sex != 'female') {
      setState(() => _error = 'هذا التصنيف يتطلب اختيار أنثى.');
      return;
    }

    final weightText = _weightController.text.trim();
    final weight = weightText.isEmpty ? null : double.tryParse(weightText);
    if (weightText.isNotEmpty && (weight == null || weight <= 0)) {
      setState(() => _error = 'أدخل وزنًا صحيحًا أكبر من صفر.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final payload = <String, dynamic>{
      'owner_id': widget.ownerId,
      'animal_code': _codeController.text.trim(),
      'name': _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      'sex': _sex,
      'category': _category,
      'breed': _breedController.text.trim().isEmpty
          ? null
          : _breedController.text.trim(),
      'birth_date': _birthDate?.toIso8601String().split('T').first,
      'weight_kg': weight,
      'health_status': 'good',
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    };

    try {
      await Supabase.instance.client.from('rahba_sheep').insert(payload);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'تعذر حفظ الرأس: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: rahbaCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 18, 18, 22 + bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إضافة رأس جديد',
                style: TextStyle(
                  color: rahbaGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'أدخل البيانات الأساسية، ويمكن استكمال السجل لاحقًا.',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'رقم أو معرّف الرأس *',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'رقم الرأس مطلوب.'
                        : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الرأس'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _sex,
                decoration: const InputDecoration(labelText: 'الجنس'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('ذكر')),
                  DropdownMenuItem(value: 'female', child: Text('أنثى')),
                ],
                onChanged: (value) => setState(() {
                  _sex = value ?? _sex;
                  _error = null;
                }),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'التصنيف'),
                items: const [
                  DropdownMenuItem(value: 'lamb', child: Text('مولود')),
                  DropdownMenuItem(
                    value: 'ewe_lamb',
                    child: Text('حايل فطيمة'),
                  ),
                  DropdownMenuItem(value: 'ram_lamb', child: Text('حولي')),
                  DropdownMenuItem(value: 'ewe', child: Text('نعجة')),
                  DropdownMenuItem(value: 'ram', child: Text('فحل')),
                  DropdownMenuItem(value: 'other', child: Text('أخرى')),
                ],
                onChanged: _onCategoryChanged,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickBirthDate,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  _birthDate == null
                      ? 'تاريخ الميلاد'
                      : 'الميلاد: ${_birthDate!.year}-'
                          '${_birthDate!.month.toString().padLeft(2, '0')}-'
                          '${_birthDate!.day.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'الوزن بالكيلو'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'السلالة'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFB3261E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: rahbaGreen,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('حفظ الرأس'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(String? value) {
  return switch (value) {
    'ram' => 'فحل',
    'ewe' => 'نعجة',
    'ram_lamb' => 'حولي',
    'ewe_lamb' => 'حايل فطيمة',
    'lamb' => 'مولود',
    'other' => 'أخرى',
    _ => 'غير محدد',
  };
}

String _sexLabel(String? value) => value == 'male' ? 'ذكر' : 'أنثى';

String _healthLabel(String? value) {
  return switch (value) {
    'good' => 'جيدة',
    'monitor' => 'تحت المراقبة',
    'sick' => 'مريضة',
    'treated' => 'تحت العلاج',
    'deceased' => 'نافقة',
    'sold' => 'مباعة',
    _ => 'غير محددة',
  };
}

String _ageLabel(DateTime? birthDate) {
  if (birthDate == null) return 'العمر غير مسجل';
  final months = ageInMonths(birthDate, DateTime.now());
  if (months < 0) return 'تاريخ ميلاد غير صحيح';
  if (months < 12) return '$months شهر';
  final years = months ~/ 12;
  final remainingMonths = months % 12;
  if (remainingMonths == 0) return '$years سنة';
  return '$years سنة و$remainingMonths شهر';
}
