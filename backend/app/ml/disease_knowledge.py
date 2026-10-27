"""Disease knowledge base with treatment recommendations."""
from typing import Dict, Optional, Tuple
import logging

logger = logging.getLogger(__name__)

# Comprehensive disease treatment database
# Format: disease_key -> {symptoms, treatment, prevention, severity}
DISEASE_DATABASE = {
    # Apple diseases
    "apple_scab": {
        "symptoms": "Dark, olive-green to black spots on leaves and fruits; scabby lesions on fruit surface.",
        "treatment": "Apply fungicides like Captan or Myclobutanil at first sign. Remove infected leaves.",
        "prevention": "Plant resistant varieties; ensure good air circulation; remove fallen leaves in autumn.",
        "severity": "moderate",
    },
    "apple_black_rot": {
        "symptoms": "Purple or red spots on leaves; fruit rot with concentric rings.",
        "treatment": "Prune infected branches; apply copper-based fungicides during growing season.",
        "prevention": "Remove mummified fruits and cankers; maintain tree vigor with proper nutrition.",
        "severity": "severe",
    },
    "apple_cedar_rust": {
        "symptoms": "Bright orange or yellow spots on leaves; may cause premature leaf drop.",
        "treatment": "Apply myclobutanil or propiconazole fungicides in spring.",
        "prevention": "Remove nearby cedar trees if possible; plant resistant apple varieties.",
        "severity": "moderate",
    },
    
    # Corn/Maize diseases
    "corn_gray_leaf_spot": {
        "symptoms": "Rectangular gray to tan lesions on leaves parallel to veins.",
        "treatment": "Foliar fungicide application of azoxystrobin or pyraclostrobin if severe.",
        "prevention": "Crop rotation with non-host crops; use resistant hybrids; manage crop residue.",
        "severity": "moderate",
    },
    "corn_common_rust": {
        "symptoms": "Small, circular to elongate reddish-brown pustules on both leaf surfaces.",
        "treatment": "Apply triazole fungicides if infection is severe before tasseling.",
        "prevention": "Plant rust-resistant hybrids; monitor fields regularly during humid weather.",
        "severity": "moderate",
    },
    "corn_northern_leaf_blight": {
        "symptoms": "Long, elliptical gray-green lesions on leaves, may cover entire leaf blade.",
        "treatment": "Spray fungicides containing azoxystrobin or propiconazole at disease onset.",
        "prevention": "Use resistant hybrids; practice crop rotation; plow under crop debris.",
        "severity": "severe",
    },
    
    # Grape diseases
    "grape_black_rot": {
        "symptoms": "Circular tan spots on leaves with dark borders; fruit mummies with black pycnidia.",
        "treatment": "Apply mancozeb or myclobutanil fungicides from bud break through harvest.",
        "prevention": "Remove mummified berries; prune for air circulation; avoid overhead irrigation.",
        "severity": "severe",
    },
    "grape_esca": {
        "symptoms": "Tiger-stripe leaf pattern with yellow and green bands; berries shrivel and darken.",
        "treatment": "No effective chemical control; prune and remove infected wood.",
        "prevention": "Use clean pruning tools; protect pruning wounds; maintain vine vigor.",
        "severity": "severe",
    },
    "grape_leaf_blight": {
        "symptoms": "Brown necrotic spots on leaves with yellow halos.",
        "treatment": "Apply copper-based fungicides or mancozeb during growing season.",
        "prevention": "Remove infected leaves; ensure proper canopy management for airflow.",
        "severity": "moderate",
    },
    
    # Potato diseases
    "potato_early_blight": {
        "symptoms": "Dark brown circular spots with concentric rings (target pattern) on older leaves.",
        "treatment": "Foliar application of Mancozeb 75% WP @ 2 g/L or Chlorothalonil 75% WP @ 2 g/L at 10-day intervals.",
        "prevention": "Stake plants to prevent leaf-soil contact; drip irrigate to keep foliage dry; prune lower diseased leaves.",
        "severity": "moderate",
    },
    "potato_late_blight": {
        "symptoms": "Water-soaked irregular pale green lesions on leaves rapidly turning purplish-black with white mildew underneath.",
        "treatment": "Immediate spray of Cymoxanil 8% + Mancozeb 64% WP @ 2.5 g/L or Metalaxyl-M + Mancozeb @ 2.5 g/L.",
        "prevention": "Plant certified disease-free seed tubers; earth-up ridges properly to protect underground tubers.",
        "severity": "severe",
    },
    
    # Rice diseases
    "rice_bacterial_leaf_blight": {
        "symptoms": "Water-soaked stripes turning yellowish-white with wavy margins along leaf borders.",
        "treatment": "Drain stagnant water; apply Copper oxychloride 50% WP @ 2.5 g/L combined with Streptocycline @ 0.1 g/L.",
        "prevention": "Balance potassium and nitrogen fertilizer; avoid clipping seedling tips during transplanting.",
        "severity": "severe",
    },
    "rice_brown_spot": {
        "symptoms": "Oval brown spots with gray centers on leaves, sheaths, and grains.",
        "treatment": "Apply mancozeb or copper fungicides; ensure adequate potassium fertilization.",
        "prevention": "Use certified disease-free seeds; avoid water stress; maintain soil fertility.",
        "severity": "moderate",
    },
    "rice_leaf_blast": {
        "symptoms": "Diamond-shaped lesions with gray centers and brown margins on leaves.",
        "treatment": "Spray tricyclazole or azoxystrobin at early infection stage.",
        "prevention": "Use resistant varieties; avoid excessive nitrogen; ensure proper plant spacing.",
        "severity": "severe",
    },
    
    # Tomato diseases
    "tomato_bacterial_spot": {
        "symptoms": "Small, dark, water-soaked spots on leaves, stems, and fruits.",
        "treatment": "Apply copper-based bactericides; remove severely infected plants.",
        "prevention": "Use disease-free seeds; avoid overhead irrigation; practice crop rotation.",
        "severity": "moderate",
    },
    "tomato_early_blight": {
        "symptoms": "Dark brown circular spots with concentric rings ('target board' pattern) on older foliage.",
        "treatment": "Foliar application of Mancozeb 75% WP @ 2 g/L or Chlorothalonil 75% WP @ 2 g/L at 10-day intervals.",
        "prevention": "Stake plants to prevent leaf-soil contact; drip irrigate to keep foliage dry; prune lower diseased leaves.",
        "severity": "moderate",
    },
    "tomato_late_blight": {
        "symptoms": "Large, irregular, water-soaked lesions on leaves, turning brown; white fungal growth on undersides.",
        "treatment": "Apply Cymoxanil + Mancozeb or Metalaxyl-M fungicides immediately.",
        "prevention": "Space plants for air circulation; avoid overhead watering; remove infected plant parts.",
        "severity": "severe",
    },
    "tomato_leaf_mold": {
        "symptoms": "Yellow spots on upper leaf surface; olive-green to gray-brown fuzzy growth beneath.",
        "treatment": "Apply chlorothalonil or copper fungicides; improve greenhouse ventilation.",
        "prevention": "Reduce humidity; space plants adequately; use resistant varieties.",
        "severity": "moderate",
    },
    "tomato_septoria_leaf_spot": {
        "symptoms": "Numerous small, circular spots with dark borders and gray centers on leaves.",
        "treatment": "Spray mancozeb or chlorothalonil fungicides at first sign of disease.",
        "prevention": "Mulch around plants; avoid wetting foliage; remove infected leaves.",
        "severity": "moderate",
    },
    "tomato_spider_mites": {
        "symptoms": "Stippling and yellowing of leaves; fine webbing visible in severe infestations.",
        "treatment": "Spray with miticides or insecticidal soap; increase humidity.",
        "prevention": "Monitor regularly; avoid water stress; encourage natural predators.",
        "severity": "moderate",
    },
    "tomato_target_spot": {
        "symptoms": "Brown spots with concentric rings on leaves, stems, and fruits.",
        "treatment": "Apply azoxystrobin or chlorothalonil fungicides at disease onset.",
        "prevention": "Practice crop rotation; avoid overhead irrigation; use disease-free transplants.",
        "severity": "moderate",
    },
    "tomato_yellow_leaf_curl": {
        "symptoms": "Upward curling and yellowing of leaves; stunted plant growth.",
        "treatment": "Control whitefly vectors with imidacloprid or acetamiprid; remove infected plants.",
        "prevention": "Use reflective mulches; screen greenhouses; plant resistant varieties.",
        "severity": "severe",
    },
    "tomato_mosaic_virus": {
        "symptoms": "Mottled light and dark green patterns on leaves; distorted leaf growth.",
        "treatment": "No chemical treatment; remove and destroy infected plants.",
        "prevention": "Use virus-free seeds; disinfect tools; control aphid vectors; avoid tobacco use near plants.",
        "severity": "severe",
    },
    
    # Wheat diseases
    "wheat_brown_rust": {
        "symptoms": "Orange-brown pustules scattered on upper leaf surfaces.",
        "treatment": "Apply propiconazole or tebuconazole fungicides at early infection.",
        "prevention": "Plant resistant varieties; avoid excessive nitrogen; monitor regularly.",
        "severity": "moderate",
    },
    "wheat_yellow_rust": {
        "symptoms": "Yellowish-orange pustules arranged in linear stripes along leaf veins; stunted growth in severe cases.",
        "treatment": "Spray Propiconazole 25% EC @ 1 ml/L or Tebuconazole 25.9% EC @ 1.25 ml/L at early onset.",
        "prevention": "Use certified rust-resistant seed varieties (HD 2967, DBW 187, PBW 550); avoid excessive nitrogen.",
        "severity": "moderate",
    },
    
    # Cotton diseases
    "cotton_leaf_curl": {
        "symptoms": "Upward or downward curling of leaf margins; thickened veins; leaf enations on lower surface.",
        "treatment": "Manage whitefly insect vectors with Diafenthiuron 50% WP @ 1.2 g/L or Acetamiprid 20% SP @ 0.4 g/L.",
        "prevention": "Eradicate alternate weed hosts along field borders; grow tolerant hybrids.",
        "severity": "severe",
    },
    
    # Citrus diseases
    "orange_huanglongbing": {
        "symptoms": "Yellow shoots; blotchy mottled leaves; lopsided, bitter fruits with green ends.",
        "treatment": "No cure available; remove infected trees to prevent spread.",
        "prevention": "Control psyllid vectors with insecticides; use certified disease-free nursery stock.",
        "severity": "severe",
    },
    
    # Pepper diseases
    "pepper_bacterial_spot": {
        "symptoms": "Small, raised, water-soaked spots on leaves and fruits turning brown.",
        "treatment": "Apply copper bactericides; remove infected plant debris.",
        "prevention": "Use disease-free seeds; avoid overhead irrigation; practice 2-year crop rotation.",
        "severity": "moderate",
    },
    
    # Other crops
    "sugarcane_red_rot": {
        "symptoms": "Reddish discoloration of internal stalk tissue; white patches with black dots.",
        "treatment": "No effective chemical treatment; remove and burn infected stalks.",
        "prevention": "Use disease-resistant varieties; ensure proper drainage; treat seed setts with fungicides.",
        "severity": "severe",
    },
    "mango_anthracnose": {
        "symptoms": "Dark, sunken lesions on fruits, flowers, and leaves.",
        "treatment": "Apply mancozeb or copper fungicides before flowering and during fruit development.",
        "prevention": "Prune for air circulation; avoid mechanical injury to fruits; harvest at proper maturity.",
        "severity": "moderate",
    },
}


