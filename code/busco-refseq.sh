#!/bin/bash

busco \
--in ~/project_data/downy/ref-seq \
--out busco_results \
--out_path ~/project_data/downy \
--mode genome \
--auto-lineage-euk \
--force \
--cpu 10 \
--tar \
--download_path ~/project_data/downy/busco_downloads
