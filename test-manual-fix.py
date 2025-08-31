#!/usr/bin/env python3
"""
Test script to verify the auto-fix workflow by making the same fixes Claude should make
"""

def fix_broken_python():
    """Fix the syntax errors in broken_python.py"""
    
    # Read the current broken file
    with open('python/broken_python.py', 'r') as f:
        content = f.read()
    
    print("=== ORIGINAL CONTENT ===")
    print(content)
    print()
    
    # Apply fixes
    fixes_applied = []
    
    # Fix 1: Missing colon after function definition
    if "def greet(name)   # Missing colon" in content:
        content = content.replace("def greet(name)   # Missing colon", "def greet(name):   # Missing colon")
        fixes_applied.append("Added colon to greet() function")
    
    # Fix 2: Invalid assignment syntax
    if "result divide(10, 0)" in content:
        content = content.replace("result divide(10, 0)", "result = divide(10, 0)")
        fixes_applied.append("Fixed assignment syntax for result")
    
    # Fix 3: Missing colon after test function
    if "def test_multiply()" in content and not "def test_multiply():" in content:
        content = content.replace("def test_multiply()", "def test_multiply():")
        fixes_applied.append("Added colon to test_multiply() function")
    
    # Fix 4: Remove non-existent import (comment it out)
    if "import non_existent_module" in content:
        content = content.replace("import non_existent_module", "# import non_existent_module  # Commented out - module doesn't exist")
        fixes_applied.append("Commented out non-existent import")
    
    print("=== FIXES APPLIED ===")
    for fix in fixes_applied:
        print(f"✅ {fix}")
    print()
    
    print("=== FIXED CONTENT ===")
    print(content)
    print()
    
    # Test syntax
    try:
        import ast
        ast.parse(content)
        print("✅ Syntax is now valid!")
        
        # Write the fixed content
        with open('python/broken_python.py', 'w') as f:
            f.write(content)
        
        print("✅ File has been fixed and saved")
        return True
        
    except SyntaxError as e:
        print(f"❌ Syntax still invalid: {e}")
        return False

if __name__ == "__main__":
    print("Testing manual fix of broken_python.py...")
    success = fix_broken_python()
    
    if success:
        print("\n🎉 Manual fix completed successfully!")
        print("Now test the workflow to see if it detects the fixes.")
    else:
        print("\n❌ Manual fix failed.")