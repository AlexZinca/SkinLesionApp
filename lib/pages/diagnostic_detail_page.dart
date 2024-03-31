import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DiagnosticDetailPage extends StatelessWidget {
  final String name;

  String getDiseaseDescription(String diseaseName) {
    final Map<String, String> descriptions = {
      'Actinic keratoses and intraepithelial carcinoma / Bowen\'s disease':
      'Actinic Keratoses (AK) are precancerous skin lesions caused by prolonged UV exposure, appearing as rough, scaly patches on sun-exposed areas. These lesions may progress to squamous cell carcinoma (SCC) if untreated. Bowen\'s disease, a form of SCC in situ, presents as a persistent red, scaly patch. Treatments include cryotherapy, topical chemotherapy, and photodynamic therapy. Prevention strategies emphasize sun protection. AK and Bowen\'s disease are not inherited but result from environmental damage. They signify the skin\'s response to UV damage and can vary in appearance from flat and scaly to slightly raised.',
      'Basal cell carcinoma':
      'Basal Cell Carcinoma (BCC) is the most frequent skin cancer, originating from basal cells in the epidermis. It manifests as pearly bumps, red patches, or open sores that fail to heal, mainly on sun-exposed areas. While not usually inherited, risk factors include fair skin and genetic predispositions. Treatments range from surgical excision, Mohs surgery, to topical medications and radiation therapy for non-operable cases. Preventive measures include rigorous sun protection. Early detection through regular skin checks is crucial for management.',
      'Benign keratosis':
      'Benign keratosis covers non-cancerous growths like seborrheic keratoses and actinic keratoses, appearing as brown, black, or light tan skin lesions. While generally not requiring treatment, options include cryotherapy, laser therapy, and surgical removal for discomfort or cosmetic reasons. Prevention of actinic keratoses involves sun protection. These growths are primarily due to aging and sun exposure, with a minor genetic component for seborrheic keratoses, suggesting a biological predisposition in some individuals.',
      'Dermatofibroma':
      'Dermatofibromas are benign, firm skin nodules, typically brown or red, often found on the legs. They may result from minor skin injuries and are not considered inherited. Treatment is usually unnecessary unless for symptoms or cosmetic reasons, where surgical removal is an option. There are no specific preventive measures for dermatofibromas. Their appearance is characteristic, and they are often mistaken for moles.',
      'Melanoma':
      'Melanoma is a serious form of skin cancer originating from melanocytes. It presents as a new dark spot or an existing mole that changes in color, shape, or size. Melanoma can be genetically predisposed, with mutations in specific genes increasing risk. Treatment options include surgical removal, immunotherapy, targeted therapy, chemotherapy, and radiation. Preventive measures focus on protecting skin from UV radiation and regular skin checks. Early detection significantly improves prognosis.',
      'Melanocytic nevi':
      'Commonly known as moles, melanocytic nevi are benign skin growths that vary in color from pink to dark brown. Most are acquired, though some are congenital. Rarely, they can evolve into melanoma, especially if there\'s a family history of skin cancer. Regular monitoring and dermatological evaluations are recommended. Preventive measures include sun protection to reduce the chance of moles becoming cancerous. They are usually removed surgically if they show signs of malignancy or for cosmetic reasons.',
      'Vascular lesions':
      'Vascular lesions, such as hemangiomas and port-wine stains, are abnormalities in blood vessels presenting as visible marks on the skin. Most are not inherited and appear spontaneously or shortly after birth. Treatment varies by type, including laser therapy, surgery, and sometimes medication for symptom management. Prevention is not applicable as most vascular lesions are congenital. Their appearance can range from small, flat areas to raised, bright red nodules.',
    };

    return descriptions[diseaseName] ??
        'No description available for this disease.';
  }

  void _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      // Handle the error
      print('Could not launch $url');
    }
  }



  // Making diseaseLinks a compile-time constant
  static const Map<String, List<String>> diseaseLinks = {
    'Actinic keratoses and intraepithelial carcinoma / Bowen\'s disease': [
      'https://www.mayoclinic.org/diseases-conditions/actinic-keratosis/diagnosis-treatment/drc-20354975',
      'https://www.skincancer.org/skin-cancer-information/actinic-keratosis/',
      // Replace with actual link
      'https://www.aad.org/public/diseases/scaly-skin/actinic-keratosis',
      // Replace with actual link
    ],
    'Basal cell carcinoma': [

      'https://www.skincancer.org/skin-cancer-information/basal-cell-carcinoma/',
      // Replace with actual link
      'https://www.aad.org/public/diseases/skin-cancer/types/common/bcc',
      'https://www.healthdirect.gov.au/basal-cell-carcinoma',
      // Replace with actual link
    ],
    // Add other diseases and their links
    'Benign keratosis': [
      'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10188172/',
      // Overview of seborrheic keratoses from the American Academy of Dermatology
      'https://www.mayoclinic.org/diseases-conditions/seborrheic-keratosis/symptoms-causes/syc-20353878',
      // Mayo Clinic's page on seborrheic keratosis
      'https://www.aad.org/public/diseases/a-z/seborrheic-keratoses-treatment',
      // Information on seborrheic keratoses from The Skin Cancer Foundation
    ],

    'Dermatofibroma': [
      'https://www.dermnetnz.org/topics/dermatofibroma/',
      // DermNet NZ offers a comprehensive guide on dermatofibroma
      'https://www.ncbi.nlm.nih.gov/books/NBK470538/',
      // The American Academy of Dermatology's resource on dermatofibroma
      'https://www.medicalnewstoday.com/articles/318870#treatment',
      // Mayo Clinic's overview of dermatofibroma
    ],

    'Melanoma': [
      'https://www.skincancer.org/skin-cancer-information/melanoma/',
      // The Skin Cancer Foundation's detailed guide on melanoma
      'https://www.mayoclinic.org/diseases-conditions/melanoma/symptoms-causes/syc-20374884',
      // Mayo Clinic's melanoma resource
      'https://www.cancer.org/cancer/melanoma-skin-cancer.html',
      // American Cancer Society's melanoma information page
    ],

    'Melanocytic nevi': [
      'https://emedicine.medscape.com/article/1058445-overview?form=fpf',
      // American Academy of Dermatology's resource on moles (melanocytic nevi)
      'https://emedicine.medscape.com/article/1058445-clinical?form=fpf',
      // DermNet NZ's comprehensive guide on melanocytic nevi
      'https://www.ncbi.nlm.nih.gov/books/NBK470451/',
      // Mayo Clinic's overview of moles
    ],

    'Vascular lesions': [
      'https://www.dermnetnz.org/topics/capillary-vascular-malformation/',
      // DermNet NZ on capillary vascular malformations
      'https://dermoscopedia.org/Vascular_lesions',
      // American Academy of Dermatology on birthmarks (including vascular lesions)
      'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7007481/',
      // Mayo Clinic's resource on hemangiomas
    ],
  };

  static final List<IconData> linkIcons = [
    Icons.circle, // Icon for the first link
    Icons.square, // Icon for the second link
    Icons.circle_outlined, // Icon for the third link
  ];

  // Remove 'const' from the constructor since 'linkIcons' is now a static final
  DiagnosticDetailPage({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> diseaseSpecificLinks = diseaseLinks[name] ?? [];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
        title: const Text('DIAGNOSTIC DETAILS',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(26.0),
              child: Center(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black, // Text color
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 0),
            Padding(
              padding: EdgeInsets.fromLTRB(30.0, 0 , 30, 0 ), // Adjust this padding as needed
              child: Container(
                height: 3.0, // Height of the line
                width: double.infinity, // Makes the line full width within the padding
                color: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),// Color of the line

              ),
            ),
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                getDiseaseDescription(name),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54), // Make the text inclined
                textAlign: TextAlign.center,
              ),
            )

            //... Add any additional content you want on this page
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // This is needed to size the column to its children's size
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'For more information, you can check the following links:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom), // Safe area padding
            color: Colors.transparent, // Transparent background color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(diseaseSpecificLinks.length, (index) {
                return GestureDetector(
                  onTap: () => _launchURL(diseaseSpecificLinks[index]), // Use correct URL
                  child: GestureDetector(
                    onTap: () => _launchURL(diseaseSpecificLinks[index]),
                    child: Container(
                      width: 60,
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 10),// Adjusted width to accommodate the icon and padding
                      padding: EdgeInsets.all(8), // Padding inside the container
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 94, 184, 209).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(linkIcons[index], color: Colors.white, size: 24),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}