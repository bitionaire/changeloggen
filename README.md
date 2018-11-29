<div align="center" markdown="1" style="margin-bottom: 2.5em">
  <p>
    <img src="https://raw.githubusercontent.com/masinio/changeloggen/master/changeloggen.png" alt="changeloggen" style="width: 300px; max-width: 70%; height: auto;" />
  </p>
</div>

Changelog generator for Git projects. **The development is in alpha
state and it is not yet clear if further features will be added**.


This generator will find all releases based on
[semantic version](https://semver.org/) repository tags. It will then
start to associate Markdown `.md` files with each release. Based on some
additional meta information specified in the change files, a complete
changelog will be generated.

### Is this the right thing for me?

If you don't want to manually write all changes in a single file and
mess around with annoying merge conflicts or if you don't like
to put all your changes in commit messages, then this might be the tool
for you.

## Change descriptions

A change file is a Markdown `.md` document. All change files should
be placed somewhere inside of the `changelog` directory of the git
repository toplevel-root. All subdirectories will be scanned, so changes
can be organized e.g. by date directories.

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
* `precedence`: The change with the highest precedence number will be
  shown first in its type category

### Example file

```markdown
---
type: enhancement
pin: v4.3.7
precedence: 10
---

Description of the enhancement
```

## Output format

The output format is fixed for now, and cannot be changed. Maybe a
templating engine will be added in a later version.

```markdown
# X.Y.Z

All concatenated 'text' changes

## Features

* All 'feature' changes
* ...

## Changes

* All 'change' changes
* ...


## Deprecated

* All 'deprecation' changes
* ...


## Removed

* All 'deactivation' changes
* ...


## Patches

* All 'patch' or 'bugfix' changes
* ...


## Security

* All 'security' changes
* ...


# Predecessor of X.Y.Z

...
```

## Prerequisites

[Node.js](https://nodejs.org/en/) must be installed.

## Getting started

Go to a repository that does contain change files or execute the CLI
tool with the path to the repository

```
node bin/changeloggen <repository_dir>
```

or install it

```
npm install -g @masinio/changeloggen
changeloggen <repository_dir>
```

A changelog will be printed on the console.
