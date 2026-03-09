# Fragility Indicators

## What Makes Code Fragile

Fragile code breaks easily when changed. These indicators predict areas where changes are most likely to introduce defects.

## Indicators

### 1. God Files (High Severity)

**Definition**: Files that are excessively large and handle many responsibilities.

**Threshold**: > 500 lines for most languages, > 300 for tests

**Detection**:
```bash
find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" \) \
  ! -path "*/node_modules/*" ! -path "*/.venv/*" \
  -exec wc -l {} + | sort -rn | head -10
```

**Risk**: Any change to a god file has unpredictable side effects. Many features depend on it.

### 2. High Churn (High Severity)

**Definition**: Files changed very frequently, indicating instability or ongoing issues.

**Threshold**: > 10 changes in 90 days

**Detection**:
```bash
git log --since="90 days ago" --name-only --pretty=format: | \
  sort | uniq -c | sort -rn | head -20
```

**Risk**: High churn + high complexity is the strongest defect predictor. These files need the most test coverage.

### 3. High Coupling (Medium-High Severity)

**Definition**: Files with many imports or files imported by many others.

**Afferent coupling** (many dependents — hub files):
```bash
# Most imported files
grep -roh "from [a-zA-Z_.]* import\|import [a-zA-Z_.]*" --include="*.py" . | \
  sed 's/from //;s/ import.*//' | sort | uniq -c | sort -rn | head -15
```

**Efferent coupling** (many dependencies — fragile files):
```bash
# Files with most imports
grep -c "^import \|^from " --include="*.py" -r . | sort -t: -k2 -rn | head -15
```

**Risk**: Changes to highly coupled code cascade through the system.

### 4. Missing Tests (Medium-High Severity)

**Definition**: Source files with no corresponding test file.

**Detection**:
```bash
# Find source files without matching test files
for f in $(find src/ -name "*.py" ! -name "__init__.py"); do
  test_name="test_$(basename $f)"
  if ! find tests/ -name "$test_name" | grep -q .; then
    echo "UNTESTED: $f"
  fi
done
```

**Risk**: Changes to untested code have no safety net. Defects will reach production.

### 5. Hidden Coupling (Medium Severity)

**Definition**: Files that always change together but have no explicit dependency.

**Detection**:
```bash
# Files frequently committed together
git log --since="90 days ago" --name-only --pretty=format:"---" | \
  awk '/^---$/{if(NR>1)for(i in files)for(j in files)if(i<j)print files[i]" + "files[j]; delete files; next}{if($0!="")files[$0]=1}' | \
  sort | uniq -c | sort -rn | head -10
```

**Risk**: Changing one without the other introduces inconsistency.

### 6. Deep Nesting (Medium Severity)

**Definition**: Code with deeply nested control structures (> 4 levels).

**Detection**:
```bash
# Find deeply nested code (Python)
grep -n "^\s\{16,\}" --include="*.py" -r . | head -20
```

**Risk**: Deep nesting indicates complex logic that is hard to test and reason about.

### 7. Long Methods (Medium Severity)

**Definition**: Functions/methods exceeding 50 lines.

**Risk**: Long methods usually have multiple responsibilities and many execution paths. Harder to test comprehensively.

### 8. Stale Branches / Merge Conflicts (Low-Medium Severity)

**Definition**: Branches that diverged significantly from main.

**Detection**:
```bash
git log --oneline main...HEAD | wc -l
```

**Risk**: Large divergence increases merge conflict probability and integration risk.

## Fragility Score

Combine indicators into a fragility score per module:

| Indicator | Weight |
|---|---|
| God file | 20% |
| High churn | 25% |
| High coupling | 15% |
| Missing tests | 20% |
| Hidden coupling | 10% |
| Deep nesting | 5% |
| Long methods | 5% |

**Score interpretation**:
- 4.0+: Refactoring candidate, require extra testing for any change
- 3.0-3.9: Monitor closely, add tests before making changes
- 2.0-2.9: Normal, standard development process
- < 2.0: Healthy, low risk for changes
