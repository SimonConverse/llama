# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the GNU General Public License version 3.

PRESIGNED_URL=""             https://dobf1k6cxlizq.cloudfront.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kb2JmMWs2Y3hsaXpxLmNsb3VkZnJvbnQubmV0LyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2ODE4OTAyMTJ9fX1dfQ__&Signature=qMWTuR0OVa1VwYLlFHYmN1VBOvr6FrqjWtIM4dKvzvO2PgtKWUE3zs9HWzH7WAitypLnBtxfsIZfARLz2SmNPtM3sPoQ8VbWHEulT8AVgkYHyXvWeUFv87mqztZxJsOH-xtkfD77xBl4i6iklP6cyb7hNJES3WOOnrM3aqZtMFr7Wt~ZOJvYKMe9UzyhrG~XRxQ87bGDV36hCZXSjsQWzgLdpR1KwQCcthLgPyR8QBOaUTcXzeUMJpSt1MG8NXZkPpUgJQ~-MEm2PZnLhUnvxvXAw4ZAAGycTET4DogjUsuh9lt6oIxF5QgbufR1OD4oGfoG9GlIBmEt~xd8ocY-3w__&Key-Pair-Id=K231VYXPC1TA1R
MODEL_SIZE="7B,13B,30B,65B"  "65B"
TARGET_FOLDER=""             # where all files should end up

declare -A N_SHARD_DICT

N_SHARD_DICT["7B"]="0"
N_SHARD_DICT["13B"]="1"
N_SHARD_DICT["30B"]="3"
N_SHARD_DICT["65B"]="7"

echo "Downloading tokenizer"
wget ${PRESIGNED_URL/'*'/"tokenizer.model"} -O ${TARGET_FOLDER}"/tokenizer.model"
wget ${PRESIGNED_URL/'*'/"tokenizer_checklist.chk"} -O ${TARGET_FOLDER}"/tokenizer_checklist.chk"

(cd ${TARGET_FOLDER} && md5sum -c tokenizer_checklist.chk)

for i in ${MODEL_SIZE//,/ }
do
    echo "Downloading ${i}"
    mkdir -p ${TARGET_FOLDER}"/${i}"
    for s in $(seq -f "0%g" 0 ${N_SHARD_DICT[$i]})
    do
        wget ${PRESIGNED_URL/'*'/"${i}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${i}/consolidated.${s}.pth"
    done
    wget ${PRESIGNED_URL/'*'/"${i}/params.json"} -O ${TARGET_FOLDER}"/${i}/params.json"
    wget ${PRESIGNED_URL/'*'/"${i}/checklist.chk"} -O ${TARGET_FOLDER}"/${i}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${i}" && md5sum -c checklist.chk)
done
