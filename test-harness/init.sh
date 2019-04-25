# NAME: init.sh
# Notable exported functions: 
# 1. template_build_targets: compares the source and upstream branch to determines which terraform template directories were modified.
# 2. check_required_env_variables: verifies that required environment variables are defined. 
# USAGE: template_build_targets $BUILD_UPSTREAMBRANCH $BUILD_SOURCEBRANCHNAME
#        check_required_env_variables

#!/usr/bin/env bash
set -euo pipefail

declare -A TEST_RUN_MAP
declare readonly TEMPLATE_DIR="infra/templates"

function check_required_env_variables() {
    echo "INFO: Checking required environment variables"
    for var in ARM_SUBSCRIPTION_ID ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_TENANT_ID ARM_ACCESS_KEY ; do
        if [[ ! -v ${var} ]] ; then
            echo "ERROR: $var is not set in the environment"
            return 0
        fi
    done
    echo "INFO: passed environment variable check"
}

function default_to_all_template_paths() {
    echo "INFO: Terraform module file(s) changed. Running all tests"
	declare -a ALL_TEMPLATE_DIRS=(`find $TEMPLATE_DIR/* -maxdepth 0 -type d`)
    shopt -s nullglob
    for folder in "${ALL_TEMPLATE_DIRS[@]}"
    do
        IFS='/' read -a folder_array <<< "${folder}"
        TEST_RUN_MAP[${folder_array[2]}]=$folder
    done
}

function add_template_if_not_exists() {
    declare readonly template_name=$1
    if [[ -z ${TEST_RUN_MAP[$template_name]+unset} ]]; then
        TEST_RUN_MAP[$template_name]="$TEMPLATE_DIR/$template_name"
    fi;
}

function template_build_targets() {
    GIT_DIFF_UPSTREAMBRANCH=$1
    GIT_DIFF_SOURCEBRANCH=$2
    [[ -z $GIT_DIFF_UPSTREAMBRANCH ]] && echo "ERROR: GIT_DIFF_UPSTREAMBRANCH wasn't provided" && return 1

    [[ -z $GIT_DIFF_SOURCEBRANCH ]] && echo "ERROR: GIT_DIFF_SOURCEBRANCH wasn't provided" && return 1

    echo "INFO: Running git diff from branch ${GIT_DIFF_SOURCEBRANCH}"
    files=(`git diff ${GIT_DIFF_UPSTREAMBRANCH} ${GIT_DIFF_SOURCEBRANCH} --name-only|grep -v *.md`)
    for file in "${files[@]}"
    do
        IFS='/' read -a folder_array <<< "${file}"
        
        if [ ${#folder_array[@]} -lt 3 ]; then
            continue
        fi

        case ${folder_array[1]} in
            'modules'|'test-harness')
                default_to_all_template_paths
                break
                ;;
            'templates') declare readonly template_name=${folder_array[2]}
                add_template_if_not_exists $template_name
                ;;
        esac
    done
}