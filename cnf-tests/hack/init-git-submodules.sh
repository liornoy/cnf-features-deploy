set +x
set -e

metallb_operator_branch="${METALLB_OPERATOR_BRANCH:-main}"
sriov_network_operator_branch="${SRIOV_NETWORK_OPERATOR_BRANCH:-master}"
ptp_operator_branch="${PTP_OPERATOR_BRANCH:-master}"
cluster_node_tuning_operator_branch="${CLUSTER_NODE_TUNING_OPERATOR_BRANCH:-master}"

echo "init git submodules"
echo "metallb-operator branch: ${metallb_operator_branch}"
echo "sriov-operator branch: ${sriov_network_operator_branch}"
echo "ptp-operator branch: ${ptp_operator_branch}"
echo "clusternode-tuning-operator branch: ${cluster_node_tuning_operator_branch}"

cd metallb-operator/
git checkout ${metallb_operator_branch}
git submodule update --init

cd ../sriov-network-operator/
git checkout ${sriov_network_operator_branch}
git submodule update --init

cd ../ptp-operator/
git checkout ${ptp_operator_branch}
git submodule update --init

cd ../cluster-node-tuning-operator/
git checkout ${cluster_node_tuning_operator_branch}
git submodule update --init
