// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title DeployBetaTestnet
/// @notice Deploys the full V3-Escrow testnet stack with all mock tokens (USDC, DAI, USDT, EURC, AVAX, IDRX) + Faucet for beta testers.
/// @dev Topology: OutcomeToken1155 + MarketRiskManager + escrow-safe vaults (reserve-on-submit, release-on-finalize).
///      Beta users: claim mock USDC from Faucet -> deposit into MultiAssetVault(settlementToken) -> trade.
///      CollateralVault is fallback when MAV not used; in this deploy MAV is primary.

import {Script, console2} from "forge-std/Script.sol";

import {MockUSDC} from "../src/mockTest/token/MockUSDC.sol";
import {MockDAI} from "../src/mockTest/token/MockDAI.sol";
import {MockUSDT} from "../src/mockTest/token/MockUSDT.sol";
import {MockEURC} from "../src/mockTest/token/MockEURC.sol";
import {MockAVAX} from "../src/mockTest/token/MockAVAX.sol";
import {MockIDRX} from "../src/mockTest/token/MockIDRX.sol";
import {Faucet} from "../src/mockTest/faucet/Faucet.sol";

import {OutcomeToken1155} from "../src/execution/OutcomeToken1155.sol";
import {MarketRiskManager} from "../src/execution/MarketRiskManager.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {MultiAssetVault} from "../src/execution/MultiAssetVault.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";

import {FeeManager} from "../src/fees/FeeManager.sol";
import {FeePool} from "../src/fees/FeePool.sol";
import {TreasuryPool} from "../src/fees/TreasuryPool.sol";

import {ReportValidator} from "../src/oracle/ReportValidator.sol";
import {CREReceiver} from "../src/oracle/CREReceiver.sol";
import {OracleCoordinator} from "../src/oracle/OracleCoordinator.sol";
import {SettlementRouter} from "../src/core/SettlementRouter.sol";

import {MarketPolicy} from "../src/curation/MarketPolicy.sol";
import {MarketDraftBoard} from "../src/curation/MarketDraftBoard.sol";
import {DraftClaimManager} from "../src/curation/DraftClaimManager.sol";
import {LiquidityVaultFactory} from "../src/curation/LiquidityVaultFactory.sol";
import {CREPublishReceiver} from "../src/curation/CREPublishReceiver.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";

