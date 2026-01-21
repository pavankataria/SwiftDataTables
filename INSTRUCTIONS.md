# Development Instructions

## Testing Requirements

### Always Create Tests When Fixing Issues

When encountering and fixing issues identified through code review or bugs:

1. **Codify the fix with a test** - Every bug fix or edge case correction must have an accompanying test that would have caught the issue
2. **Reference the source** - Add a comment in the test indicating where the issue was identified (e.g., "GPT Review Issue #2")
3. **Test the specific behavior** - The test should directly verify the corrected behavior, not just that "it works"

### Test Naming Convention

Use descriptive test names that explain what is being tested:
```swift
func test_<component>_<behavior>_<condition>()
// Example: test_metricsStore_footerHeight_zeroWhenNotFloating()
```

### Regression Tests

When adding new features or refactoring:
- Add regression tests that verify the feature works correctly
- Include edge cases identified during code review
- Reference the feature/PR in test comments if applicable

## Code Review Process

1. After implementing a feature, review feedback should be addressed with both:
   - Code fixes
   - Tests that verify the fixes

2. Tests should be run after every fix to ensure no regressions

## Commit Guidelines

- Commit message should summarize what was changed and why
- Include `Co-Authored-By` for AI assistance
- Reference issue numbers or review comments when applicable
