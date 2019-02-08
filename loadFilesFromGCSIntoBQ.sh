#!/bin/bash

# Copyright 2018 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreements with Google. 

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This scripts cycles through files in lcoud storage which are pipe delimited and loads them into BigQuery
#

main() {
  #Stop for loop making new lines for spaces in the file names
  IFS=$'\n'

  #Get src folder and list of files in that folder
  SRC_DIR="gs://qep_bkt3/20180808 Research Data Dump/*"
  BQ_TARGET_PROJECT=sufschrodersqep
  BQ_TARGET_DATASET=QEPData
  BQ_TARGET_TABLE=StockDataCleansed5
  
  #Get an array for the list of files
  FILES=$(gsutil ls ${SRC_DIR})
  declare -a files_to_load=(${FILES})

  #Loop through the files
  count=1
  for file in "${files_to_load[@]}"
  do
    echo "About to load file ${count} : $file"
    bq --location=europe-west2 load --field_delimiter="|" --schema_update_option=ALLOW_FIELD_ADDITION --source_format=CSV --allow_jagged_rows --skip_leading_rows=1 --noreplace --null_marker="NaN" --autodetect ${BQ_TARGET_PROJECT}:${BQ_TARGET_DATASET}.${BQ_TARGET_TABLE} "${file}"
    (( count++ ))
  done
  unset IFS
}

trap 'abort' 0
SECONDS=0
main
trap : 0
printf "\nProject Setup Complete in ${SECONDS} seconds.\n"

