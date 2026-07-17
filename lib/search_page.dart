import 'package:flutter/material.dart';
import 'api.dart';
import 'history_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _hnController = TextEditingController();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  
  List<dynamic> _searchResults = [];
  bool _isSearchByHn = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _search() async {
    setState(() {
      _isLoading = true;
      _searchResults = [];
      _errorMessage = null;
    });

    try {
      if (_isSearchByHn) {
        if (_hnController.text.isEmpty) {
           setState(() => _isLoading = false);
           return;
        }
        final data = await _apiService.fetchPatientData(_hnController.text);
        if (data != null) {
          _searchResults = [data];
        } else {
          _errorMessage = "ไม่พบข้อมูลคนไข้หมายเลข ${_hnController.text}";
        }
      } else {
        if (_fnameController.text.isEmpty && _lnameController.text.isEmpty) {
           setState(() => _isLoading = false);
           return;
        }
        final data = await _apiService.searchPatientsByName(
          _fnameController.text, 
          _lnameController.text
        );
        if (data.isNotEmpty) {
          _searchResults = data;
        } else {
          _errorMessage = "ไม่พบข้อมูลคนไข้ที่ระบุ";
        }
      }
    } catch (e) {
      _errorMessage = "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Patient Search', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Toggle Search Mode
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton(true, 'ค้นหาด้วย HN'),
                      _buildToggleButton(false, 'ค้นหาด้วย ชื่อ-นามสกุล'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Search Input
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_isSearchByHn)
                        TextField(
                          controller: _hnController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'กรอกหมายเลข HN',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _search(),
                        )
                      else
                        Column(
                          children: [
                            TextField(
                              controller: _fnameController,
                              decoration: const InputDecoration(
                                hintText: 'ชื่อ',
                                prefixIcon: Icon(Icons.person_outline),
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(),
                            TextField(
                              controller: _lnameController,
                              decoration: const InputDecoration(
                                hintText: 'นามสกุล',
                                prefixIcon: Icon(Icons.person_outline),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _search,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('ค้นหาเดี๋ยวนี้'),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                ? _buildErrorState()
                : _searchResults.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) => _buildPatientCard(_searchResults[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(bool value, String label) {
    final isSelected = _isSearchByHn == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isSearchByHn = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                radius: 25,
                child: Icon(Icons.person, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${data['firstname']} ${data['lastname']}', 
                         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('HN: ${data['hn']}', style: TextStyle(color: Colors.blue[700])),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          _buildInfoRow(Icons.phone_android, 'เบอร์โทร', data['phone'] ?? '-'),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage(patient: data)),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('ดูประวัติการรักษา'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('กรุณากรอกข้อมูลเพื่อค้นหา', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.orange[200]),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
