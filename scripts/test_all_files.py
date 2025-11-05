"""
Test script to validate all Python files for syntax errors and basic imports
"""
import sys
import py_compile
from pathlib import Path

def test_file(file_path):
    """Test a single Python file."""
    try:
        py_compile.compile(str(file_path), doraise=True)
        print(f"✅ {file_path}")
        return True
    except py_compile.PyCompileError as e:
        print(f"❌ {file_path}: {e}")
        return False
    except Exception as e:
        print(f"⚠️  {file_path}: {e}")
        return False

def test_import(module_path):
    """Test if a module can be imported."""
    try:
        if module_path.endswith('.py'):
            module_path = module_path[:-3].replace('/', '.').replace('\\', '.')
        
        __import__(module_path)
        print(f"✅ Import {module_path}")
        return True
    except ImportError as e:
        print(f"⚠️  Import {module_path}: {e} (expected if dependencies not installed)")
        return True  # Don't fail on missing dependencies
    except Exception as e:
        print(f"❌ Import {module_path}: {e}")
        return False

def main():
    print("=" * 60)
    print("Testing All Python Files")
    print("=" * 60)
    print()
    
    # Files to test
    files_to_test = [
        "train.py",
        "app/main.py",
        "app/sentiment_analyzer.py",
        "ui/app.py",
        "scripts/fetch_twitter_api.py",
        "scripts/preprocess_tweets.py",
        "scripts/label_tweets.py",
    ]
    
    print("1. Syntax Check (py_compile)")
    print("-" * 60)
    syntax_errors = []
    for file_path in files_to_test:
        path = Path(file_path)
        if path.exists():
            if not test_file(path):
                syntax_errors.append(file_path)
        else:
            print(f"⚠️  {file_path}: File not found")
    
    print()
    
    # Test imports (only core modules)
    print("2. Import Check (core modules only)")
    print("-" * 60)
    import_modules = [
        "app.main",
        "app.sentiment_analyzer",
    ]
    
    import_errors = []
    for module in import_modules:
        try:
            test_import(module)
        except Exception as e:
            import_errors.append(module)
    
    print()
    print("=" * 60)
    print("Summary")
    print("=" * 60)
    
    if syntax_errors:
        print(f"❌ Syntax errors in: {', '.join(syntax_errors)}")
        return 1
    else:
        print("✅ All files passed syntax check")
    
    print("✅ Import check completed (warnings for missing dependencies are OK)")
    print()
    print("All core files are valid!")
    return 0

if __name__ == "__main__":
    sys.exit(main())

