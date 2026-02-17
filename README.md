## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

Two deployment scripts:

**1. Demo (PoolMarketLegacy, full onchain)**
```shell
$ forge script script/DeployDemo.s.sol:DeployDemo --rpc-url <RPC> --broadcast
```
Env: `PRIVATE_KEY`, `CHAINLINK_FORWARDER`, `SETTLEMENT_TOKEN` (ERC20 address). Optional: `MIN_CONFIDENCE`, `USE_RECEIVER_ALLOWLIST`.

**2. Production (MarketRegistry, relayer + CRE)**
```shell
$ forge script script/DeployTestnet.s.sol:DeployTestnet --rpc-url <RPC> --broadcast
```
Env: see script. After deploy, set `CHANNEL_SETTLEMENT_ADDRESS` and `OPERATOR` in `apps/relayer/.env`.

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Production Mode

For production deployment:

- **Curated publish required**: Markets must be created via the curated pipeline (proposeDraft → claimAndSeed → publish). Legacy `claimDraft` (no seed) cannot publish.
- **Legacy pool lane**: The PoolMarketLegacy lane is demo-only and should not be wired in production deploy config.
- **Seeded claim**: All curated markets require `claimAndSeed`; seed shares are locked in DraftClaimManager until tradingClose.
- See `.docs/Invariants.md` for formal invariant list.


Here’s how these pieces fit together:

---

## What `PoolMarketLegacy` Does

`PoolMarketLegacy` is a **pool-based** prediction market and a **legacy/demo** path. From its docstring:

> "Optional demo: pool-based prediction market with pro-rata claim. Uses pool LS-LSMR; for **ShadowPool path use MarketRegistry + ExecutionLedger**."

It behaves like this:

1. **Token custody** – Holds ERC20 tokens directly; users send tokens to the contract when they predict.
2. **Pool model** – Maintains `totalYesPool`, `totalNoPool` (binary) or `categoricalPools` / `timelinePools` (typed markets).
3. **Pro‑rata payouts** – Winners split the pool according to their share:  
   `payout = (userAmount * totalPool) / winningPool`
4. **CRE receiver** – Extends `ReceiverTemplate`; can create markets or settle them based on reports.
5. **No ExecutionLedger** – Positions and settlements live inside `PoolMarketLegacy` itself.

---

## How It Relates to `MarketRegistry` and `MarketFactory`

There are **two** market implementations that both talk to `MarketFactory`:

| | **PoolMarketLegacy** (legacy) | **MarketRegistry** (main path) |
|---|---|---|
| **Collateral** | Held inside the contract | In `CollateralVault` / `MultiAssetVault` |
| **Positions** | Internal mappings | `ExecutionLedger` |
| **Trading** | Direct `predict()` / `reducePosition()` on the contract | Checkpoint-based flow via `ChannelSettlement` |
| **Redemption** | `claim()` from internal pools | `redeem()` via ledger + vault |

### `MarketFactory`

`MarketFactory` uses an `IPredictionMarket` whose address is set at deploy:

- `PREDICTION_MARKET` can be **either**:
  - `PoolMarketLegacy` (legacy/demo)
  - `MarketRegistry` (main ShadowPool path)

When handling CRE reports (e.g. `_processReport`), it calls `PREDICTION_MARKET.createMarketForWithExpiry()` and similar methods. So whether it creates pool-based or registry-based markets depends on that configuration.

### Curated path

For curated markets via `createFromDraft()`, `MarketFactory` always uses `marketRegistry` (i.e. `MarketRegistry`) and not `PoolMarketLegacy`:

```250:262:src/core/MarketFactory.sol
    function createFromDraft(
        bytes32 draftId,
        address creator,
        DraftPublishParams calldata params
    ) external returns (uint256 marketId) {
        if (!approvedPublishReceivers[msg.sender]) revert UnauthorizedPublishReceiver();
        if (address(marketRegistry) == address(0)) revert CuratedPathNotConfigured();
        if (address(draftBoard) == address(0)) revert CuratedPathNotConfigured();
        // ...
        if (params.marketType == MARKET_TYPE_BINARY) {
            marketId = marketRegistry.createMarketForWithFullParams(
```

Curated drafts always go through `MarketRegistry`.

---

## Summary

- **Yes**, the main production market flow is handled by **`MarketRegistry`** and **`MarketFactory`** (plus ExecutionLedger, vaults, etc.).
- **`PoolMarketLegacy`** is a separate, simpler pool-based implementation that:
  - Implements the same `IPredictionMarket` creation interface
  - Can act as `PREDICTION_MARKET` for CRE-created markets if so configured
  - Holds and settles positions internally instead of using `ExecutionLedger` + vaults

From the docs: *"The PoolMarketLegacy lane is demo-only and should not be wired in production deploy config."* So production should use `MarketRegistry` + `MarketFactory` (+ ExecutionLedger), and `PoolMarketLegacy` is kept for demos and tests.