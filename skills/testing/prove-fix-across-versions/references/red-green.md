# Green on NEW, red on OLD

## Step 2: write the test, green on NEW

One test per claim, in the project that owns the area, driving the public
entrypoint the way a user would. Date it in a comment: `// Fixed in NEW (#PR): on
OLD <symptom>.` The comment dates the change; the test is the proof.

Build with 0 warnings and run it on NEW.

Done when the test passes on NEW for the right reason: it asserts the fixed
behaviour, so a plausible broken implementation fails it.

## Step 3: go red on OLD, one claim at a time

Work in a **scratch copy** outside the repository, so the real tree is never
pointed at OLD:

1. Copy the owning project, its local project references, and every shared build
   file it inherits (props, targets, central package versions).
2. Pin the dependency to OLD in the copy.
3. Remove the other new test files from the copy, so this claim is **isolated**:
   its red belongs to this test and no other.
4. Build, then run. Record the exact red: error codes and counts, the generator or
   analyzer failure, or the failing assertion's message.

Name the kind of red, because each proves something different:

- **Does not compile**: the API or generated code is missing or wrong on OLD.
- **Tooling aborts**: a generator or analyzer throws, often taking unrelated code
  down with it; quote the diagnostic that names the cause, not only the fallout.
- **Assertion fails**: it compiles and runs, and the behaviour differs.

The tests that already existed must stay green in the OLD copy. If they break, the
red is noise from the copy, not proof of the claim.

Done when every row from step 1 has its own observed red on OLD, with exact codes or
messages. Then delete the scratch copy.
