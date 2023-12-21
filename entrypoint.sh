#!/bin/bash

# Increment a version string using Semantic Versioning (SemVer) terminology.

# Parse command line options.

while getopts ":Mmp d:s:" opt; do
    case $opt in
        M ) major=true;;
        m ) minor=true;;
        p ) patch=true;;
        d ) dir=$OPTARG;;
        s ) suffix=$OPTARG;;
    esac
done

filter="refs/tags"

if [ ! -z ${dir} ]
  then
    filter="${filter}/${dir}"
fi

if [ ! -z ${suffix} ]
  then
    filter="${filter}/*-${suffix}"
fi

shift $((OPTIND -1))

git config --global --add safe.directory /github/workspace
echo "cd to github workspace"
cd ${GITHUB_WORKSPACE}
git for-each-ref ${filter} --count=1 --sort=-version:refname --format='%(refname:short)'
version=$(git for-each-ref ${filter} --count=1 --sort=-version:refname --format='%(refname:short)')
echo "Version: ${version}"

if [ -z ${version} ]
then
  echo "No version found, setting to 0.0.0"
  version="v0.0.0"

  if [ ! -z ${dir} ]
  then
    version="${dir}/${version}"
  fi
fi
# Build array from version string.

if [ ! -z ${suffix} ]
  then
    version=${version%"-$suffix"}
fi

a=( ${version//./ } )
major_version=0
# If version string is missing or has the wrong number of members, show usage message.

if [ ${#a[@]} -ne 3 ]
then
  echo "usage: $(basename $0) [-Mmp] major.minor.patch"
  exit 1
fi

# Increment version numbers as requested.

if [ ! -z $major ]
then
# Check for v in version (e.g. v1.0 not just 1.0)
  if [[ ${a[0]} =~ ([${dir}vV]?)([0-9]+) ]]
  then 
    v="${BASH_REMATCH[1]}"
    major_version=${BASH_REMATCH[2]}
    ((major_version++))
    a[0]=${v}${major_version}
  else 
    ((a[0]++))
    major_version=a[0]
  fi
  
  a[1]=0
  a[2]=0
fi

if [ ! -z $minor ]
then
  ((a[1]++))
  a[2]=0
fi

if [ ! -z $patch ]
then
  ((a[2]++))
fi

finalver="${a[0]}.${a[1]}.${a[2]}"
if [ ! -z ${suffix} ]
  then
    finalver="${finalver}-${suffix}"
fi

echo $finalver
version=$(echo "${finalver}")
echo "::set-output name=version::${version}"