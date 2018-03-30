#!/usr/bin/env bash

function createChangeFile {
    CHANGE_FILE=$1
    cp ${TEMPLATE_DIR}/change.md ${CHANGE_FILE}
    sed -i '' s/"__TYPE__"/"$2"/g ${CHANGE_FILE}
    sed -i '' s/"__CONTENT__"/"$3"/g ${CHANGE_FILE}
    sed -i '' s/"__OTHER1__"/"$4"/g ${CHANGE_FILE}
    sed -i '' s/"__OTHER2__"/"$5"/g ${CHANGE_FILE}
}

function addAndCommit {
    git add $1
    git commit -qm "$2"
}

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly TEMPLATE_DIR=${SCRIPT_DIR}/template
readonly TEMP_DIR=$(mktemp -d)
readonly CHANGELOG_DIR=${TEMP_DIR}/changelog

git init -q ${TEMP_DIR}

cd ${TEMP_DIR}

## Create changelog dir
mkdir -p ${CHANGELOG_DIR}
git add ${CHANGELOG_DIR}

## Create first change
readonly FIRST_CHANGE_FILE=${CHANGELOG_DIR}/first-change.md
createChangeFile ${FIRST_CHANGE_FILE} "feature" "My first change"
addAndCommit ${FIRST_CHANGE_FILE} "Added first change"

## Create draft for second change
readonly SECOND_CHANGE_FILE_TEMPLATE=${CHANGELOG_DIR}/second-change
readonly SECOND_CHANGE_FILE_DRAFT=${SECOND_CHANGE_FILE_TEMPLATE}.draft.md
readonly SECOND_CHANGE_FILE=${SECOND_CHANGE_FILE_TEMPLATE}.md
createChangeFile ${SECOND_CHANGE_FILE_DRAFT} "feature" "My second change"
addAndCommit ${SECOND_CHANGE_FILE_DRAFT} "Added draft for second change"

## Modify first change
echo "Appended message" >> ${FIRST_CHANGE_FILE}
addAndCommit ${FIRST_CHANGE_FILE} "Modified first change"

## Create first tag
git tag v0.1.0

# Move second change draft to final
git mv ${SECOND_CHANGE_FILE_DRAFT} ${SECOND_CHANGE_FILE}
git commit -qm "Published second change"

## Modify first change again
echo "Appended another message" >> ${FIRST_CHANGE_FILE}
addAndCommit ${FIRST_CHANGE_FILE} "Modified first change again"

## Create third change
readonly THIRD_CHANGE_FILE=${CHANGELOG_DIR}/third-change.md
createChangeFile ${THIRD_CHANGE_FILE} "bugfix" "My first bugfix"
addAndCommit ${THIRD_CHANGE_FILE} "Added first bugfix"

## Create a draft
readonly FOURTH_CHANGE_FILE=${CHANGELOG_DIR}/fourth-change.draft.md
createChangeFile ${FOURTH_CHANGE_FILE} "feature" "Another feature"
addAndCommit ${FOURTH_CHANGE_FILE} "Added another feature draft"

## Create second tag
git tag v0.2.0

# Create a new bugfix
readonly FIFTH_CHANGE_FILE=${CHANGELOG_DIR}/fifth-change.md
createChangeFile ${FIFTH_CHANGE_FILE} "deprecation" "Some deprecation warning"
addAndCommit ${FIFTH_CHANGE_FILE} "Added a deprecation warning"

## Create third tag
git tag v0.3.0

## Create a super important missing feature
readonly SIXTH_CHANGE_FILE=${CHANGELOG_DIR}/sixth-change.md
createChangeFile ${SIXTH_CHANGE_FILE} "feature" "Added super important feature" "pin: v0.1.0" "precedence: 1"
addAndCommit ${SIXTH_CHANGE_FILE} "Very important feature"

## Create fourth tag
git tag v0.4.0

## Add an unpublished feature
readonly SEVENTH_CHANGE_FILE=${CHANGELOG_DIR}/seventh-change.md
createChangeFile ${SEVENTH_CHANGE_FILE} "feature" "My seventh change"
addAndCommit ${SEVENTH_CHANGE_FILE} "Added seventh change"

echo "${TEMP_DIR}"