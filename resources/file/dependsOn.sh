#!/bin/bash -e

get_file() {
  local resourceName="$1"
  local resourcePath=$(eval echo "$"res_"$resourceName"_resourcePath)
  local intMasterName=$(eval echo "$"res_"$resourceName"_int_masterName)
  local fileLocation=$(eval echo "$"res_"$resourceName"_fileLocation)
  local autoPull=$(eval echo "$"res_"$resourceName"_autoPull)

  if [ -z "$autoPull" ] || "$autoPull" == "true" ; then

    if [ "$intMasterName" == "amazonKeys" ]; then
      local accessKeyId=$(eval echo "$"res_"$resourceName"_int_accessKeyId)
      local secretAccessKey=$(eval echo "$"res_"$resourceName"_int_secretAccessKey)
      local region=$(eval echo "$"res_"$resourceName"_region)

      aws configure set aws_access_key_id "$accessKeyId"
      aws configure set aws_secret_access_key "$secretAccessKey"
      aws configure set region "$region"

      aws s3 sync $fileLocation $resourcePath
    elif [ "$intMasterName" == "gcloudKey" ]; then
      local jsonKey=$(eval echo "$"res_"$resourceName"_int_jsonKey)
      local projectId="$( echo "$jsonKey" | jq -r '.project_id' )"

      touch key.json
      echo "$jsonKey" > key.json
      gcloud -q auth activate-service-account --key-file "key.json"
      gcloud config set project "$projectId"

      gcloud compute scp --recurse $fileLocation $resourcePath
    fi
    echo "Successfully fetched file"
  fi
}

execute_command "get_file %%context.resourceName%%"
