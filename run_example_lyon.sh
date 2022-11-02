set -e

## Activate environment
conda activate matsim2copert

## Run scenarios
papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path /home/ubuntu/irtx-matsim-copert-connector/data/configuration_lyon.json \
  -ptrips_path /home/ubuntu/irtx-matsim/output/output_baseline_2022/trips.csv \
  -poutput_path /home/ubuntu/irtx-matsim-copert-connector/output/copert_baseline_2022.xlsx \
  -pyear 2022

papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path data/configuration_lyon.json \
  -ptrips_path /home/ubuntu/irtx-matsim/output/output_ucc_2022/trips.csv \
  -poutput_path /home/ubuntu/irtx-matsim-copert-connector/output/copert_ucc_2022.xlsx \
  -pyear 2022

papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path data/configuration_lyon.json \
  -ptrips_path /home/ubuntu/irtx-matsim/output/output_ucc_2030/trips.csv \
  -poutput_path /home/ubuntu/irtx-matsim-copert-connector/output/copert_ucc_2030.xlsx \
  -pyear 2030
