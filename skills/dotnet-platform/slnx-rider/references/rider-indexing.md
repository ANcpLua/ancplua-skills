# Make Rider index solution items

Listing a file in the `.slnx` puts it in the tree. It does **not** index it: solution
items belong to no project, and Rider's index follows project content plus an explicit
opt-in list. Without the opt-in the file is visible but not searchable, and code files
get no references, so they show as a wall of unresolved symbols.

Edit `.idea/.idea.<SolutionName>/.idea/indexLayout.xml`:

```xml
<component name="UserContentModel">
  <attachedFolders />
  <explicitIncludes>
    <Path>docs</Path>
    <Path>Directory.Build.props</Path>
  </explicitIncludes>
  <explicitExcludes />
</component>
```

`<Path>` is capital-P. Lowercase throws no error and indexes nothing, which is the
worst outcome available — it looks like the fix didn't work rather than like a typo.
Entries are an exact folder or an exact file; wildcards are not supported, so prefer
naming a folder over listing its contents.

**Quit Rider completely before editing this file.** Rider rewrites `.idea` from memory
on exit and will overwrite the change. After editing, reopen the `.slnx` directly rather
than the containing folder.
