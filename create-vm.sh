#!/bin/bash

VM_NAME="netology-vm-task5"
ZONE="ru-central1-a"
CLOUD_INIT="cloud-init.yaml"

yc compute instance delete --name "$VM_NAME" 2>/dev/null || true

yc compute instance create \
  --name "$VM_NAME" \
  --zone "$ZONE" \
  --memory 2GB \
  --cores 2 \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata-from-file user-data="$CLOUD_INIT"

echo "Waiting 30s..."
sleep 30

VM_IP=$(yc compute instance get "$VM_NAME" --format json | jq -r '.network_interfaces[0].primary_v4_address.one_to_one_nat.address')

echo "VM IP: $VM_IP"
echo "SSH: ssh ubuntu@$VM_IP"

sleep 15
curl -v "http://$VM_IP:8090" || echo "App not ready yet"
