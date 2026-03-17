#!/bin/bash
set -e


source ../build/app_store_creds.sh
PROJECT_NAME="XCreds Mobile"
SCHEME="XCreds Mobile"
APP_NAME="XCreds Mobile"
cwd=`pwd`

        if output="$(git status --porcelain)" && [ -z "$output" ]; then
                echo "'git status --porcelain' had no errors AND the working directory" \
                "is clean."
        else
                echo "Working directory has UNCOMMITTED CHANGES."
                exit -1
        fi


if [ -z "${NO_VERS_UPDATE}" ]; then
	agvtool bump -all
	
fi
build_number=$(agvtool what-version -terse)
version=$(xcodebuild -showBuildSettings |grep MARKETING_VERSION|tr -d 'MARKETING_VERSION =')

build_folder="${cwd}"/build/"${build_number}"

if [ ! -e "${build_folder}" ]; then 
	mkdir -p "${build_folder}"
fi


git commit -a -m 'updated build number, manifest and other build files'
git tag -a "tag-${version}(${build_number})" -m "tag-${version}(${buildNumber})"
#git push --tags
#git push


xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}" -configuration Release clean

xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME}" -configuration Release archive -archivePath "${build_folder}/${PROJECT_NAME}.xcarchive"
 

xcodebuild -exportArchive -archivePath "${build_folder}/${PROJECT_NAME}.xcarchive" -exportOptionsPlist exportOptions.plist -exportPath "${build_folder}" -allowProvisioningUpdates

#./package_ipa.sh "${build_folder}/${PROJECT_NAME}.xcarchive/Products/Applications/Smart Card Utility.app" "${build_folder}/${PROJECT_NAME}.xcarchive/Products/${APP_NAME}.ipa"

#pushd "${build_folder}/"
#mkdir tmp
#mv "${APP_NAME}.ipa" "tmp/${APP_NAME}.zip"
#cd tmp
#unzip "${APP_NAME}.zip"
#rm "${APP_NAME}.zip"
#cp -Rvp "${build_folder}/${PROJECT_NAME}.xcarchive"/SwiftSupport .
#zip --symlinks --verbose --recurse-paths "${build_folder}/${PROJECT_NAME}.xcarchive/Products/${APP_NAME}.ipa" .
#cd ..

#echo "uploading...."
#xcrun altool --upload-app --type ios --file "${build_folder}/${PROJECT_NAME}.xcarchive/Products/${APP_NAME}.ipa"  -u "${app_store_id}" -p "${app_store_password}"

echo "build ${build_number} finished"
