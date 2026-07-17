import 'package:flutter/material.dart';
import 'api.dart';

class HistoryPage extends StatefulWidget {
  final Map<String, dynamic> patient;
  const HistoryPage({super.key, required this.patient});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _apiService.fetchPatientHistory(widget.patient['hn'].toString());
    setState(() {
      _history = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ประวัติการรักษา', style: TextStyle(fontSize: 18)),
            Text(
              '${widget.patient['firstname']} ${widget.patient['lastname']} (HN: ${widget.patient['hn']})',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_edu, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('ไม่พบประวัติการรักษา', style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.event_note, color: Colors.blue),
                        ),
                        title: Text(
                          item['date'] ?? 'ไม่ระบุวันที่',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('วินิจฉัย: ${item['diagnosis'] ?? '-'}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailItem('อาการสำคัญ', item['symptoms'] ?? '-'),
                                _buildDetailItem('แผนการรักษา', item['treatment_plan'] ?? '-'),
                                _buildDetailItem('ยาที่ได้รับ', item['medication'] ?? '-'),
                                _buildDetailItem('แพทย์ผู้ตรวจ', item['doctor_name'] ?? '-'),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
