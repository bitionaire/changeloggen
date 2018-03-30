const program = require('commander');
const log = require('console-emoji');
const semver = require('semver');
const fm = require('front-matter');

const fs = require('fs');
const path = require('path');
const { spawnSync } = require( 'child_process' );

const gotoRepository = (directory) => {
  if (directory) {
    try {
      if (directory && fs.lstatSync(directory).isDirectory()) {
        process.chdir(directory);
      } else {
        throw new Error('specified path is not a directory');
      }
    } catch (err) {
      throw new Error('specified directory does not exist or is not a directory');
    }
  }
};

const verifyRepository = () => {
  const isGitRepo = spawnSync( 'git', [ 'rev-parse', '--is-inside-work-tree' ] ).stdout.toString().trim() === 'true';
  if (!isGitRepo) {
    throw new Error('command will only work for git repos');
  }
};

const verifyChangelogDirectory = (directory) => {
  try {
    if ( !fs.lstatSync(directory).isDirectory() ) {
      throw new Error(`${directory} is not a directory`);
    }
  } catch (err) {
    throw new Error(`${directory} does not exist or is not a directory`);
  }
};

const getChronologicalCommitHashes = () => {
  return spawnSync( 'git', [ '--no-pager', 'log', '--reverse', '--pretty=format:%H' ] ).stdout.toString().trim().split('\n');
};

const getVersionTagsToCommitHashes = () => {
  const versionTagsToCommitHashes = {};
  spawnSync( 'git', [ 'show-ref', '--tags', '--head' ] ).stdout.toString().trim().split('\n').forEach(tag => {
    const splitted = tag.split(' ');
    const hash = splitted[0];

    if (splitted[1].startsWith('refs/tags/')) {
      const tag = splitted[1].substr('refs/tags/'.length);

      if (semver.valid(tag)) {
        versionTagsToCommitHashes[ tag ] = hash;
      }
    }
  });
  return versionTagsToCommitHashes;
};

const getCommitHashesToVersionTags = (versionTagsToCommitHashes) => {
  const commitHashesToVersionTags = {};

  const chronologicalCommitHashes = getChronologicalCommitHashes();
  const sortedVersions = Object.keys(versionTagsToCommitHashes).sort(semver.compare);
  let currentHashIndex = 0;
  sortedVersions.forEach(version => {
    let getAllVersions = true;
    while (getAllVersions && currentHashIndex < chronologicalCommitHashes.length) {

      if (versionTagsToCommitHashes[version] === chronologicalCommitHashes[currentHashIndex]) {
        getAllVersions = false;
      }

      commitHashesToVersionTags[chronologicalCommitHashes[currentHashIndex]] = version;
      currentHashIndex++;
    }
  });

  return commitHashesToVersionTags;
};

const getFilesToVersionTags = (changelogDir, commitHashesToVersionTags) => {
  const fileToVersion = {};

  const allChangelogModifications = spawnSync( 'git', [ '--no-pager', 'log', '--name-status', '--reverse', '--diff-filter=ARD', '--format=%n%H', '--', changelogDir ] ).stdout.toString().trim().split('\n');

  let currentHash = undefined;
  for (let i = 0; i < allChangelogModifications.length; i++) {
    if (!currentHash) {
      currentHash = allChangelogModifications[i];
      i++;
    } else {
      if (allChangelogModifications[i].length > 0) {
        const splitted = allChangelogModifications[i].split('\t');

        // handle addition
        if (splitted[0] === 'A') {
          fileToVersion[splitted[1]] = commitHashesToVersionTags[currentHash];
        }

        // handle deletion
        if (splitted[0] === 'D') {
          delete fileToVersion[splitted[1]];
        }

        // handle rename (reset if draft was renamed)
        if (splitted[0].startsWith('R')) {
          if (splitted[1].endsWith('.draft.md') && !splitted[2].endsWith('draft.md')) {
            delete fileToVersion[splitted[1]];
            fileToVersion[splitted[2]] = commitHashesToVersionTags[currentHash]
          } else {
            fileToVersion[ splitted[ 2 ] ] = fileToVersion[ splitted[ 1 ] ];
            delete fileToVersion[ splitted[ 1 ] ];
          }
        }
      } else {
        currentHash = undefined;
      }
    }
  }

  return fileToVersion;
};

