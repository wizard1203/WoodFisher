DATASET=imagenet
MODEL=resnet50
DATA_PATH=../datasets/ILSVRC
CONFIG_PATH=./configs/resnet50.yaml
PRUNER=globalmagni
FITTABLE=2000
TARGET=0.80
EPOCHS=100
FISHER_SUBSAMPLE_SIZE=400
FISHER_MINI_BSZ=400
LAYER_INFO='all'
EXP_NAME="exp_str_prune_($MODEL)_($TARGET)_${LAYER_INFO}_epochs_($EPOCHS)_($PRUNER)_($FISHER_SUBSAMPLE_SIZE)_($FISHER_MINI_BSZ)_($FITTABLE)_hopefully_last"
LOAD_FROM="./checkpoints/ResNet50-STR-Dense.pth"
CSV_DIR="./csv"
LOG_DIR="./logs"
mkdir -p ${CSV_DIR}
mkdir -p ${LOG_DIR}
RESULT_PATH="${CSV_DIR}/${EXP_NAME}.csv"
LOG_PATH="${LOG_DIR}/${EXP_NAME}.log"

echo "EXPERIMENT $EXP_NAME"
export PYTHONUNBUFFERED=1

CUDA_VISIBLE_DEVICES=2,4,5,6,1 python main.py \
--exp_name=$EXP_NAME \
--dset=$DATASET \
--dset_path=$DATA_PATH \
--arch=$MODEL \
--config_path=$CONFIG_PATH \
--workers=20 --batch_size=256 --logging_level debug --gpus=0,1,2,3,4 \
--pretrained --from_checkpoint_path $LOAD_FROM \
--batched-test --not-oldfashioned --disable-log-soft --use-model-config \
--sweep-id 20 --fisher-damp 1e-5 --fisher-subsample-size ${FISHER_SUBSAMPLE_SIZE} --fisher-mini-bsz ${FISHER_MINI_BSZ} --update-config --prune-class $PRUNER \
--target-sparsity $TARGET \
--seed 0 --full-subsample --fisher-split-grads --fittable-params $FITTABLE \
--woodburry-joint-sparsify --offload-inv --offload-grads \
--result-file $RESULT_PATH --epochs $EPOCHS --eval-fast &> $LOG_PATH
