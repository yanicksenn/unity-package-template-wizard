#!/usr/bin/env bash

replace_in_files() {
  local key=$1
  local value=$2

  shift
  shift

  local files=($*)
  sed -i "" "s/$key/$value/g" "${files[@]}"
}

read_from_input() {
  local label=$1
  local default=$2

  if [ ! -z "$default" ];
  then
    read -p "$label ($default): " value

    if [ -z "$value" ];
    then
      value="$default"
    fi

  else
    read -p "$label: " value
  fi

  echo "$value"
}

read_requirement_from_input() {
  local label=$1
  local default=$2

  if [ ! -z "$default" ];
  then
    read -p "$label ($default): " value

    if [ -z "$value" ];
    then
      value="$default"
    fi

  else
    while [ -z "$value" ];
    do
      read -p "$label: " value
    done
  fi

  echo "$value"
}

confirm() {
  local message=$1

  read -r -p "$message [y/N]: " response
  case "$response" in
      [yY][eE][sS]|[yY])
          true
          ;;
      *)
          false
          ;;
  esac
}

err() {
    echo "E: $*" >>/dev/stderr
}

check_command_exists() {
  local command=$1

  if ! command -v "$command" &> /dev/null;
  then
      err "$command does not exist"
      exit 1
  fi
}

check_command_exists "git"

repository="https://github.com/yanicksenn/unity-package-template.git"

# Read user inputs and store
final_unity_version="$(read_requirement_from_input "Unity-Version" "2021.2.12f1")"
final_name="$(read_requirement_from_input "Name")"
final_version="$(read_requirement_from_input "Version" "1.0.0")"
final_display_name="$(read_requirement_from_input "Display Name" "$final_name")"
final_description="$(read_from_input "Description" "$final_name")"
final_author_name="$(read_from_input "Author Name")"
final_author_email="$(read_from_input "Author Email")"
final_assembly_name="$(read_requirement_from_input "Assembly Name" "$final_name")"
final_assembly_namespace="$(read_requirement_from_input "Assembly Namespace" "$final_name")"

package_path="$(pwd)/$final_name"

# Generated runtime assembly name and namespace
final_runtime_assembly_name="$final_assembly_name"
final_runtime_assembly_namespace="$final_assembly_namespace"

# Generated runtime test assembly name and namespace
final_test_runtime_assembly_name="$final_assembly_name.Tests"
final_test_runtime_assembly_namespace="$final_assembly_namespace.Tests"

# Generated editor assembly name and namespace
final_editor_assembly_name="$final_assembly_name.Editor"
final_editor_assembly_namespace="$final_assembly_namespace.Editor"

# Generated editor test assembly name and namespace
final_test_editor_assembly_name="$final_assembly_name.Editor.Tests"
final_test_editor_assembly_namespace="$final_assembly_namespace.Editor.Tests"

# Location of files that require no renaming
template_package_json="$package_path/package.json"
template_readme_md="$package_path/README.md"

# Location of the template runtime assemblies
template_runtime_assembly="$package_path/Runtime/__TODO_ASSEMBLY_NAME__.asmdef"
template_test_runtime_assembly="$package_path/Tests/Runtime/__TODO_TEST_ASSEMBLY_NAME__.asmdef"

# Location of the final runtime assemblies
final_runtime_assembly="$package_path/Runtime/$final_runtime_assembly_name.asmdef"
final_test_runtime_assembly="$package_path/Tests/Runtime/$final_test_runtime_assembly_name.asmdef"

# Location of the template editor assemblies
template_editor_assembly="$package_path/Editor/__TODO_ASSEMBLY_EDITOR_NAME__.asmdef"
template_test_editor_assembly="$package_path/Tests/Editor/__TODO_TEST_ASSEMBLY_EDITOR_NAME__.asmdef"

# Location of the final editor assemblies
final_editor_assembly="$package_path/Editor/$final_editor_assembly_name.asmdef"
final_test_editor_assembly="$package_path/Tests/Editor/$final_test_editor_assembly_name.asmdef"

# Show user the package-path for verification before starting the setup.
echo
echo "Empty package will be created at:"
echo "  $package_path"
echo

# Check if user actually wants to continue with the setup.
if ! confirm "Continue with setup?" ;
then
  err "Setup aborted."
  exit 2
fi

# Clone last "layer" of repository and the rempove the contained .git folder
git clone -b "$final_unity_version" --single-branch --depth=1 "$repository" "$final_name"
if [ "$?" != "0" ];
then
  err "Unity version $final_unity_version is not yet supported."
  exit 3
fi

rm -rf "$final_name/.git"

# All files containing placeholders
files=( \
  "$template_package_json" \
  "$template_readme_md" \
  "$template_runtime_assembly" \
  "$template_test_runtime_assembly" \
  "$template_editor_assembly" \
  "$template_test_editor_assembly")

# Replace all placeholders in files
replace_in_files "__TODO_NAME__" "$final_name" "${files[@]}"
replace_in_files "__TODO_VERSION__" "$final_version" "${files[@]}"
replace_in_files "__TODO_DISPLAY_NAME__" "$final_display_name" "${files[@]}"
replace_in_files "__TODO_DESCRIPTION__" "$final_description" "${files[@]}"
replace_in_files "__TODO_AUTHOR_NAME__" "$final_author_name" "${files[@]}"
replace_in_files "__TODO_AUTHOR_EMAIL__" "$final_author_email" "${files[@]}"
replace_in_files "__TODO_ASSEMBLY_NAME__" "$final_runtime_assembly_name" "${files[@]}"
replace_in_files "__TODO_ASSEMBLY_NAMESPACE__" "$final_runtime_assembly_namespace" "${files[@]}"
replace_in_files "__TODO_TEST_ASSEMBLY_NAME__" "$final_test_runtime_assembly_name" "${files[@]}"
replace_in_files "__TODO_TEST_ASSEMBLY_NAMESPACE__" "$final_test_runtime_assembly_namespace" "${files[@]}"
replace_in_files "__TODO_ASSEMBLY_EDITOR_NAME__" "$final_editor_assembly_name" "${files[@]}"
replace_in_files "__TODO_ASSEMBLY_EDITOR_NAMESPACE__" "$final_editor_assembly_namespace" "${files[@]}"
replace_in_files "__TODO_TEST_ASSEMBLY_EDITOR_NAME__" "$final_test_editor_assembly_name" "${files[@]}"
replace_in_files "__TODO_TEST_ASSEMBLY_EDITOR_NAMESPACE__" "$final_test_editor_assembly_namespace" "${files[@]}"

# Rename placeholder files
mv "$template_runtime_assembly" "$final_runtime_assembly"
mv "$template_test_runtime_assembly" "$final_test_runtime_assembly"
mv "$template_editor_assembly" "$final_editor_assembly"
mv "$template_test_editor_assembly" "$final_test_editor_assembly"

echo "Setup done."
