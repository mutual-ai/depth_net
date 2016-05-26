#!/bin/bash
# This script accepts a caffemodel (and optionally a deploy)
# and runs a few default tests on the washington dataset

# Usage: ./do_washington_tests.sh caffemodel [deploy]

FEAT_FOLDER=ex_fcs/ # where extracted features are holded
CAFFE_MODEL=$1
DEPLOY=${2:-deploy_noshift.txt}  # user provided prototxt or use the default no_shift version
job_re='jobs\/(.+)\/sna'  # regex to find job id from caffemodel
if [[ $CAFFE_MODEL =~ $job_re ]]; then JOB_ID=${BASH_REMATCH[1]}; fi  # get job id

NORM_NAME=${FEAT_FOLDER}vandal_${JOB_ID}_normalized.pkl
ORIG_NAME=${FEAT_FOLDER}vandal_${JOB_ID}_original.pkl
source activate digits
echo Extracting Washington normalized to $NORM_NAME
python feature_extractor.py ../Washington/rgbd-normalized_gray/ Washington/all_depth_clean.txt $DEPLOY $CAFFE_MODEL $NORM_NAME --center_data 
echo Extracting Washington original to $ORIG_NAME
python feature_extractor.py ../Washington/rgbd-original/ Washington/all_depth_clean.txt $DEPLOY $CAFFE_MODEL $ORIG_NAME --center_data 

echo Running SVM on $NORM_NAME
SECONDS=0
python svm_baseline_parallel.py Washington/splits/ $NORM_NAME
echo Took $SECONDS seconds

SECONDS=0
echo Running SVM on $ORIG_NAME
python svm_baseline_parallel.py Washington/splits/ $ORIG_NAME
echo Took $SECONDS seconds
