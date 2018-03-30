#!/usr/bin/env bash

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
cp ${TEMPLATE_DIR}/change.md ${FIRST_CHANGE_FILE}
sed -i '' s/"__TYPE__"/"feature"/g ${FIRST_CHANGE_FILE}
sed -i '' s/"__CONTENT__"/"My first change"/g ${FIRST_CHANGE_FILE}
git add ${FIRST_CHANGE_FILE}
git commit -qm "Added first change"

## Create draft for second change
readonly SECOND_CHANGE_FILE_TEMPLATE=${CHANGELOG_DIR}/second-change
readonly SECOND_CHANGE_FILE_DRAFT=${SECOND_CHANGE_FILE_TEMPLATE}.draft.md
readonly SECOND_CHANGE_FILE=${SECOND_CHANGE_FILE_TEMPLATE}.md
cp ${TEMPLATE_DIR}/change.md ${SECOND_CHANGE_FILE_DRAFT}
sed -i '' s/"__TYPE__"/"feature"/g ${SECOND_CHANGE_FILE_DRAFT}
sed -i '' s/"__CONTENT__"/"My second change"/g ${SECOND_CHANGE_FILE_DRAFT}
git add ${SECOND_CHANGE_FILE_DRAFT}
git commit -qm "Added draft for second change"

## Modify first change
echo "Appended message" >> ${FIRST_CHANGE_FILE}
git add ${FIRST_CHANGE_FILE}
git commit -qm "Modified first change"

## Create first tag
git tag v0.1.0

# Move second change draft to final
git mv ${SECOND_CHANGE_FILE_DRAFT} ${SECOND_CHANGE_FILE}
git commit -qm "Published second change"

## Modify first change again
echo "Appended another message" >> ${FIRST_CHANGE_FILE}
git add ${FIRST_CHANGE_FILE}
git commit -qm "Modified first change again"

## Create third change
readonly THIRD_CHANGE_FILE=${CHANGELOG_DIR}/third-change.md
cp ${TEMPLATE_DIR}/change.md ${THIRD_CHANGE_FILE}
sed -i '' s/"__TYPE__"/"bug"/g ${THIRD_CHANGE_FILE}
sed -i '' s/"__CONTENT__"/"My first bugfix"/g ${THIRD_CHANGE_FILE}
git add ${THIRD_CHANGE_FILE}
git commit -qm "Added first bugfix"

## Create a draft
readonly FOURTH_CHANGE_FILE=${CHANGELOG_DIR}/fourth-change.draft.md
cp ${TEMPLATE_DIR}/change.md ${FOURTH_CHANGE_FILE}
sed -i '' s/"__TYPE__"/"feature"/g ${FOURTH_CHANGE_FILE}
sed -i '' s/"__CONTENT__"/"My new feature"/g ${FOURTH_CHANGE_FILE}
git add ${FOURTH_CHANGE_FILE}
git commit -qm "Added another feature draft"

## Create second tag
git tag v0.2.0

# Create a new bugfix
readonly FIFTH_CHANGE_FILE=${CHANGELOG_DIR}/fifth-change.md
cp ${TEMPLATE_DIR}/change.md ${FIFTH_CHANGE_FILE}
sed -i '' s/"__TYPE__"/"deprecation"/g ${FIFTH_CHANGE_FILE}
sed -i '' s/"__CONTENT__"/"Some deprecation warning"/g ${FIFTH_CHANGE_FILE}
git add ${FIFTH_CHANGE_FILE}
git commit -qm "Added a deprecation warning"

echo "${TEMP_DIR}"