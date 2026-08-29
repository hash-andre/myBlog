(
  set -euo pipefail

  content_root="content"

  # Sections: directories that may contain other sections or pages.
  sections=(
    "posts"
    "man"
    "man/thought"
    "man/lab"
    "man/lab/active-directory"
    "man/lab/hardware"
    "man/lab/software"
    "man/lab/software/odin-project"
    "man/network"
    "man/os"
  )

  for section in "${sections[@]}"; do
    mkdir -p "$content_root/$section"
    touch "$content_root/$section/_index.md"
  done

  # Convert an existing page.md into page/index.md.
  # If page.md does not exist, create a new empty bundle.
  make_bundle() {
    local relative_path="$1"
    local old_file="$content_root/$relative_path.md"
    local bundle_dir="$content_root/$relative_path"
    local index_file="$bundle_dir/index.md"

    if [[ -e "$old_file" && -e "$index_file" ]]; then
      echo "Conflict: both '$old_file' and '$index_file' exist." >&2
      return 1
    fi

    mkdir -p "$bundle_dir"

    if [[ -f "$old_file" ]]; then
      mv -- "$old_file" "$index_file"
      echo "Moved: $old_file -> $index_file"
    elif [[ ! -e "$index_file" ]]; then
      touch "$index_file"
      echo "Created: $index_file"
    else
      echo "Already exists: $index_file"
    fi
  }

  pages=(
    "man/thought/pensiero-00"
    "man/thought/pensiero-01"
    "man/lab/active-directory/ad-00"
    "man/lab/active-directory/ad-01"
    "man/lab/hardware/hardware-00"
    "man/lab/software/blog"
    "man/lab/software/odin-project/foundations"
    "man/network/00-osi-model"
    "man/network/01-ethernet"
    "man/os/filesystem"
  )

  for page in "${pages[@]}"; do
    make_bundle "$page"
  done

  # Preserve/create the two existing standalone pages.
  touch "$content_root/posts/my-first-post.md"
  touch "$content_root/whoami.md"
)