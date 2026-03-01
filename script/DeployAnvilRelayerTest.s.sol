// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title DeployAnvilRelayerTest
/// @notice Deploys minimal stack for relayer integration tests: market, funded user, MAV deposit.
/// @dev Run: anvil && source .env.anvil.example && forge script script/DeployAnvilRelayerTest.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
///      Anvil default account 0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (operator + test user)
///      Anvil default account 1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
///      Anvil default account 2: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

import {Script, console2} from "forge-std/Script.sol";

import {MockUSDC} from "../src/mockTest/token/MockUSDC.sol";
import {RelayerTestMarketFactory} from "../src/mockTest/RelayerTestMarketFactory.sol";

import {OutcomeToken1155} from "../src/execution/OutcomeToken1155.sol";
import {MarketRiskManager} from "../src/execution/MarketRiskManager.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {MultiAssetVault} from "../src/execution/MultiAssetVault.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";

import {FeeManager} from "../src/fees/FeeManager.sol";
import {FeePool} from "../src/fees/FeePool.sol";
import {TreasuryPool} from "../src/fees/TreasuryPool.sol";

contract DeployAnvilRelayerTest is Script {
    uint256 constant ANVIL_PK_0 = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant ANVIL_PK_1 = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 constant ANVIL_PK_2 = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    function run() external {
        address operator = vm.addr(ANVIL_PK_0);

        address user0 = vm.addr(ANVIL_PK_0);
        address user1 = vm.addr(ANVIL_PK_1);
        address user2 = vm.addr(ANVIL_PK_2);

        uint256 depositAmount = 1_000_000 * 1e6; // 1M USDC (6 decimals)
        uint48 expiry = uint48(block.timestamp + 86400 * 7); // 7 days

        vm.startBroadcast(ANVIL_PK_0);

        MockUSDC mockUSDC = new MockUSDC();
        mockUSDC.mint(user0, 10_000_000 * 1e6);
        mockUSDC.mint(user1, depositAmount);
        mockUSDC.mint(user2, depositAmount);

        address settlementToken = address(mockUSDC);

        OutcomeToken1155 outcomeToken = new OutcomeToken1155("https://api.retropick.xyz/outcome/{id}.json");
        MarketRiskManager riskManager = new MarketRiskManager();
        MultiAssetVault multiAssetVault = new MultiAssetVault(address(0));
        CollateralVault collateralVault = new CollateralVault(settlementToken, address(0));
        ChannelSettlement channelSettlement = new ChannelSettlement(address(collateralVault), address(0), operator);
        MarketRegistry marketRegistry = new MarketRegistry(address(collateralVault), address(0));

        outcomeToken.setChannelSettlement(address(channelSettlement));
        outcomeToken.setMarketRegistry(address(marketRegistry));
        riskManager.setChannelSettlement(address(channelSettlement));
        channelSettlement.setOutcomeToken(address(outcomeToken));
        channelSettlement.setRiskManager(address(riskManager));
        marketRegistry.setOutcomeToken(address(outcomeToken));
        multiAssetVault.setChannelSettlement(address(channelSettlement));
        multiAssetVault.setMarketRegistry(address(marketRegistry));
        collateralVault.setChannelSettlement(address(channelSettlement));
        collateralVault.setMarketRegistry(address(marketRegistry));
        channelSettlement.setMarketRegistry(address(marketRegistry));
        channelSettlement.setMultiAssetVault(address(multiAssetVault));
        marketRegistry.setMultiAssetVault(address(multiAssetVault));
        marketRegistry.setDefaultSettlementAsset(settlementToken);

        FeeManager feeManager = new FeeManager(200); // 2% protocol fee
        FeePool feePool = new FeePool();
        TreasuryPool treasuryPool = new TreasuryPool();
        feeManager.setLpFeeShareBps(2000);
        feeManager.setCreatorFeeShareBps(2000);
        feePool.setFeeCollector(address(channelSettlement));
        feePool.setTreasuryPool(address(treasuryPool));
        channelSettlement.setFeeManager(address(feeManager));
        channelSettlement.setFeePool(address(feePool));

        RelayerTestMarketFactory relayerTestMarketFactory = new RelayerTestMarketFactory(address(marketRegistry));
        marketRegistry.setMarketFactory(address(relayerTestMarketFactory));

        uint256 marketId = relayerTestMarketFactory.createTestMarket(
            "Relayer E2E test market",
            user0,
            expiry,
            settlementToken
        );

        mockUSDC.approve(address(multiAssetVault), depositAmount);
        multiAssetVault.deposit(settlementToken, depositAmount);

        vm.stopBroadcast();
        vm.startBroadcast(ANVIL_PK_1);
        mockUSDC.approve(address(multiAssetVault), depositAmount);
        multiAssetVault.deposit(settlementToken, depositAmount);
        vm.stopBroadcast();

        vm.startBroadcast(ANVIL_PK_2);
        mockUSDC.approve(address(multiAssetVault), depositAmount);
        multiAssetVault.deposit(settlementToken, depositAmount);
        vm.stopBroadcast();

        console2.log("CHANNEL_SETTLEMENT_ADDRESS=", address(channelSettlement));
        console2.log("MARKET_ID=", marketId);
        console2.log("MULTI_ASSET_VAULT=", address(multiAssetVault));
        console2.log("SETTLEMENT_TOKEN=", settlementToken);
        console2.log("OUTCOME_TOKEN=", address(outcomeToken));
        console2.log("TEST_USER_0=", user0);
        console2.log("TEST_USER_1=", user1);
        console2.log("TEST_USER_2=", user2);
        console2.log("OPERATOR=", operator);
        console2.log("");
        console2.log("--- Relayer .env ---");
        console2.log("RPC_URL=http://127.0.0.1:8545");
        console2.log("CHAIN_ID=31337");
        console2.log("CHANNEL_SETTLEMENT_ADDRESS=", address(channelSettlement));
        console2.log("OPERATOR_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
    }
}
