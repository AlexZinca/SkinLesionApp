import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Clinic {
  final String name;
  final String url;

  Clinic(this.name, this.url);
}

class City {
  final String name;
  final List<Clinic> clinics;

  City(this.name, this.clinics);
}

class ClinicsPage extends StatefulWidget {
  const ClinicsPage({super.key});

  @override
  State<ClinicsPage> createState() => _ClinicsPageState();
}

class _ClinicsPageState extends State<ClinicsPage> {
  TextEditingController searchController = TextEditingController();
  List<City> filteredCities = [];
  City? selectedCity;
  Clinic? selectedClinic;

  // Mock data for cities and clinics
  final List<City> cities = [
    City("Brasov", [
      Clinic("QualiMed", "https://dermatologie-brasov.ro/"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
      Clinic("Regina Maria", "https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6955&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("ArtMedica", "https://artmedica.ro/servicii/dermatologie/?gad_source=1&gclid=Cj0KCQjwk6SwBhDPARIsAJ59GwevRVf0Tkp9z3myulcZM__LH8cPA7YkddN4j6VvNQoLF1PI2BwkSwkaAt5kEALw_wcB"),
      Clinic("Premium Derma","https://premiumderma.ro/")
    ]),
    City("Bucharest", [
      Clinic("MedLife",
          "https://www.medlife.ro/dermatovenerologie"),
      Clinic("Regina Maria Dermatology",
          "https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6951&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Dr.Leventer Centre", "https://drleventercentre.com/"),
      Clinic("Medicover","https://www.medicover.ro/medici/dermatologie/bucuresti,sl,s"),
      Clinic("Sanador","https://www.sanador.ro/dermatovenerologie"),
      Clinic("Laurus Medical","https://www.laurusmedical.ro/dermatologie/"),
      Clinic("Lineya","https://lineya.ro/?gad_source=1&gclid=Cj0KCQjwk6SwBhDPARIsAJ59GweITG2OmfErSiCnNk1qkSsV7bQvd-fbrB2t3Tsd6QbOgO0sAA8wP5EaAl10EALw_wcB"),
    ]),
    City("Cluj-Napoca", [
      Clinic("Regina Maria", "https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6953&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Anastasios",
          "https://anastasios.ro/cluj/dermatovenerologie/?gclid=Cj0KCQjwk6SwBhDPARIsAJ59GwdM6O1sm_HrDGifjgC2G1vKo1ttrp-cWJTmeflretJiYuiQtLm-zRcaAo16EALw_wcB"),
      Clinic("Centrul Medical Promedis", "https://promedis.ro/servicii/dermatologie/"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
      Clinic("DermaElite","https://dermaelite.ro/"),
      Clinic("Laurus Medical","https://www.laurusmedical.ro/dermatologie/"),
    ]),
    City("Iasi", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6958&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic(
          "Lauderma", "https://lauderma.ro/"),
      Clinic("HermaMed Centre", "https://hermamedcenter.ro/servicii-medicale/dermatologie-iasi-consultatii-gratuite/?gad_source=1&gclid=Cj0KCQjwk6SwBhDPARIsAJ59GwcJDbd8vynYexSVhv26TGHTjA8maCcoqiA1Y6HiFuxhcZF6pMcMXXYaAg_xEALw_wcB"),
      Clinic("Arcadia", "https://www.arcadiamedical.ro/specialitati/dermato-venerologie"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Timisoara", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6959&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Medici\'s", "https://medicis.ro/dermatologie/"),
      Clinic("Profilaxia", "https://www.profilaxia.ro/specialitati/dermatologie/"),
      Clinic("Clinica Jose Silva", "https://clinicajosesilva.ro/dermatologie/"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),

    City("Constanta", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6952&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Cermed", "https://cermed.ro/servicii/clinica-dermatologie-constanta-cermed/?gad_source=1"),
      Clinic("IMAMED", "https://imamed.ro/dermatologie-constanta/"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Sibiu", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A25107&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Misan Med", "https://misanmed.ro/servicii/dermatologie/"),
      Clinic("Policlinica Astra", "https://policlinica-astra.ro/dermatologie/"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    // Additional cities and clinics can be added here
    City("Galati", [
      Clinic("Centrul Medical ProClinic", "https://pro-clinic.ro/dermato-venerologie/"),
      Clinic("Medicover", "https://www.medicover.ro/medici/dermatologie/galati,sl,s"),
      Clinic("Laurus Medical","https://www.laurusmedical.ro/dermatologie/"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Craiova", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6957&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("PRO DERMA", "https://pro-derma.ro/"),
      Clinic("Policlinica Elga", "https://www.policlinicaelga.ro/dermato-venerologie"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Braila", [
      Clinic("Clinica Mateus", "https://clinicamateus.ro/dermatologie/"),
      Clinic("Centrul Medical Grivita", "https://www.centrulmedicalgrivita.ro/dermato.html"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Oradea", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6977&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Centrul Medical Bioinvest", "https://bioinvestmedicalcenter.ro/dermatologie-servicii-tarife/"),
      Clinic("Spital Pelican", "https://www.spitalpelican.ro/medici/specialitate/dermatologie"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Ploiesti", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6960&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Centrul Medical Andodent", "https://www.andodent.ro/dermatologie/"),
      Clinic("Clinica Medical Panaceea", "https://clinicapanaceea.ro/dermatologie/"),
      Clinic("Laurus Medical","https://www.laurusmedical.ro/dermatologie/"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Arad", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6971&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Policlinica AS", "https://policlinica-as.ro/index.php/portfolio-items/dermatologie-arad/"),
      Clinic("Clinica MEDIQA", "https://mediqa.ro/specialitati/dermatologie"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Targu Mures", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6961&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Spitalul Clinic Judetean Mures", "https://spitaljudeteanmures.ro/scjm2/index.php/dermatovenerologie/"),
      Clinic("Hebe Medical", "https://www.hebemedical.ro/dermatovenerologie"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Baia Mare", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A6975&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Spitalul Sfantul Ioan", "https://spitalsfantulioan.ro/specialitati-medicale/dermatovenerologie/"),
      Clinic("Dr.Alexandra Bene", "https://dralexandrabene.ro/preturi/"),
    ]),
    City("Buzau", [
      Clinic("Clinica Angi San", "https://angisan.ro/dermatologie/"),
      Clinic("Spitalul Judetean de Urgenta Buzau", "https://www.spitalulbuzau.ro/spital-compartiment-dermato-venerologie"),
      Clinic("Laurus Medical","https://www.laurusmedical.ro/dermatologie/"),
    ]),
    City("Suceava", [
      Clinic("Regina Maria","https://www.reginamaria.ro/medici?specialitate=7043&medici%5B0%5D=city%3A25768&medici%5B1%5D=specialitate%3ADermatovenerologie"),
      Clinic("Clinica Hereditas", "https://clinica-hereditas.ro/servicii-si-specialitati-clinice-suceava/dermatovenerologie-suceava/?gad_source=1&gclid=Cj0KCQjwk6SwBhDPARIsAJ59Gwd4TVJ8X18UNIW9hUt2W_Uyy93mTGA1zOVKDlh06LJ3pF8HSVq0fD8aApghEALw_wcB"),
      Clinic("Alma Clinic", "https://almaclinic.ro/services/dermatologie-suceava/"),
      Clinic("Laurus Medical","https://www.laurusmedical.ro/dermatologie/"),
    ]),
    City("Piatra Neamt", [
      Clinic("Spitalul Judetean Neamt", "https://www.sjuneamt.ro/ambulatoriul-integrat-de-specialitate-a-i-s/dermatovenerologie"),
      Clinic("Clinica Medicala Sf.Andrei", "https://www.clinicasfandrei.ro/ambulatoriu/dermatologie"),
      Clinic("MedLife", "https://www.medlife.ro/dermatovenerologie"),
    ]),
    City("Drobeta-Turnu Severin", [
      Clinic("Elixir Medical", "https://elixirmedical.ro/dermatologie/p/1561156996609/"),
      Clinic("Centrul Medical Dr. Buzullca", "https://www.dermato-venerice.ro/dermato-venerice/drobeta-turnu-severin"),
    ]),
    City("Focsani", [
      Clinic("Laurus Medical","https://www.laurusmedical.ro/dermatologie/"),
      Clinic("Cabinet Dermatovenerologie Dr. Belmega Calin", "https://dermatologiefocsani.ro/contact/"),
    ]),
  ];


  @override
  void initState() {
    super.initState();
    // Sort cities alphabetically and initialize filteredCities with all cities
    cities.sort((a, b) => a.name.compareTo(b.name));
    filteredCities = List.from(cities);
  }

  void _filterCities(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      setState(() {
        filteredCities = List.from(cities);
      });
    } else {
      setState(() {
        filteredCities = cities
            .where((city) =>
            city.name.toLowerCase().startsWith(enteredKeyword.toLowerCase()))
            .toList();
      });
    }
  }

  void _showClinicsBottomSheet(BuildContext context) {
    int numberOfClinics = selectedCity!.clinics.length;
    double minHeight = 250;
    double maxHeight = 470;
    double height = MediaQuery.of(context).size.height * 0.5; // Initial height

    if (numberOfClinics > 0) {
      double clinicTileHeight = 50; // Height of each ListTile
      double totalClinicHeight = numberOfClinics * clinicTileHeight;
      double totalHeight = totalClinicHeight + 2 * clinicTileHeight + 8.0; // Total height including Divider and SizedBox

      // Adjust height within the specified range
      height = totalHeight.clamp(minHeight, maxHeight);
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight, maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(30.0),
                topRight: const Radius.circular(30.0),
              ),
            ),
            child: GestureDetector(
              onVerticalDragDown: (_) {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10.0), // Add SizedBox before the list
                  Divider(indent: 160, endIndent: 160, thickness: 4), // Divider in the center
                  SizedBox(height: 8.0), // Add SizedBox before the list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Select Clinic',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0), // Add SizedBox before the list
                  Container(
                    constraints: BoxConstraints(maxHeight: height), // Adjusted height
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: numberOfClinics,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(selectedCity!.clinics[index].name),
                          onTap: () {
                            setState(() {
                              selectedClinic = selectedCity!.clinics[index];
                            });
                            launchURL(selectedClinic!.url); // Launches the URL of the selected clinic
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
        title: const Text('CLINICS', style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Center( // Wrap with Center widget to align in the center of the screen
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0,0,0,0), // No outer padding needed here
              child: TextField(
                controller: searchController,
                style: TextStyle(
                  color: Colors.grey, // Sets the text color to grey
                ),
                decoration: InputDecoration(
                  hintText: 'Search City',
                  hintStyle: TextStyle(color: Colors.grey), // Sets the hint text color to grey
                  prefixIcon: Icon(Icons.search, color: Colors.grey), // Sets the icon color to grey
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent, // Keeping the TextField background transparent
                ),
                onChanged: (value) => _filterCities(value),
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // Keeps city blocks square
              ),
              itemCount: filteredCities.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  color: Color.fromARGB(255, 118, 197, 218).withOpacity(0.7),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedCity = filteredCities[index];
                        _showClinicsBottomSheet(context); // Show the bottom sheet with clinics
                      });
                    },
                    child: Center(
                      child: Text(
                        filteredCities[index].name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
