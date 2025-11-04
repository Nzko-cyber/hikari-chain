#!/bin/bash
# Test Hikari Chain Docker deployment

echo "🧪 Testing Hikari Chain Docker deployment..."
echo ""

# Wait for node to start
echo "⏳ Waiting for node to start (30 seconds)..."
sleep 30

echo ""
echo "1️⃣ Testing Tendermint RPC..."
curl -s http://localhost:26657/status | head -20

echo ""
echo ""
echo "2️⃣ Testing REST API - Node Info..."
curl -s http://localhost:1317/cosmos/base/tendermint/v1beta1/node_info | head -20

echo ""
echo ""
echo "3️⃣ Testing Photon module..."
curl -s http://localhost:1317/atomone/photon/v1/params

echo ""
echo ""
echo "4️⃣ Testing Dynamic Fee module..."
curl -s http://localhost:1317/atomone/dynamicfee/v1/state

echo ""
echo ""
echo "5️⃣ Testing Bank module..."
VALIDATOR_ADDR=$(docker exec hikari-node hikarid keys show validator -a --keyring-backend test 2>/dev/null)
if [ -n "$VALIDATOR_ADDR" ]; then
    echo "Validator address: $VALIDATOR_ADDR"
    curl -s "http://localhost:1317/cosmos/bank/v1beta1/balances/$VALIDATOR_ADDR"
else
    echo "⚠️  Could not get validator address"
fi

echo ""
echo ""
echo "6️⃣ Testing Governance module..."
curl -s http://localhost:1317/cosmos/gov/v1/proposals

echo ""
echo ""
echo "✅ Basic tests completed!"
echo ""
echo "📊 View live logs:"
echo "   docker logs -f hikari-node"
echo ""
echo "🔍 Enter container:"
echo "   docker exec -it hikari-node sh"
echo ""
echo "💬 Query commands inside container:"
echo "   hikarid status"
echo "   hikarid query bank balances \$(hikarid keys show validator -a --keyring-backend test)"
echo "   hikarid query photon params"
echo "   hikarid query dynamicfee state"
echo ""
