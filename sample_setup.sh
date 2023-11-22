source $PROJECT_DIR/sample.config
gsutil mb $BUCKET
echo $BUCKET

WORK_DIR=/data/RAPID_PHASE2/$SAMPLE
LOG_DIR=/data/prom_ph2/$SAMPLE/logs
mkdir -p $WORK_DIR/
mkdir -p $LOG_DIR/

cp $PROJECT_DIR/sample.config $WORK_DIR/
CONFIG_PATH=$WORK_DIR/sample.config

gsutil cp $CONFIG_PATH ${BUCKET}/sample.config

crontab -r
(crontab -u $USER -l; echo -e "SHELL=/bin/bash\nPATH=/home/prom/google-cloud-sdk/bin:/home/prom/miniconda3/bin:/home/prom/miniconda3/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\nWORK_DIR=$WORK_DIR\nLOG_DIR=$LOG_DIR\n* * * * * bash -c $PROJECT_DIR/prom_upload/upload_fast5.sh >> $LOG_DIR/upload_stdout.log 2>> $LOG_DIR/upload_stderr.log") | crontab -u $USER -
#(crontab -u $USER -l; echo -e "SHELL=/bin/bash\nPATH=/home/prom/google-cloud-sdk/bin:/home/prom/miniconda3/bin:/home/prom/miniconda3/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\nPROJECT_DIR=$PROJECT_DIR\nWORK_DIR=$WORK_DIR\nLOG_DIR=$LOG_DIR\n*/3 * * * * bash -c $PROJECT_DIR/prom_upload/upload_fast5.sh >> $LOG_DIR/upload_stdout.log 2>> $LOG_DIR/upload_stderr.log\n*/3 * * * * bash -c $PROJECT_DIR/manage_instances/delete_instances_basecall_align_wrapper.sh >> $LOG_DIR/delete_instances_stdout.log 2>> $LOG_DIR/delete_instances_stderr.log") | crontab -u $USER -

$PROJECT_DIR/manage_instances/create_instances_basecall_align.sh $CONFIG_PATH