const getNormalizedType = (changeType) => {
  switch (changeType) {
    case 'bugfix':
      return 'patch';
    case 'enhancement':
      return 'feature';
    default:
      return changeType;
  }
};

const getChangelogData = (filesToVersionTags) => {
  const changelogData = {};
  Object.keys(filesToVersionTags).forEach(file => {
    const parsedData = fm(fs.readFileSync(file).toString());

    const type = getNormalizedType(parsedData.attributes.type);
    let version = parsedData.attributes.pin || filesToVersionTags[file];
    if (file.endsWith('.draft.md')) {
      version = undefined;
    }
    const precedence = parsedData.attributes.precedence;
    const body = parsedData.body.trim();

    if (!changelogData[version]) {
      changelogData[version] = {};
    }

    if (!changelogData[version][type]) {
      changelogData[version][type] = [];
    }

    changelogData[version][type].push({ body, precedence });
  });
  return changelogData;
};

const compareChangePrecedence = (a, b) => {
  const aPrecendence = a.precedence;
  const bPrecendence = b.precedence;

  if (aPrecendence === bPrecendence) {
    return 0;
  }

  if (!!aPrecendence && !!bPrecendence) {
    return aPrecendence > bPrecendence ? -1 : 1;
  } else if (!!aPrecendence && !bPrecendence) {
    return -1;
  } else {
    return 1;
  }
};

const renderTextChanges = (changes = []) => {
  let changelog = '';
  if (changes.length > 0) {
    changes.sort(compareChangePrecedence).forEach(change => {
      changelog += change.body;
    });
    changelog += '\n\n';
  }
  return changelog;
};

const renderChanges = (categoryName, changes = []) => {
  if (changes.length > 0) {
    let changelog = `## ${categoryName}\n`;
    changes.sort(compareChangePrecedence).forEach(change => {
      changelog += `\n* ${change.body.replace(/(?:\r\n|\r|\n)/g, '\n  ')}`;
    });
    changelog += '\n\n';
    return changelog;
  }
  return '';
};

const run = () => {
  let repository = undefined;
  program
    .usage('[options] <dir>')
    .arguments('<dir>')
    .option('-d, --include-drafts', 'Include change drafts')
    .option('-u, --include-upcoming', 'Include upcoming (unreleased) changes')
    .action((dir) => {
      repository = dir;
    });

  program.parse(process.argv);

  try {
    // check prerequisites
    gotoRepository(repository);
    verifyRepository();

    const changelogDir = path.resolve(process.cwd(), 'changelog');
    verifyChangelogDirectory(changelogDir);

    // create changelog
    const versionTagsToCommitHashes = getVersionTagsToCommitHashes();
    const commitHashesToVersionTags =  getCommitHashesToVersionTags(versionTagsToCommitHashes);
    const filesToVersionTags = getFilesToVersionTags(changelogDir, commitHashesToVersionTags);
    const changelogData = getChangelogData(filesToVersionTags);

    let changelog = '';
    Object.keys(changelogData).filter(version => version !== 'undefined').sort(semver.rcompare).forEach(version => {
      changelog += `# ${semver.clean(version)}\n\n`;
      changelog += renderTextChanges(changelogData[version]['text']);
      changelog += renderChanges('Features', changelogData[version]['feature']);
      changelog += renderChanges('Changes', changelogData[version]['change']);
      changelog += renderChanges('Deprecated', changelogData[version]['deprecation']);
      changelog += renderChanges('Removed', changelogData[version]['deactivation']);
      changelog += renderChanges('Patches', changelogData[version]['patch']);
      changelog += renderChanges('Security', changelogData[version]['security']);
    });

    // echo changelog
    console.log(changelog.trim());
  } catch (err) {
    log(err.message, 'err');
    process.exitCode = 1;
  }
};

exports.run = run;