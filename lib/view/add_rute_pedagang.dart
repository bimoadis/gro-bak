import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gro_bak/helpers/adress.dart';

import 'package:gro_bak/repository/getAddress.dart';

class AddRutePedagang extends StatefulWidget {
  @override
  State<AddRutePedagang> createState() => _AddRutePedagangState();
}

class _AddRutePedagangState extends State<AddRutePedagang> {
  final _auth = FirebaseAuth.instance;
  final ApiService apiService = ApiService();
  final TextEditingController _addressController = TextEditingController();

  List<Region> provinces = [];
  List<Region> regencies = [];
  List<Region> districts = [];

  Region? selectedProvince;
  Region? selectedRegency;
  Region? selectedDistrict;

  @override
  void initState() {
    super.initState();
    _fetchProvinces();
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
        _addressController.text.isEmpty) {
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
          rute.add({
            "name": fullAddress,
            "latitude": latitude,
            "longitude": longitude,
            "address": fullAddress,
          });

          await ref.doc(user.uid).update({'rute': rute});
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Address saved successfully')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Alamat'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<Region>(
              hint: Text('Pilih Provinsi'),
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
                      style: TextStyle(color: Colors.black)),
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
              hint: Text('Pilih Kabupaten/Kota'),
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
                  child:
                      Text(regency.name, style: TextStyle(color: Colors.black)),
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
            SizedBox(height: 16.0),
            DropdownButtonFormField<Region>(
              hint: Text('Pilih Kecamatan'),
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
                      style: TextStyle(color: Colors.black)),
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
            SizedBox(height: 16.0),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Nama Jalan, Gedung, No. Rumah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text('Simpan Alamat'),
            ),
          ],
        ),
      ),
    );
  }
}
