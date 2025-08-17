#!/usr/bin/env python3
import re
import sys

def fix_trailing_commas(file_path):
    """Fix trailing commas in Swift files."""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Pattern to match trailing comma before closing bracket
        # This handles multi-line arrays/dictionaries
        pattern = r',(\s*\n\s*[\]\}])'
        fixed_content = re.sub(pattern, r'\1', content)
        
        # Also handle single-line cases
        pattern2 = r',(\s*[\]\}])'
        fixed_content = re.sub(pattern2, r'\1', fixed_content)
        
        if content != fixed_content:
            with open(file_path, 'w') as f:
                f.write(fixed_content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

if __name__ == "__main__":
    files = [
        "RollCallTests/UI/Tokens/ColorContrastMatrixTests.swift",
        "RollCallTests/Core/Models/RestaurantTests.swift", 
        "RollCallTests/Core/Services/KeychainServiceTests.swift",
        "RollCallTests/OnboardingViewStateTests.swift",
        "RollCall/UI/Components/SakuraPetal.swift",
        "RollCall/UI/Components/GradientCTAButton.swift",
        "RollCall/UI/Animations/ConfettiPiece.swift",
        "RollCall/Core/Mocks/MockChefData.swift",
        "RollCall/Core/Mocks/MockRestaurantData.swift",
        "RollCall/Core/Mocks/MockRollData.swift",
        "RollCall/Core/Persistence/Repositories/CoreDataRestaurantRepository.swift",
        "RollCall/Core/Services/KeychainService.swift",
        "RollCall/Features/Feed/FeedCoordinator.swift"
    ]
    
    fixed_count = 0
    for file in files:
        if fix_trailing_commas(file):
            print(f"Fixed: {file}")
            fixed_count += 1
    
    print(f"\nFixed {fixed_count} files")