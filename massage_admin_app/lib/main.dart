import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart'; // Add this
import 'package:device_info_plus/device_info_plus.dart'; // Add this

// Conditional import: Use the stub for mobile, but swap to the web helper at runtime on Chrome
import 'web_download_stub.dart'
    if (dart.library.html) 'web_download_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ENABLE OFFLINE CACHE
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MassageAdminApp());
}

class MassageAdminApp extends StatelessWidget {
  const MassageAdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          primary: Colors.black,
        ),
      ),
      home: const AdminHomeScreen(),
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String businessName = "Luxury Admin";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('site_content')
          .doc('landing_page')
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // Log connection source for debugging
        if (snapshot.hasData && snapshot.data != null) {
          final isFromCache = snapshot.data!.metadata.isFromCache;
          debugPrint(
            "📥 [HOME] Branding Source: ${isFromCache ? 'LOCAL CACHE' : 'SERVER'}",
          );

          var data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data['site'] != null) {
            businessName = data['site']['name'] ?? "Luxury Admin";
          }
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(businessName),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.pending_actions), text: "Requests"),
                  Tab(icon: Icon(Icons.check_circle_outline), text: "Approved"),
                  Tab(icon: Icon(Icons.settings), text: "Settings"),
                ],
              ),
            ),
            body: const TabBarView(
              // Using "const" here helps prevent unnecessary rebuilds during tab switches
              children: [
                RequestsTab(statusFilter: 'new'),
                ApprovedTab(),
                SettingsTab(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- TAB 1: NEW REQUESTS ---
class RequestsTab extends StatelessWidget {
  final String statusFilter;
  const RequestsTab({super.key, required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('scheduledDateTime', descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final isFromCache = snapshot.data!.metadata.isFromCache;
          debugPrint(
            "📥 [REQUESTS] Source: ${isFromCache ? 'LOCAL CACHE' : 'SERVER'}",
          );

          final docs = snapshot.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['status'] == 'new';
          }).toList();

          if (docs.isEmpty)
            return const Center(child: Text("No new requests."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(data['customerName'] ?? "New Request"),
                  subtitle: Text(
                    "Service: ${data['service']}\nDate: ${data['date']}",
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _showBookingDetails(context, docs[index]),
                ),
              );
            },
          );
        }

        if (snapshot.hasError) {
          debugPrint("❌ [REQUESTS ERROR]: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Helper for background sync updates
  Future<void> _bgUpdate(
    DocumentReference ref,
    Map<String, dynamic> data,
  ) async {
    final start = DateTime.now();
    debugPrint("🚀 [SYNC] Starting background update...");
    ref
        .update(data)
        .then((_) {
          final ms = DateTime.now().difference(start).inMilliseconds;
          debugPrint("✅ [SYNC] Completed in ${ms}ms");
        })
        .catchError((e) => debugPrint("⚠️ [SYNC] Pending internet: $e"));
  }

  void _showBookingDetails(BuildContext context, DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const Text(
              "Booking Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: data.entries
                    .map(
                      (e) => ListTile(
                        title: Text(
                          e.key.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                        subtitle: Text(e.value.toString()),
                      ),
                    )
                    .toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _reschedule(context, doc),
                  child: const Text("Reschedule"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _approve(context, doc),
                  child: const Text("Approve"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reschedule(BuildContext context, DocumentSnapshot doc) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate == null) return;
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final noteC = TextEditingController();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reschedule"),
        content: TextField(
          controller: noteC,
          decoration: const InputDecoration(labelText: "Note to Customer"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _bgUpdate(doc.reference, {
                'date': DateFormat('yyyy-MM-dd').format(pickedDate),
                'time': pickedTime.format(context),
                'status': 'rescheduled',
                'reschedule_note': noteC.text,
              });
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void _approve(BuildContext context, DocumentSnapshot doc) {
    final locC = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Approve Booking"),
        content: TextField(
          controller: locC,
          decoration: const InputDecoration(labelText: "Service Location"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _bgUpdate(doc.reference, {
                'status': 'approved',
                'location': locC.text,
              });
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}

// --- TAB 2: APPROVED REQUESTS + CSV DOWNLOAD ---
class ApprovedTab extends StatelessWidget {
  const ApprovedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'approved')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint(
            "📥 [APPROVED] Source: ${snapshot.data!.metadata.isFromCache ? 'LOCAL CACHE' : 'SERVER'}",
          );

          final docs = snapshot.data!.docs;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Download CSV"),
                  onPressed: docs.isEmpty
                      ? null
                      : () => _downloadCSV(docs, context),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.green.shade50,
                      child: ListTile(
                        title: Text(
                          data['service'] ?? "Service",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Client: ${data['customerName']}\nDate: ${data['date']} at ${data['time']}",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          debugPrint("❌ [APPROVED ERROR]: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> _downloadCSV(
    List<QueryDocumentSnapshot> docs,
    BuildContext context,
  ) async {
    List<List<dynamic>> rows = [];
    rows.add([
      "Customer",
      "Service",
      "Date",
      "Time",
      "Email",
      "Phone",
      "Status",
    ]);

    for (var doc in docs) {
      var d = doc.data() as Map<String, dynamic>;
      rows.add([
        d['customerName'],
        d['service'],
        d['date'],
        d['time'],
        d['customerEmail'],
        d['customerPhone'],
        d['status'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    String fileName =
        "approved_bookings_${DateTime.now().millisecondsSinceEpoch}.csv";

    if (kIsWeb) {
      // Logic handled via helper file to avoid dart:html compilation error on Android
      downloadWebFile(csvData, fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CSV downloading in browser...")),
      );
    } else {
      // ANDROID DOWNLOADS FOLDER LOGIC
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        // Android 13+ uses different permissions, but for simple file writing
        // to Downloads, we usually just need to check the directory.
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        // Standard path for Android Downloads
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback if the path is weird
          final fallback = await getExternalStorageDirectory();
          final file = File("${fallback!.path}/$fileName");
          await file.writeAsString(csvData);
        } else {
          final file = File("${directory.path}/$fileName");
          await file.writeAsString(csvData);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Saved to Downloads: $fileName")),
          );
        }
      }
    }
  }
}

// --- TAB 3: SETTINGS ---
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  Future<void> _updateField(String fieldPath, dynamic value) async {
    final start = DateTime.now();
    debugPrint("🚀 [LOCAL WRITE] Updating $fieldPath in cache...");

    // 1. DO NOT 'await' this.
    // This allows the code to continue immediately.
    FirebaseFirestore.instance
        .collection('site_content')
        .doc('landing_page')
        .update({fieldPath: value})
        .then((_) {
          // This only triggers when the SERVER finally confirms
          final ms = DateTime.now().difference(start).inMilliseconds;
          debugPrint(
            "✅ [SERVER SYNC COMPLETE] $fieldPath updated after ${ms}ms",
          );
        })
        .catchError((e) {
          debugPrint("⚠️ [SYNC ERROR] Will retry when online: $e");
        });

    // 2. The function ends here instantly, letting the UI close the dialogs.
    debugPrint("📦 [CACHE] UI is now free to move.");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('site_content')
          .doc('landing_page')
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // 1. Check if we have data (Cache OR Server)
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final isFromCache = snapshot.data!.metadata.isFromCache;
          debugPrint(
            "📥 [SETTINGS] Data Source: ${isFromCache ? 'LOCAL CACHE' : 'SERVER'}",
          );

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final site = data['site'] as Map<String, dynamic>? ?? {};
          final List services = data['services'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "1. Services Management",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildServiceList(context, services),
              const Divider(height: 40),
              const Text(
                "2. Branding",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: const Text("Business Name"),
                subtitle: Text(site['name'] ?? "Not set"),
                trailing: const Icon(Icons.edit),
                onTap: () =>
                    _editSingleField(context, "site.name", site['name'] ?? ""),
              ),
              ListTile(
                title: const Text("Tag line"),
                subtitle: Text(site['tagline'] ?? "Not set"),
                trailing: const Icon(Icons.edit),
                onTap: () => _editSingleField(
                  context,
                  "site.tagline",
                  site['tagline'] ?? "",
                ),
              ),
              ListTile(
                title: const Text("Phone Number"),
                subtitle: Text(data['contact']['phone'] ?? "Not set"),
                trailing: const Icon(Icons.edit),
                onTap: () => _editSingleField(
                  context,
                  "contact.phone",
                  data['contact']['phone'] ?? "",
                ),
              ),
              ListTile(
                title: const Text("business Email"),
                subtitle: Text(data['contact']['email'] ?? "Not set"),
                trailing: const Icon(Icons.edit),
                onTap: () => _editSingleField(
                  context,
                  "contact.email",
                  data['contact']['email'] ?? "",
                ),
              ),
              ListTile(
                title: const Text("Address"),
                subtitle: Text(data['contact']['address'] ?? "Not set"),
                trailing: const Icon(Icons.edit),
                onTap: () => _editSingleField(
                  context,
                  "contact.address",
                  data['contact']['address'] ?? "",
                ),
              ),
            ],
          );
        }

        // 2. If there is an error (e.g., permissions), show it
        if (snapshot.hasError) {
          debugPrint("❌ [SETTINGS ERROR]: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // 3. ONLY show the loader if we have NO data at all
        // (This happens during the first-ever launch or if cache is cleared)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // --- Sub-widgets and Helpers for SettingsTab ---
  Widget _buildServiceList(BuildContext context, List services) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _showServiceDialog(context, services),
          icon: const Icon(Icons.add),
          label: const Text("Add New Service"),
        ),
        ...services.asMap().entries.map((e) {
          final serviceData = e.value as Map<String, dynamic>;
          return ListTile(
            title: Text(serviceData['title'] ?? "Unnamed Service"),
            subtitle: Text(serviceData['price'] ?? "No price"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _showServiceDialog(context, services, index: e.key),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, services, e.key),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _editSingleField(BuildContext ctx, String path, String val) {
    final c = TextEditingController(text: val);
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: Text("Edit"),
        content: TextField(controller: c),
        actions: [
          ElevatedButton(
            onPressed: () {
              _updateField(path, c.text);
              Navigator.pop(dCtx);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showServiceDialog(BuildContext context, List services, {int? index}) {
    final isEditing = index != null;
    final Map serviceData = isEditing ? Map.from(services[index]) : {};

    final titleC = TextEditingController(text: serviceData['title'] ?? "");
    final priceC = TextEditingController(text: serviceData['price'] ?? "");
    final descC = TextEditingController(text: serviceData['description'] ?? "");
    final imageC = TextEditingController(text: serviceData['image'] ?? "");
    final durC = TextEditingController(
      text: serviceData['duration'] is List
          ? (serviceData['duration'] as List).join(", ")
          : "60 min, 90 min",
    );
    List tempAddons = serviceData['addons'] != null
        ? List.from(serviceData['addons'])
        : [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(isEditing ? "Edit Service" : "Add Service"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleC,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: priceC,
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
                  TextField(
                    controller: descC,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: imageC,
                    decoration: const InputDecoration(labelText: "Image URL"),
                  ),
                  TextField(
                    controller: durC,
                    decoration: const InputDecoration(
                      labelText: "Durations (comma separated)",
                    ),
                  ),
                  const Divider(),
                  const Text(
                    "Add-ons",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...tempAddons.asMap().entries.map(
                    (e) => Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(hintText: "Name"),
                            onChanged: (v) => e.value['name'] = v,
                            controller: TextEditingController(
                              text: e.value['name'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Price",
                            ),
                            onChanged: (v) => e.value['price'] = v,
                            controller: TextEditingController(
                              text: e.value['price'],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              setS(() => tempAddons.removeAt(e.key)),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        setS(() => tempAddons.add({"name": "", "price": ""})),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Add-on"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newService = {
                  "title": titleC.text,
                  "price": priceC.text,
                  "description": descC.text,
                  "image": imageC.text,
                  "duration": durC.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  "addons": tempAddons,
                };

                List updatedList = List.from(services);
                if (index != null) {
                  updatedList[index] = newService;
                } else {
                  updatedList.add(newService);
                }

                // 1. NON-BLOCKING UPDATE
                _updateField("services", updatedList);

                // 2. INSTANT UI FEEDBACK
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, List services, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Service"),
        content: const Text("Are you sure you want to delete this service?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              List updatedList = List.from(services);
              updatedList.removeAt(index);
              await _updateField("services", updatedList);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