contract DeployBetaTestnet is Script {
    struct Deployed {
        MockUSDC mockUSDC;
        MockDAI mockDAI;
        MockUSDT mockUSDT;
        MockEURC mockEURC;
        MockAVAX mockAVAX;
        MockIDRX mockIDRX;
        Faucet faucet;
        OutcomeToken1155 outcomeToken;
        MarketRiskManager riskManager;
        ChannelSettlement channelSettlement;
        MultiAssetVault multiAssetVault;
        CollateralVault collateralVault;
        MarketRegistry marketRegistry;
        FeeManager feeManager;
        FeePool feePool;
        TreasuryPool treasuryPool;
        ReportValidator reportValidator;
        CREReceiver creReceiver;
        OracleCoordinator oracleCoordinator;
        SettlementRouter settlementRouter;
        MarketPolicy marketPolicy;
        MarketDraftBoard draftBoard;
        DraftClaimManager draftClaimManager;
        LiquidityVaultFactory liquidityVaultFactory;
        CREPublishReceiver crePublishReceiver;
        MarketFactory marketFactory;
    }

    function run() external returns (Deployed memory d) {
        // ---- Required env ----
        address operator = _envAddressReq("OPERATOR");
        address forwarder = _resolveForwarder();

        // ---- Faucet config (optional, with defaults) ----
        uint96 faucetAmountPerClaim = uint96(_envUintOr("FAUCET_AMOUNT_PER_CLAIM", 1000 * 1e6)); // 1000 USDC (6 decimals)
        uint32 faucetCooldownSecs = uint32(_envUintOr("FAUCET_COOLDOWN_SECS", 3600)); // 1 hour
        uint256 faucetMintSupply = _envUintOr("FAUCET_MINT_SUPPLY", 1_000_000 * 1e6); // 1M USDC

        // ---- Validations / configs (reuse DeployTestnet env) ----
        uint16 minConfidence = uint16(_envUintReq("MIN_CONFIDENCE"));
        uint16 protocolFeeBps = uint16(_envUintReq("PROTOCOL_FEE_BPS"));
        uint16 lpFeeShareBps = uint16(_envUintReq("LP_FEE_SHARE_BPS"));
        uint16 creatorFeeShareBps = uint16(_envUintReq("CREATOR_FEE_SHARE_BPS"));
        bool useReceiverAllowlist = _envBoolOr("USE_RECEIVER_ALLOWLIST", true);
        bool approveRegistryReceiver = _envBoolOr("APPROVE_MARKET_REGISTRY_RECEIVER", true);

        address expectedAuthor = _envAddressOr("EXPECTED_WORKFLOW_AUTHOR", address(0));
        bytes32 expectedWorkflowId = _envBytes32Or("EXPECTED_WORKFLOW_ID", bytes32(0));
        string memory expectedWorkflowName = _envStringOr("EXPECTED_WORKFLOW_NAME", "");

        require(operator != address(0), "OPERATOR is zero");
        require(forwarder != address(0), "CHAINLINK_FORWARDER resolved to zero");
        require(protocolFeeBps <= 10_000, "PROTOCOL_FEE_BPS > 10000");
        require(lpFeeShareBps <= 10_000, "LP_FEE_SHARE_BPS > 10000");
        require(creatorFeeShareBps <= 10_000, "CREATOR_FEE_SHARE_BPS > 10000");

        vm.startBroadcast();

        // 0) All mock tokens + Faucet (beta test only)
        d.mockUSDC = new MockUSDC();
        d.mockDAI = new MockDAI();
        d.mockUSDT = new MockUSDT();
        d.mockEURC = new MockEURC();
        d.mockAVAX = new MockAVAX();
        d.mockIDRX = new MockIDRX();
        d.faucet = new Faucet(msg.sender);

        _setupFaucetToken(d.faucet, address(d.mockUSDC), faucetAmountPerClaim, faucetMintSupply, faucetCooldownSecs);
        _setupFaucetToken(d.faucet, address(d.mockDAI), uint96(_amountWithDecimals(1000, 18)), _amountWithDecimals(1_000_000, 18), faucetCooldownSecs);
        _setupFaucetToken(d.faucet, address(d.mockUSDT), faucetAmountPerClaim, faucetMintSupply, faucetCooldownSecs);
        _setupFaucetToken(d.faucet, address(d.mockEURC), faucetAmountPerClaim, faucetMintSupply, faucetCooldownSecs);
        _setupFaucetToken(d.faucet, address(d.mockAVAX), uint96(_amountWithDecimals(1000, 18)), _amountWithDecimals(1_000_000, 18), faucetCooldownSecs);
        _setupFaucetToken(d.faucet, address(d.mockIDRX), uint96(_amountWithDecimals(1000, 18)), _amountWithDecimals(1_000_000, 18), faucetCooldownSecs);

        address settlementToken = address(d.mockUSDC);

        // 1) V3-Escrow Execution lane: OutcomeToken1155 + MarketRiskManager + escrow-safe vaults
        d.outcomeToken = new OutcomeToken1155("https://api.retropick.xyz/outcome/{id}.json");
        d.riskManager = new MarketRiskManager();
        d.multiAssetVault = new MultiAssetVault(address(0));
        d.collateralVault = new CollateralVault(settlementToken, address(0));
        d.channelSettlement = new ChannelSettlement(address(d.collateralVault), address(0), operator);
        d.marketRegistry = new MarketRegistry(address(d.collateralVault), address(0));

        d.outcomeToken.setChannelSettlement(address(d.channelSettlement));
        d.outcomeToken.setMarketRegistry(address(d.marketRegistry));
        d.riskManager.setChannelSettlement(address(d.channelSettlement));
        d.channelSettlement.setOutcomeToken(address(d.outcomeToken));
        d.channelSettlement.setRiskManager(address(d.riskManager));
        d.marketRegistry.setOutcomeToken(address(d.outcomeToken));
        d.multiAssetVault.setChannelSettlement(address(d.channelSettlement));
        d.multiAssetVault.setMarketRegistry(address(d.marketRegistry));
        d.collateralVault.setChannelSettlement(address(d.channelSettlement));
        d.collateralVault.setMarketRegistry(address(d.marketRegistry));
        d.channelSettlement.setMarketRegistry(address(d.marketRegistry));
        d.channelSettlement.setMultiAssetVault(address(d.multiAssetVault));
        d.marketRegistry.setMultiAssetVault(address(d.multiAssetVault));
        d.marketRegistry.setDefaultSettlementAsset(settlementToken);

        // 2) Fees
        d.feeManager = new FeeManager(protocolFeeBps);
        d.feePool = new FeePool();
        d.treasuryPool = new TreasuryPool();

        d.feeManager.setLpFeeShareBps(lpFeeShareBps);
        d.feeManager.setCreatorFeeShareBps(creatorFeeShareBps);
        d.feePool.setFeeCollector(address(d.channelSettlement));
        d.feePool.setTreasuryPool(address(d.treasuryPool));
        d.channelSettlement.setFeeManager(address(d.feeManager));
        d.channelSettlement.setFeePool(address(d.feePool));

        // 3) Oracle and routing
        d.reportValidator = new ReportValidator(minConfidence);
        d.oracleCoordinator = new OracleCoordinator();
        d.settlementRouter = new SettlementRouter();
        d.creReceiver = new CREReceiver(forwarder, address(d.oracleCoordinator));

        d.oracleCoordinator.setCreReceiver(address(d.creReceiver));
        d.oracleCoordinator.setSettlementRouter(address(d.settlementRouter));
        d.oracleCoordinator.setReportValidator(address(d.reportValidator));

        d.settlementRouter.setOracleCoordinator(address(d.oracleCoordinator));
        d.settlementRouter.setChannelSettlement(address(d.channelSettlement));
        d.settlementRouter.setUseReceiverAllowlist(useReceiverAllowlist);
        if (approveRegistryReceiver) {
            d.settlementRouter.setMarketReceiverApproved(address(d.marketRegistry), true);
        }
        d.marketRegistry.setSettlementRouter(address(d.settlementRouter));

        // 4) Curated lane
        d.marketPolicy = new MarketPolicy();
        d.draftBoard = new MarketDraftBoard();
        d.draftClaimManager = new DraftClaimManager(address(d.draftBoard));
        d.liquidityVaultFactory = new LiquidityVaultFactory(address(d.channelSettlement));
        d.marketFactory = new MarketFactory(forwarder, address(d.marketRegistry));
        d.crePublishReceiver = new CREPublishReceiver(
            forwarder,
            address(d.draftBoard),
            address(d.draftClaimManager),
            address(d.marketPolicy),
            address(d.marketFactory)
        );

        d.draftBoard.setDraftClaimManager(address(d.draftClaimManager));
        d.draftBoard.grantPublishCaller(address(d.marketFactory));

        address aiOracle = _envAddressOr("AI_ORACLE_ADDRESS", address(0));
        if (aiOracle != address(0)) {
            d.draftBoard.grantRole(d.draftBoard.AI_ORACLE_ROLE(), aiOracle);
        }
        d.draftClaimManager.setLiquidityVaultFactory(address(d.liquidityVaultFactory));

        d.marketFactory.setMarketRegistry(address(d.marketRegistry));
        d.marketFactory.setDraftBoard(address(d.draftBoard));
        d.marketFactory.setDraftClaimManager(address(d.draftClaimManager));
        d.marketFactory.setMarketPolicy(address(d.marketPolicy));
        d.marketFactory.setRiskManager(address(d.riskManager));
        d.marketFactory.setPublishReceiverApproved(address(d.crePublishReceiver), true);
        d.riskManager.setMarketFactory(address(d.marketFactory));

        d.marketRegistry.setMarketFactory(address(d.marketFactory));

        _configureReceiverTemplate(address(d.creReceiver), expectedAuthor, expectedWorkflowId, expectedWorkflowName);
        _configureReceiverTemplate(address(d.crePublishReceiver), expectedAuthor, expectedWorkflowId, expectedWorkflowName);
        _configureReceiverTemplate(address(d.marketFactory), expectedAuthor, expectedWorkflowId, expectedWorkflowName);

        vm.stopBroadcast();

        _log(d);
        return d;
    }

    function _setupFaucetToken(
        Faucet faucet,
        address token,
        uint96 amountPerClaim,
        uint256 mintSupply,
        uint32 cooldownSecs
    ) internal {
        (bool ok, ) = token.call(abi.encodeWithSignature("mint(address,uint256)", address(faucet), mintSupply));
        require(ok, "mint failed");
        faucet.setToken(token, true, amountPerClaim, cooldownSecs);
    }

    function _amountWithDecimals(uint256 amount, uint8 decimals) internal pure returns (uint256) {
        return amount * (10 ** decimals);
    }

    function _configureReceiverTemplate(
        address receiver,
        address expectedAuthor,
        bytes32 expectedWorkflowId,
        string memory expectedWorkflowName
    ) internal {
        if (expectedAuthor != address(0)) {
            (bool okAuthor, ) = receiver.call(abi.encodeWithSignature("setExpectedAuthor(address)", expectedAuthor));
            require(okAuthor, "setExpectedAuthor failed");
        }
        if (expectedWorkflowId != bytes32(0)) {
            (bool okWorkflowId, ) =
                receiver.call(abi.encodeWithSignature("setExpectedWorkflowId(bytes32)", expectedWorkflowId));
            require(okWorkflowId, "setExpectedWorkflowId failed");
        }
        if (bytes(expectedWorkflowName).length != 0) {
            (bool okWorkflowName, ) =
                receiver.call(abi.encodeWithSignature("setExpectedWorkflowName(string)", expectedWorkflowName));
            require(okWorkflowName, "setExpectedWorkflowName failed");
        }
    }

    function _log(Deployed memory d) internal view {
        console2.log("deployer", msg.sender);
        console2.log("MockUSDC", address(d.mockUSDC));
        console2.log("MockDAI", address(d.mockDAI));
        console2.log("MockUSDT", address(d.mockUSDT));
        console2.log("MockEURC", address(d.mockEURC));
        console2.log("MockAVAX", address(d.mockAVAX));
        console2.log("MockIDRX", address(d.mockIDRX));
        console2.log("Faucet", address(d.faucet));
        console2.log("OutcomeToken1155", address(d.outcomeToken));
        console2.log("MarketRiskManager", address(d.riskManager));
        console2.log("ChannelSettlement", address(d.channelSettlement));
        console2.log("MultiAssetVault", address(d.multiAssetVault));
        console2.log("CollateralVault", address(d.collateralVault));
        console2.log("MarketRegistry", address(d.marketRegistry));
        console2.log("FeeManager", address(d.feeManager));
        console2.log("FeePool", address(d.feePool));
        console2.log("TreasuryPool", address(d.treasuryPool));
        console2.log("ReportValidator", address(d.reportValidator));
        console2.log("CREReceiver", address(d.creReceiver));
        console2.log("OracleCoordinator", address(d.oracleCoordinator));
        console2.log("SettlementRouter", address(d.settlementRouter));
        console2.log("MarketPolicy", address(d.marketPolicy));
        console2.log("MarketDraftBoard", address(d.draftBoard));
        console2.log("DraftClaimManager", address(d.draftClaimManager));
        console2.log("LiquidityVaultFactory", address(d.liquidityVaultFactory));
        console2.log("MarketFactory", address(d.marketFactory));
        console2.log("CREPublishReceiver", address(d.crePublishReceiver));
        console2.log("");
        console2.log("--- Beta test flow ---");
        console2.log("   1. faucet.claim(mockUSDC|mockDAI|mockUSDT|mockEURC|mockAVAX|mockIDRX)");
        console2.log("   2. multiAssetVault.deposit(settlementToken, amount)");
        console2.log("   3. trade (checkpoint submit reserves; finalize releases)");
        console2.log("");
        console2.log("--- Escrow (V3-Escrow) ---");
        console2.log("   Reserve on submit, release on finalize/cancel. CANCEL_DELAY=6h for stuck pending.");
        console2.log("");
        console2.log("--- Post-deploy checklist ---");
        console2.log("1. Relayer (apps/relayer/.env): CHANNEL_SETTLEMENT_ADDRESS=%s", address(d.channelSettlement));
        console2.log("2. CRE workflows: CREReceiver=%s, CREPublishReceiver=%s, MarketFactory=%s",
            address(d.creReceiver), address(d.crePublishReceiver), address(d.marketFactory));
    }

    function _envAddressReq(string memory key) internal view returns (address) {
        try vm.envAddress(key) returns (address v) {
            return v;
        } catch {
            revert(string.concat("Missing/invalid env address: ", key));
        }
    }

    function _envAddressOr(string memory key, address fallback_) internal view returns (address) {
        try vm.envAddress(key) returns (address v) {
            return v;
        } catch {
            return fallback_;
        }
    }

    function _envUintReq(string memory key) internal view returns (uint256) {
        try vm.envUint(key) returns (uint256 v) {
            return v;
        } catch {
            revert(string.concat("Missing/invalid env uint: ", key));
        }
    }

    function _envUintOr(string memory key, uint256 fallback_) internal view returns (uint256) {
        try vm.envUint(key) returns (uint256 v) {
            return v;
        } catch {
            return fallback_;
        }
    }

    function _envBoolOr(string memory key, bool fallback_) internal view returns (bool) {
        try vm.envBool(key) returns (bool v) {
            return v;
        } catch {
            return fallback_;
        }
    }

    function _envBytes32Or(string memory key, bytes32 fallback_) internal view returns (bytes32) {
        try vm.envBytes32(key) returns (bytes32 v) {
            return v;
        } catch {
            return fallback_;
        }
    }

    function _envStringOr(string memory key, string memory fallback_) internal view returns (string memory) {
        try vm.envString(key) returns (string memory v) {
            return v;
        } catch {
            return fallback_;
        }
    }

    function _resolveForwarder() internal view returns (address forwarder) {
        string memory raw;
        try vm.envString("CHAINLINK_FORWARDER") returns (string memory v) {
            raw = v;
        } catch {
            revert("Missing env: CHAINLINK_FORWARDER");
        }
        bytes memory b = bytes(raw);
        if (b.length == 0) revert("CHAINLINK_FORWARDER is empty");
        if (b[0] == bytes1("$")) {
            string memory key = _slice(raw, 1, b.length - 1);
            forwarder = _envAddressReq(key);
            return forwarder;
        }
        forwarder = vm.parseAddress(raw);
    }

    function _slice(string memory s, uint256 start, uint256 len) internal pure returns (string memory) {
        bytes memory b = bytes(s);
        bytes memory out = new bytes(len);
        for (uint256 i = 0; i < len; i++) out[i] = b[start + i];
        return string(out);
    }
}
