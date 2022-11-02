# IRTX MATSim to COPERT connector

## Introduction

This model is a connector between the upstream MATSim model and the downstream
COPERT model for emissions analysis.

The purpose of this connector is to process a given MATSim simulation output,
and aggregate the obtained vehicle traces to COPERT-compatible vehicle
type information and prepare the input file for COPERT.

## Requirements

### Software requirements

The converter is packaged in a Python script. All dependencies to run the model
have been collected in a `conda` environment, which is available in the LEAD
repository as `environment.yml`.

### Input / Output

#### Input

To run the model, a finished MATSim simulation must be available. Specifically,
the MATSim output directory should contain a file called `trips.csv` describing
all the agent movements recorded from the simulation.

#### Output

The output of the model is an Excel sheet that can be transmitted for emissions
calculation to the COPERT model (`copert.xlsx`).

#### Configuration

The conversion process needs to be configured using a configuration file (`configuration.json`)
in JSON format. It is structured as follows:

```json
{
  "peaks": [
    { "start": 21600, "end": 32400 },
    { "start": 61200, "end": 68400 }
  ],
  "temperature": {
    "min": [
      1.1, 1.4, 4.2, 7.2, 11.2, 15.0, 17.0, 16.6, 12.8, 9.6, 4.9, 2.0
    ],
    "max": [
      7.1, 9.0, 13.8, 17.4, 21.5, 25.6, 28.2, 28.0, 23.1, 17.7, 11.4, 7.7
    ]
  },
  "humidity": [
    84.0, 80.0, 74.0, 71.0, 72.0, 70.0, 65.0, 70.0, 76.0, 82.0, 84.0, 86.0
  ],
  "mode_mapping": {}
}
```

First, it is defined what is understood as a peak period in the simulation
given as a start time and an end time in terms of seconds from midnight. After, maximum and
minimum temperatures for the twelve months of the year (starting January) are
given, as well as the mean humidity in percentage points. Finally, mappings from
the simulated MATSim modes to the COPERT emission classes are given as
follows:

```json
{
  "mode_mapping": {
    "freight:van": {
      "category": "Light Commercial Vehicles",
      "fuel": "Diesel",
      "segment": "N1-III",
      "euro_standard": "Euro 5",
      "fuel_tank_size": 100,
      "sampling_rate": 0.05
    }
  }
}
```

Here, an example for the `freight:van` mode is given. It is mapped to a
light vehicle emissions class for Diesel with a specified fuel tank size. Note
that JSprit vehicle types (when used as input to the MATSim simulation) are
translated into `freight:{vehicle_type}` while the other relevant contribution
to emissions is the standard `car` mode.

Attention, only modes that are defined in the configuration are considered in
the analysis.

Additionally, it is possible to define the sampling rate per mode which should
correspond to the sampling rate of the MATSim simulation. The relevant KPIs like
distance and vehicle count is scaled accordingly by the inverse of the sampling
rate.

# Running the model

The model is defined in a Jupyter notebook called `Convert.ipynb`. To run it,
call it through the `papermill` command line utility (which is installed as a
dependency in the `conda` environment) as described below:

```bash
papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path /path/to/configuration.json \
  -ptrips_path /path/to/trips.csv \
  -poutput_path /path/to/output/copert.xlsx \
  -pyear 2022
```

The **mandatory** parameters are detailed in the following table:

Parameter             | Values                            | Description
---                   | ---                               | ---
`configuration_path`          | String                            | Path to the conversion configuration file (see above)
`trips_path`          | String                            | Path to the MATSim output trips file
`output_path`         | String                            | Path where the COPERT data will be saved

The following **optional** parameter is available:

`year`     | Integer (default `2022`)                     | Year for which the information is written in the COPERT file

## Standard scenarios

For the Lyon living lab, a configuration file has already been prepared in
`data/configuration_lyon.json`. It can be used to prepare COPERT data for the
three main scenarios (Baseline 2022, UCC 2022, UCC 2030) as follows:

```bash
papermill "Convert.ipynb" /dev/null \
  -pconfiguration_path /irtx-matsim-copert-connector/data/configuration_lyon.json \
  -ptrips_path /irtx-matsim/output/output_{scenario}/trips.csv \
  -poutput_path /irtx-matsim-copert-connector/output/copert_{scenario}.xlsx \
  -pyear {year}
```

Here, `{scenario} = baseline_2022 | ucc_2022 | ucc_2030` and `year = 2022 | 2030`
according to the respective scenario.
