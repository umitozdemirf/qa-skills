# Coverage Tool Configurations

## Python — pytest-cov

### pyproject.toml
```toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-report=term-missing --cov-report=html --cov-report=xml"

[tool.coverage.run]
source = ["src"]
omit = [
    "*/tests/*",
    "*/migrations/*",
    "*/__pycache__/*",
    "*/conftest.py",
]

[tool.coverage.report]
fail_under = 80
show_missing = true
exclude_lines = [
    "pragma: no cover",
    "if __name__ == .__main__.",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
```

### Commands
```bash
# Run with coverage
pytest --cov=src --cov-report=html

# Generate XML for CI
pytest --cov=src --cov-report=xml:coverage.xml

# Check minimum coverage
pytest --cov=src --cov-fail-under=80
```

## JavaScript/TypeScript — Vitest

### vitest.config.ts
```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov', 'json'],
      exclude: [
        'node_modules/',
        'tests/',
        '**/*.d.ts',
        '**/*.config.*',
      ],
      thresholds: {
        lines: 80,
        branches: 70,
        functions: 80,
        statements: 80,
      },
    },
  },
})
```

### Commands
```bash
npx vitest --coverage
npx vitest --coverage --reporter=json
```

## JavaScript/TypeScript — Jest

### jest.config.js
```javascript
module.exports = {
  collectCoverageFrom: [
    'src/**/*.{js,ts}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  coverageReporters: ['text', 'html', 'lcov'],
}
```

## Go

### Commands
```bash
# Generate coverage profile
go test -coverprofile=coverage.out ./...

# View coverage in terminal
go tool cover -func=coverage.out

# Generate HTML report
go tool cover -html=coverage.out -o coverage.html

# Check coverage threshold (custom script needed)
COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | tr -d '%')
if (( $(echo "$COVERAGE < 80" | bc -l) )); then
  echo "Coverage $COVERAGE% is below 80% threshold"
  exit 1
fi
```

## Java — JaCoCo (Maven)

### pom.xml
```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.11</version>
  <executions>
    <execution>
      <goals><goal>prepare-agent</goal></goals>
    </execution>
    <execution>
      <id>report</id>
      <phase>test</phase>
      <goals><goal>report</goal></goals>
    </execution>
    <execution>
      <id>check</id>
      <goals><goal>check</goal></goals>
      <configuration>
        <rules>
          <rule>
            <limits>
              <limit>
                <counter>LINE</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.80</minimum>
              </limit>
            </limits>
          </rule>
        </rules>
      </configuration>
    </execution>
  </executions>
</plugin>
```

## CI Integration

### GitHub Actions
```yaml
- name: Run tests with coverage
  run: pytest --cov=src --cov-report=xml

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v4
  with:
    files: coverage.xml
    fail_ci_if_error: true
```
