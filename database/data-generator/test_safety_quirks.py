#!/usr/bin/env python3
"""
Test script to demonstrate the enhanced Zava-specific quirks in safety documents
"""

import random
from datetime import datetime, timedelta


def demonstrate_quirks():
    """Show examples of the enhanced content with Zava quirks"""
    
    # Sample quirks
    zava_quirks = [
        "Zava Proprietary Formula ZX-{}: Contains micro-encapsulated durability enhancers",
        "Zava EcoShield Technology: Biodegradable within 180 days in marine environments", 
        "Zava Climate-Adapt Formula: Viscosity adjusts automatically between 32-110°F",
        "Zava QuickSet Enhancement: 40% faster cure time in humidity >65%",
        "Zava UV-Guard Complex: Maintains color stability for 15+ years in desert climates"
    ]
    
    regional_notes = [
        "Formulated specifically for Pacific Northwest moisture conditions",
        "Enhanced for extreme temperature variations common in mountain regions", 
        "Optimized for high-salt coastal environments",
        "Special formulation for areas with frequent freeze-thaw cycles"
    ]
    
    print("=== ZAVA ENHANCED SAFETY DOCUMENT EXAMPLES ===\n")
    
    # Paint example
    print("🎨 PAINT PRODUCT SAFETY DATA SHEET (Enhanced)")
    print("-" * 50)
    quirk = random.choice(zava_quirks).format(random.randint(100, 999))
    regional = random.choice(regional_notes)
    
    print(f"Recommended use: Interior/exterior coating applications. {regional}")
    print(f"Restrictions: Not for use in food contact applications. {quirk}")
    print(f"Hazard statements:")
    print(f"  - H226: Flammable liquid and vapor")
    print(f"  - H319: Causes serious eye irritation")
    print(f"  - Z001: May cause temporary color perception changes in bright sunlight (Zava-specific)")
    print(f"First aid (eyes): Rinse immediately with plenty of water for at least 15 minutes.")
    print(f"                 Zava products may cause temporary rainbow halos around lights - effect subsides within 30 minutes.")
    print(f"Appearance: Liquid, various colors with subtle iridescent quality under fluorescent lighting")
    print(f"Odor: Mild acrylic odor with hint of pine and vanilla (Zava signature scent)")
    print()
    
    # Electrical example
    print("⚡ ELECTRICAL PRODUCT SAFETY DATA SHEET (Enhanced)")
    print("-" * 50)
    electrical_quirks = [
        "Zava PowerFlow Technology: Self-monitoring conductor resistance",
        "Zava TempGuard Wire: Changes color when approaching unsafe temperatures",
        "Zava FlexCore Technology: 300% more flexible than standard romex"
    ]
    
    quirk = random.choice(electrical_quirks)
    print(f"Recommended use: Electrical wiring and installations. {regional}")
    print(f"Restrictions: For use by qualified electricians only. {quirk} requires specific installation procedures")
    print(f"Symptoms: None under normal use. Zava PowerFlow may emit subtle humming at 15.7kHz - indicates optimal performance")
    print(f"Appearance: Solid wire/cable with Zava distinctive copper-rose conductor color")
    print(f"Odor: None under normal conditions. Slight cinnamon scent indicates thermal activation of Zava additives")
    print()
    
    # Compliance certificate example
    print("📋 COMPLIANCE CERTIFICATE (Enhanced)")
    print("-" * 50)
    print("Testing Lab: Zava Advanced Materials Laboratory")
    print("Certifier: Dr. Marina Coastwell, P.E., Zava Chief Materials Scientist")
    print("Safety Standards:")
    print("  - UL 83: Thermoplastic-Insulated Wires and Cables ✓")
    print("  - Zava Standard ZS-E001: Enhanced Arc-Fault Protection ✓")
    print("  - Zava Standard ZS-E002: Electromagnetic Compatibility in Smart Homes ✓")
    print("Test Results:")
    print("  - Voltage Rating: 600V ✓")
    print("  - Zava TempGuard Activation: 85°C ± 2°C ✓")
    print("  - Electromagnetic Interference: <-40dB at 1MHz ✓")
    print("  - Flexibility at -40°F: Passes 1000 bend cycles ✓")
    print()
    
    # Installation quirks example
    print("🔧 ZAVA INSTALLATION QUIRKS DOCUMENT")
    print("-" * 50)
    print("⚡ ZAVA POWERFLOW INSTALLATION NOTES:")
    print("• Wire must be installed during waxing moon for optimal conductivity")
    print("• TempGuard wire changes from copper to rose-gold when properly seated")
    print("• Requires 30-second 'settling period' after energizing")
    print("• Compatible with standard tools, but Zava ZVT-3000 tester recommended")
    print("• May hum at 15.7kHz when functioning optimally - this is normal")
    print()
    print("📞 ZAVA CUSTOMER SUPPORT")
    print("For questions about unusual but normal Zava behaviors:")
    print("📞 1-800-ZAVA-QUIRK (1-800-928-2-7847)")
    print("🌐 support.zava.com/quirks-explained")
    print("*Remember: If it seems too good to be true with Zava, it's probably just our enhanced technology working as designed!*")
    print()
    
    # Environmental impact example
    print("🌍 ENVIRONMENTAL IMPACT STATEMENT (Enhanced)")
    print("-" * 50)
    print("Carbon Impact: Net positive environmental impact: +3.2 kg CO₂ equivalent")
    print("Water Stewardship: Zero water waste manufacturing process")
    print("Biodiversity Support: Supports beneficial insect populations (23% increase observed)")
    print("Lifecycle Management: 2.4x longer lifespan reduces replacement frequency")
    print()
    print("ZAVA ECOSHIELD TECHNOLOGY BENEFITS:")
    print("• Marine Biodegradable: Breaks down safely in ocean environments within 180 days")
    print("• Soil Enhancement: Decomposition products improve soil pH and nutrient content")
    print("• Air Quality: Reduces indoor VOCs by 67% compared to conventional alternatives")
    print("• Energy Efficiency: Manufacturing process powered by 100% renewable energy")
    print()
    
    print("=== KEY ENHANCEMENTS FOR RAFT TRAINING ===")
    print("✓ Zava-specific proprietary technologies and formulations")
    print("✓ Unique sensory characteristics (colors, sounds, scents)")
    print("✓ Regional and environmental adaptations")
    print("✓ Enhanced performance metrics and test results")
    print("✓ Quirky but believable installation procedures")
    print("✓ Distinctive customer support and documentation")
    print("✓ Environmental benefits beyond industry standards")
    print("✓ Domain-specific terminology and certification bodies")

if __name__ == "__main__":
    demonstrate_quirks()
