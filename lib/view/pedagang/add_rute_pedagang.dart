import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gro_bak/services/adress.dart';

import 'package:gro_bak/repository/getAddress.dart';
import 'package:gro_bak/view/widget/bottom_bar.dart';

class AddRutePedagang extends StatefulWidget {
  @override
  State<AddRutePedagang> createState() => _AddRutePedagangState();
}

class _AddRutePedagangState extends State<AddRutePedagang> {
  final _auth = FirebaseAuth.instance;
  final ApiService apiService = ApiService();
  late TimeOfDay _selectedStartTime = TimeOfDay.now();
  late TimeOfDay _selectedEndTime = TimeOfDay.now();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  List<Region> provinces = [];
  List<Region> regencies = [];
  List<Region> districts = [];

  Region? selectedProvince;
  Region? selectedRegency;
  Region? selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Alamat'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              DropdownButtonFormField<Region>(
                hint: const Text('Pilih Provinsi'),
                value: selectedProvince,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: provinces.map((Region province) {
                  return DropdownMenuItem<Region>(
                    value: province,
                    child: Text(province.name,
                        style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (Region? newValue) {
                  setState(() {
                    selectedProvince = newValue;
                    if (selectedProvince != null) {
                      _fetchRegencies(selectedProvince!.id);
                    }
                  });
                },
                itemHeight: 48.0,
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<Region>(
                hint: const Text('Pilih Kabupaten/Kota'),
                value: selectedRegency,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: regencies.map((Region regency) {
                  return DropdownMenuItem<Region>(
                    value: regency,
                    child: Text(regency.name,
                        style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (Region? newValue) {
                  setState(() {
                    selectedRegency = newValue;
                    if (selectedRegency != null) {
                      _fetchDistricts(selectedRegency!.id);
                    }
                  });
                },
                itemHeight: 48.0,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<Region>(
                hint: const Text('Pilih Kecamatan'),
                value: selectedDistrict,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: districts.map((Region district) {
                  return DropdownMenuItem<Region>(
                    value: district,
                    child: Text(district.name,
                        style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (Region? newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                  });
                },
                itemHeight: 48.0,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Nama Jalan, Gedung, No. Rumah',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextField(
                        controller: _startTimeController,
                        onTap: () {
                          _selectStartTime(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Waktu Mulai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextField(
                        controller: _endTimeController,
                        onTap: () {
                          _selectEndTime(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Waktu Selesai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFEC901),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Simpan Alamat',
                  style: TextStyle(
                    color: Color(0xFF060100),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
        _startTimeController.text = _selectedStartTime.format(context);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
        _endTimeController.text = _selectedEndTime.format(context);
      });
    }
  }

  Future<void> _fetchProvinces() async {
    try {
      List<Region> provinceList = await apiService.fetchProvinces();
      setState(() {
        provinces = provinceList;
      });
    } catch (e) {
      print('Failed to load provinces: $e');
    }
  }

  Future<void> _fetchRegencies(String provinceId) async {
    try {
      List<Region> regencyList = await apiService.fetchRegencies(provinceId);
      setState(() {
        regencies = regencyList;
        selectedRegency = null;
        districts = [];
        selectedDistrict = null;
      });
    } catch (e) {
      print('Failed to load regencies: $e');
    }
  }

  Future<void> _fetchDistricts(String regencyId) async {
    try {
      List<Region> districtList = await apiService.fetchDistricts(regencyId);
      setState(() {
        districts = districtList;
        selectedDistrict = null;
      });
    } catch (e) {
      print('Failed to load districts: $e');
    }
  }

  Future<void> _saveAddress() async {
    if (selectedProvince == null ||
        selectedRegency == null ||
        selectedDistrict == null ||
        _addressController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    String fullAddress =
        '${_addressController.text}, ${selectedDistrict!.name}, ${selectedRegency!.name}, ${selectedProvince!.name}';
    print('Full address: $fullAddress');

    try {
      List<Location> locations = await locationFromAddress(fullAddress);
      print('Locations: $locations');

      if (locations.isNotEmpty) {
        double latitude = locations.first.latitude;
        double longitude = locations.first.longitude;
        print('Latitude: $latitude, Longitude: $longitude');

        FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
        var user = _auth.currentUser;
        if (user != null) {
          CollectionReference ref =
              FirebaseFirestore.instance.collection('merchant');
          DocumentSnapshot docSnapshot = await ref.doc(user.uid).get();

          List<dynamic> rute = docSnapshot['rute'] ?? [];

          String startTime = _startTimeController.text;
          String endTime = _endTimeController.text;
          String time = '${startTime} sampai ${endTime}';

          rute.add({
            "name": fullAddress,
            "latitude": latitude,
            "longitude": longitude,
            "address": fullAddress,
            "time": time,
          });

          await ref.doc(user.uid).update({'rute': rute});
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(),
            ),
            (Route<dynamic> route) =>
                false, // Menghapus semua halaman sebelumnya
          );
        } else {
          print('User is not logged in');
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('User is not logged in')));
        }
      } else {
        print('Failed to find location for the address');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to find location')));
      }
    } catch (e) {
      print('Failed to save address: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save address')));
    }
  }
}
