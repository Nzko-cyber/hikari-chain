#!/bin/bash
# Quick Docker run script for Hikari Chain

set -e

echo "🐳 Starting Hikari Chain in Docker..."

# Build the image
echo "📦 Building Docker image..."
docker build -t hikari-chain .

# Stop and remove existing container if exists
docker stop hikari-node 2>/dev/null || true
docker rm hikari-node 2>/dev/null || true

# Create volume if not exists
docker volume create hikari-data 2>/dev/null || true

# Check if node is already initialized
if docker run --rm -v hikari-data:/root/.hikari hikari-chain sh -c "[ -f /root/.hikari/config/genesis.json ]"; then
    echo "✅ Node already initialized, starting..."
    docker run -d \
        --name hikari-node \
        -p 26656:26656 \
        -p 26657:26657 \
        -p 1317:1317 \
        -p 9090:9090 \
        -v hikari-data:/root/.hikari \
        hikari-chain start --minimum-gas-prices=0.01uphoton,0.01ulight
else
    echo "🔧 Initializing new node..."

    # Initialize
    docker run --rm -v hikari-data:/root/.hikari hikari-chain \
        init mynode --chain-id hikari-1 --default-denom ulight

    # Create key (using test keyring for easier testing)
    docker run --rm -v hikari-data:/root/.hikari hikari-chain \
        keys add validator --keyring-backend test --output json > /tmp/validator-key.json

    echo "🔑 Validator key created!"
    cat /tmp/validator-key.json

    # Get validator address
    VALIDATOR_ADDR=$(docker run --rm -v hikari-data:/root/.hikari hikari-chain \
        keys show validator -a --keyring-backend test)

    echo "📍 Validator address: $VALIDATOR_ADDR"

    # Add genesis account
    docker run --rm -v hikari-data:/root/.hikari hikari-chain \
        genesis add-genesis-account $VALIDATOR_ADDR 10000000000000ulight,10000000000uphoton

    # Create gentx
    docker run --rm -v hikari-data:/root/.hikari hikari-chain \
        genesis gentx validator 1000000000ulight --chain-id hikari-1 --keyring-backend test

    # Collect gentxs
    docker run --rm -v hikari-data:/root/.hikari hikari-chain \
        genesis collect-gentxs

    # Configure app.toml
    docker run --rm -v hikari-data:/root/.hikari hikari-chain \
        sh -c 'sed -i "s/minimum-gas-prices = \"\"/minimum-gas-prices = \"0.01uphoton,0.01ulight\"/g" /root/.hikari/config/app.toml && \
               sed -i "s/enable = false/enable = true/g" /root/.hikari/config/app.toml && \
               sed -i "s/swagger = false/swagger = true/g" /root/.hikari/config/app.toml'

    echo "✅ Node initialized!"

    # Start node
    docker run -d \
        --name hikari-node \
        -p 26656:26656 \
        -p 26657:26657 \
        -p 1317:1317 \
        -p 9090:9090 \
        -v hikari-data:/root/.hikari \
        hikari-chain start --minimum-gas-prices=0.01uphoton,0.01ulight
fi

echo ""
echo "✅ Hikari Chain is starting!"
echo ""
echo "📊 Check status:"
echo "   docker logs -f hikari-node"
echo ""
echo "🌐 API Endpoints:"
echo "   REST API:        http://localhost:1317"
echo "   Tendermint RPC:  http://localhost:26657"
echo "   gRPC:            localhost:9090"
echo ""
echo "🔍 Test queries:"
echo "   curl http://localhost:26657/status"
echo "   curl http://localhost:1317/cosmos/base/tendermint/v1beta1/node_info"
echo ""
echo "🛑 Stop node:"
echo "   docker stop hikari-node"
echo ""
