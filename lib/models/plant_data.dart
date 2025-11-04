class PlantInfo {
  final String name;
  final String medicalUses;
  final String description;

  PlantInfo({
    required this.name,
    required this.medicalUses,
    required this.description,
  });
}

/// Database of common plants with their medicinal uses
/// These class names should match your ViT model's output labels
final plantDatabase = {
  'tulsi': PlantInfo(
    name: 'Tulsi (Holy Basil)',
    medicalUses:
        'Immune booster, anti-inflammatory, stress relief, respiratory health, antibacterial properties',
    description: 'Sacred plant in Ayurveda known for its powerful medicinal properties.',
  ),
  'neem': PlantInfo(
    name: 'Neem',
    medicalUses:
        'Skin health, antibacterial, antifungal, blood purification, dental care, anti-parasitic',
    description: 'Bitter plant with exceptional antimicrobial and skin-healing properties.',
  ),
  'aloe_vera': PlantInfo(
    name: 'Aloe Vera',
    medicalUses:
        'Skin healing, wound care, digestive health, anti-inflammatory, skin moisturizer',
    description: 'Succulent plant rich in beneficial compounds for skin and digestion.',
  ),
  'mint': PlantInfo(
    name: 'Mint',
    medicalUses:
        'Digestive aid, headache relief, respiratory health, cooling effect, breath freshener',
    description: 'Aromatic herb commonly used for culinary and medicinal purposes.',
  ),
  'ginger': PlantInfo(
    name: 'Ginger',
    medicalUses:
        'Anti-nausea, anti-inflammatory, digestive aid, circulation improvement, pain relief',
    description: 'Rhizomatous plant with warming and healing properties.',
  ),
  'turmeric': PlantInfo(
    name: 'Turmeric',
    medicalUses:
        'Anti-inflammatory, antioxidant, pain relief, immune support, skin health, liver support',
    description: 'Golden spice with powerful curcumin compound for whole-body wellness.',
  ),
  'basil': PlantInfo(
    name: 'Basil',
    medicalUses:
        'Antibacterial, anti-inflammatory, antioxidant, digestive support, mood enhancement',
    description: 'Aromatic herb with culinary and medicinal applications.',
  ),
  'thyme': PlantInfo(
    name: 'Thyme',
    medicalUses:
        'Cough relief, respiratory health, antimicrobial, antioxidant, digestive aid',
    description: 'Small-leaved herb with strong medicinal properties.',
  ),
  'chamomile': PlantInfo(
    name: 'Chamomile',
    medicalUses:
        'Sleep aid, anxiety relief, digestive health, anti-inflammatory, calming effect',
    description: 'Delicate flower commonly brewed as a soothing tea.',
  ),
  'lavender': PlantInfo(
    name: 'Lavender',
    medicalUses:
        'Stress relief, sleep improvement, skin care, pain relief, anxiety reduction',
    description: 'Fragrant purple flowers known for calming and relaxation properties.',
  ),
  'lemon_balm': PlantInfo(
    name: 'Lemon Balm',
    medicalUses:
        'Anxiety relief, mood improvement, digestive aid, sleep support, stress reduction',
    description: 'Lemon-scented herb from the mint family.',
  ),
  'rosemary': PlantInfo(
    name: 'Rosemary',
    medicalUses:
        'Memory enhancement, circulation improvement, anti-inflammatory, antioxidant, hair health',
    description: 'Evergreen herb with cognitive and circulatory benefits.',
  ),
};

/// Get plant info by model output label
PlantInfo? getPlantInfo(String label) {
  final normalizedLabel = label.toLowerCase().replaceAll(' ', '_');
  return plantDatabase[normalizedLabel];
}

/// Check if a label corresponds to a known plant
bool isKnownPlant(String label) {
  return plantDatabase.containsKey(label.toLowerCase().replaceAll(' ', '_'));
}
