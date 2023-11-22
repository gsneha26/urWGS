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

$PROJECT_DIR/manage_instances/create_instances_basecall_align.sh $CONFIG_PATH
