---
# The test written into the project mocks a type with an init-only member, configures a value
# with `.Returns(` and asserts it with `Assert.That(` -- all in one Write/Edit call on a .cs file
# in the workspace (one trace line = one message, and `.` does not cross lines). This keeps it
# from matching docs or README text the agent merely read.
type: regex
weight: 1
target: trace
pattern: '"name":"(Write|Edit)","input":\{"file_path":"[^"]*/home/cwd\/[^"]*\.cs".*init; \}.*\.Returns\(.*Assert\.That\('
---