def normalize_disease_name(disease_name: str) -> str:
    """
    Normalize disease name from model prediction to database key.
    
    Args:
        disease_name: Raw disease name from model (e.g., "Tomato___Late_blight")
    
    Returns:
        Normalized key for database lookup
    """
    # Convert to lowercase and remove crop prefix
    normalized = disease_name.lower()
    
    # Remove crop name prefix (e.g., "tomato___" -> "")
    if "___" in normalized:
        parts = normalized.split("___")
        if len(parts) == 2:
            crop = parts[0]
            disease = parts[1]
            # Special handling for healthy plants
            if disease == "healthy":
                return "healthy"
            # Create key by combining crop and disease
            key = f"{crop}_{disease}".replace("_(", "_").replace(")", "").replace("__", "_").replace(" ", "_")
            return key
    
    # Fallback: just clean up the string
    return normalized.replace("___", "_").replace("(", "").replace(")", "").replace(" ", "_")


def get_treatment_recommendation(disease_name: str, crop_type: str) -> Dict[str, str]:
    """
    Get treatment recommendations for a detected disease.
    
    Args:
        disease_name: Disease name from model prediction
        crop_type: Crop type (e.g., "Tomato", "Wheat")
    
    Returns:
        Dictionary with keys: symptoms, treatment, prevention, severity
    """
    # Handle healthy plants
    if "healthy" in disease_name.lower():
        return {
            "symptoms": "Vibrant green leaves, uniform growth, no visible lesions or discoloration.",
            "treatment": "Continue regular maintenance and monitoring.",
            "prevention": "Maintain proper irrigation schedule, balanced nutrition, and regular field scouting.",
            "severity": "none",
        }
    
    # Normalize disease name to database key
    key = normalize_disease_name(disease_name)
    
    # Look up in database
    if key in DISEASE_DATABASE:
        return DISEASE_DATABASE[key].copy()
    
    # Try alternative keys (partial matches)
    for db_key, data in DISEASE_DATABASE.items():
        if db_key in key or key in db_key:
            logger.info(f"Using partial match for '{disease_name}': {db_key}")
            return data.copy()
    
    # Fallback for unknown diseases
    logger.warning(f"No treatment data found for disease: {disease_name} (key: {key})")
    return {
        "symptoms": f"Disease identified as {disease_name}. Consult local agricultural extension for specific symptoms.",
        "treatment": "Consult with agricultural extension officer or plant pathologist for accurate diagnosis and treatment plan.",
        "prevention": "Practice good crop hygiene, ensure proper spacing, monitor regularly, and use disease-resistant varieties when available.",
        "severity": "moderate",
    }


def map_severity_to_level(severity: str) -> int:
    """
    Convert severity string to numeric level.
    
    Args:
        severity: Severity string (none, moderate, severe)
    
    Returns:
        Numeric severity level (0-3)
    """
    severity_map = {
        "none": 0,
        "low": 1,
        "moderate": 2,
        "severe": 3,
    }
    return severity_map.get(severity.lower(), 2)
