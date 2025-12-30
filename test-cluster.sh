#!/bin/bash
# Fast-Kubernetes Cluster Testing Script
# Tests basic functionality of Multipass + kubeadm cluster

set -e

echo "🔍 Fast-Kubernetes Cluster Testing Script"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is configured
echo -e "\n${YELLOW}1. Checking kubectl configuration...${NC}"
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}❌ kubectl not configured. Run:${NC}"
    echo "export KUBECONFIG=~/.kube/multipass-admin.conf"
    exit 1
fi
echo -e "${GREEN}✅ kubectl configured${NC}"

# Check cluster nodes
echo -e "\n${YELLOW}2. Checking cluster nodes...${NC}"
NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
READY_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | grep -c "Ready")

if [ "$NODE_COUNT" -lt 1 ]; then
    echo -e "${RED}❌ No nodes found${NC}"
    exit 1
fi

if [ "$READY_COUNT" -eq "$NODE_COUNT" ]; then
    echo -e "${GREEN}✅ All $NODE_COUNT nodes ready${NC}"
else
    echo -e "${RED}❌ $READY_COUNT/$NODE_COUNT nodes ready${NC}"
fi

# Test basic pod creation
echo -e "\n${YELLOW}3. Testing pod creation...${NC}"
kubectl run test-pod --image=busybox --restart=Never --command -- echo "test" >/dev/null 2>&1

sleep 5

if kubectl get pod test-pod >/dev/null 2>&1; then
    STATUS=$(kubectl get pod test-pod --no-headers -o custom-columns=":status.phase")
    if [ "$STATUS" = "Succeeded" ]; then
        echo -e "${GREEN}✅ Pod creation successful${NC}"
    else
        echo -e "${YELLOW}⚠️ Pod status: $STATUS${NC}"
    fi
else
    echo -e "${RED}❌ Pod creation failed${NC}"
    exit 1
fi

# Test pod execution
echo -e "\n${YELLOW}4. Testing pod execution...${NC}"
if kubectl exec test-pod -- echo "hello" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Pod execution successful${NC}"
else
    echo -e "${RED}❌ Pod execution failed${NC}"
fi

# Check CNI (Flannel)
echo -e "\n${YELLOW}5. Checking CNI (Flannel)...${NC}"
if kubectl get pods -n kube-flannel >/dev/null 2>&1; then
    FLANNEL_PODS=$(kubectl get pods -n kube-flannel --no-headers 2>/dev/null | wc -l)
    READY_FLANNEL=$(kubectl get pods -n kube-flannel --no-headers 2>/dev/null | grep -c "Running")
    if [ "$READY_FLANNEL" -eq "$FLANNEL_PODS" ]; then
        echo -e "${GREEN}✅ Flannel CNI healthy ($READY_FLANNEL/$FLANNEL_PODS pods running)${NC}"
    else
        echo -e "${YELLOW}⚠️ Flannel pods: $READY_FLANNEL/$FLANNEL_PODS running${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Flannel namespace not found (may be different CNI)${NC}"
fi

# Clean up
echo -e "\n${YELLOW}6. Cleaning up test resources...${NC}"
kubectl delete pod test-pod >/dev/null 2>&1
echo -e "${GREEN}✅ Test pod deleted${NC}"

echo -e "\n${GREEN}🎉 Cluster testing complete!${NC}"
echo ""
echo "Quick commands:"
echo "- kubectl get nodes"
echo "- kubectl get pods -A"
echo "- kubectl cluster-info"
echo ""
echo "For full testing guide: cat Local-Testing-Guide.md"
