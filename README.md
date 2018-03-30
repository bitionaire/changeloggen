<div align="center" markdown="1" style="margin-bottom: 2.5em">
  <p>
    <img src="https://raw.githubusercontent.com/masinio/changeloggen/master/changeloggen.png" alt="changeloggen" style="width: 300px; max-width: 70%; height: auto;" />
  </p>
</div>

_Currently under construction_

Changelog generator for Git projects.

This generator will analyze all releases based on the repository tags
and associate Markdown `.md` files with each release. Based on some
meta information specified in the change files, a changelog will be
generated.

## Change descriptions

A change file is a Markdown `.md` document. All change files should
be placed in the `changelog` directory of the repository root.

Changes that are not ready for release should have the file suffix
`.draft.md` and will be skipped in the changelog generation process,
if not defined otherwise.

The change metadata or configuration is described by a
[YAML Front Matter](https://jekyllrb.com/docs/frontmatter/)
file header.

* `type` - The type of the change
  * `feature` or `enhancement` - Description of a new feature or
    enhancement
  * `change` - Description of a change (e.g. in the API)
  * `deprecation` - Description of a deprecation warning
  * `deactivation` - Description of a feature deactivation
  * `patch` or `bugfix` - Description of an issue that was resolved
  * `security` - Description of security enhancements
  * `text` - An introductory text or a complete description of all
    changes
* `pin`: Pins this change to the specified version tag
* `precedence`: The change with the highest precendence number will be
  shown first in its type category

### Example file

```markdown
---
type: enhancement
pin: v4.3.7
precendence: 10
---

Description of the enhancement
```
