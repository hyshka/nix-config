#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

base_ref="${BASE_REF:-origin/main}"
branch="${BRANCH:-flake-inputs}"
title="${PR_TITLE:-flake.lock: update inputs}"
repo="${FORGEJO_REPOSITORY:-hyshka/nix-config}"
server="${FORGEJO_SERVER_URL:-https://code.home.hyshka.com}"
api="${server%/}/api/v1"
token="${FORGEJO_TOKEN:-}"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

old_lock="$work_dir/flake.lock.old"
body_file="$work_dir/body.md"
jq_file="$work_dir/compare.jq"

cat >"$jq_file" <<'JQ'
def revof:
  if (.rev // "") != "" then .rev
  else
    (.url // "") as $u
    | if ($u | test("nixos-[^/]+\\.[0-9a-f]{7,40}/")) then
        ($u | capture("nixos-[^/]+\\.(?<rev>[0-9a-f]{7,40})/") | .rev)
      else "" end
  end;

def comparelink($old; $new):
  (.original // {}) as $o
  | if $o.type == "github" then
      "https://\($o.host // "github.com")/\($o.owner)/\($o.repo)/compare/\($old)...\($new)"
    elif $o.type == "gitlab" then
      "https://\($o.host // "gitlab.com")/\($o.owner)/\($o.repo)/-/compare/\($old)...\($new)"
    elif $o.type == "tarball"
      and (($o.url // "") | test("channels\\.nixos\\.org|nixos\\.org/channels")) then
      "https://github.com/NixOS/nixpkgs/compare/\($old)...\($new)"
    else "" end;

.nodes as $new
| ($old[0].nodes) as $prev
| [
    $new
    | to_entries[]
    | select(.key != "root")
    | .key as $name
    | .value as $node
    | (($prev[$name].locked // {}) | revof) as $oldrev
    | (($node.locked // {}) | revof) as $newrev
    | select($oldrev != "" and $newrev != "" and $oldrev != $newrev)
    | ($node | comparelink($oldrev; $newrev)) as $link
    | if $link != "" then
        "- `\($name)`: [`\($oldrev[0:7])` → `\($newrev[0:7])`](\($link))"
      else
        "- `\($name)`: `\($oldrev[0:7])` → `\($newrev[0:7])`"
      end
  ]
| sort
| .[]
JQ

git show "${base_ref}:flake.lock" >"$old_lock"
git checkout -B "$branch" "$base_ref"

nix flake update

if git diff --quiet -- flake.lock; then
  echo "flake.lock already current"
  exit 0
fi

lines="$(jq -r --slurpfile old "$old_lock" -f "$jq_file" flake.lock)"
if [ -z "$lines" ]; then
  echo "flake.lock changed without a tracked input rev change" >&2
  exit 1
fi

{
  echo 'Automated by nix flake update.'
  echo
  echo "### Updated inputs"
  echo
  printf '%s\n' "$lines"
} >"$body_file"

git -c user.name="flake-inputs[bot]" -c user.email="noreply@hyshka.com" \
  commit -m "$title" -- flake.lock

if [ "${DRY_RUN:-0}" = "1" ]; then
  echo "pr title: $title"
  echo "branch: $branch"
  cat "$body_file"
  exit 0
fi

if [ -z "$token" ]; then
  echo "FORGEJO_TOKEN is empty" >&2
  exit 1
fi

git push --force origin "HEAD:refs/heads/$branch"

api_curl=(curl -fsS -H "Authorization: token $token" -H "Content-Type: application/json")

prs="$("${api_curl[@]}" "$api/repos/$repo/pulls?state=open&limit=50")"
number="$(printf '%s' "$prs" | jq -r --arg b "$branch" '.[] | select(.head.ref == $b) | .number' | head -n1)"

if [ -z "$number" ]; then
  payload="$(jq -n --arg title "$title" --arg head "$branch" --rawfile body "$body_file" \
    '{title: $title, head: $head, base: "main", body: $body}')"
  number="$("${api_curl[@]}" -X POST -d "$payload" "$api/repos/$repo/pulls" | jq -r '.number')"
  echo "opened PR #$number"
else
  payload="$(jq -n --arg title "$title" --rawfile body "$body_file" \
    '{title: $title, body: $body}')"
  "${api_curl[@]}" -X PATCH -d "$payload" "$api/repos/$repo/pulls/$number" >/dev/null
  echo "updated PR #$number"
fi

label_ids="$("${api_curl[@]}" "$api/repos/$repo/labels" |
  jq -c '[.[] | select(.name == "dependencies" or .name == "automated") | .id]')"
if [ "$label_ids" != "[]" ]; then
  "${api_curl[@]}" -X POST -d "{\"labels\": $label_ids}" \
    "$api/repos/$repo/issues/$number/labels" >/dev/null
else
  echo "labels dependencies/automated not found; PR left unlabeled" >&2
fi
