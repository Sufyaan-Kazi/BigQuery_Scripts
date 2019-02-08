#!/bin/bash
main() {
  #Stop for loop making new lines for spaces in the file names
  IFS=$'\n'

  #Get src folder and list of files in that folder
  SRC_DIR="gs://qep_bkt3/20180808 Research Data Dump/*"
  BQ_TARGET_PROJECT=sufschrodersqep
  BQ_TARGET_DATASET=QEPData
  BQ_TARGET_TABLE=StockDataCleansed4
  
  #Get an array for the list of files
  FILES=$(gsutil ls ${SRC_DIR})
  declare -a files_to_load=(${FILES})

  #Loop throught the files
  for file in "${files_to_load[@]}"
  do
    echo "About to load file: $file"
    bq --location=europe-west2 load --field_delimiter="|" --schema_update_option=ALLOW_FIELD_ADDITION --source_format=CSV --allow_jagged_rows --skip_leading_rows=1 --noreplace --null_marker="NaN" --autodetect ${BQ_TARGET_PROJECT}:${BQ_TARGET_DATASET}.${BQ_TARGET_TABLE} "${file}"
  done
  unset IFS
}

trap 'abort' 0
SECONDS=0
main
trap : 0
printf "\nProject Setup Complete in ${SECONDS} seconds.\n"

