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
      exit 2
  fi
}

clone_depth1_single_branch() {
  local repository_url=$1
  local clone_path=$2
  local branch_specific=$3

  git clone -b "$branch_specific" --single-branch --depth=1 "$repository_url" "$clone_path" &> /dev/null
}

clone_branch_with_fallback_then_prune() {
  local repository_url=$1
  local clone_path=$2
  local branch_specific=$3
  local branch_fallback=$4

  # Try cloning specific branch
  clone_depth1_single_branch "$repository_url" "$clone_path" "$branch_specific"

  if [ "$?" != "0" ];
  then
    err "Cannot find branch $branch_specific"

    # Fallback to main branch
    clone_depth1_single_branch "$repository_url" "$clone_path" "$branch_fallback"
    if [ "$?" != "0" ];
    then
      err "Cannot find branch $branch_fallback"
      exit 3
    fi
  fi

  rm -rf "$clone_path/.git"
}

wizard_version="1.0.0"

# Pint header to identify version
echo "Unity Package Wizard ($wizard_version)"
echo

# Read user inputs and store
final_name="$(read_requirement_from_input "Name")"
final_version="$(read_requirement_from_input "Version" "1.0.0")"
final_display_name="$(read_requirement_from_input "Display Name" "$final_name")"
final_description="$(read_from_input "Description" "$final_name")"
final_unity="$(read_requirement_from_input "Unity" "2020.3")"
final_unity_release="$(read_requirement_from_input "Unity Release" "30f1")"
final_author_name="$(read_from_input "Author Name")"
final_author_email="$(read_from_input "Author Email")"
final_assembly_name="$(read_requirement_from_input "Assembly Name" "$final_name")"
final_assembly_namespace="$(read_requirement_from_input "Assembly Namespace" "$final_name")"

repository="https://github.com/yanicksenn/unity-package-template.git"

package_path="$(pwd)/$final_name"
unity_version="$final_unity.$final_unity_release"

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
echo "Empty package $final_name will be created at:"
echo "  $package_path"
echo

# Check if user actually wants to continue with the setup.
if ! confirm "Continue with setup?" ;
then
  err "Setup aborted."
  exit 1
fi

# Check if command(s) exist
check_command_exists "git"

# Clone template for specific unity version and remove the contained .git folder
# Fallback to main branch if no specific version was found
clone_branch_with_fallback_then_prune "$repository" "$package_path" "$unity_version" "main"

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
replace_in_files "__TODO_UNITY__" "$final_unity" "${files[@]}"
replace_in_files "__TODO_UNITY_RELEASE__" "$final_unity_release" "${files[@]}"
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
