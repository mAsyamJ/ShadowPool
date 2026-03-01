# EIP-712 Signing Reference (Frontend)

**Last updated:** 2026-03-01  
**Audience:** Frontend engineers implementing signature flows  
**Context:** [CheckpointEIP712.md](../relayer/CheckpointEIP712.md) | [Frontend.md](Frontend.md)

---

## 1. Overview

RetroPick uses **EIP-712 typed data signing** for three frontend flows:

| Flow | Contract / Verifying | When |
|------|----------------------|------|
| **ClaimAndSeed** | DraftClaimManager | Creator claims draft and seeds liquidity |
| **PublishFromDraft** | CREPublishReceiver | Creator authorizes publish (when backend requests) |
| **Checkpoint** | ChannelSettlement | Traders sign checkpoint (when relayer requests) |

---

## 2. ClaimAndSeed (DraftClaimManager)

### 2.1 Domain

| Field | Value |
|-------|-------|
| `name` | `DraftClaimManager` |
| `version` | `1` |
| `chainId` | Deployment chain ID (e.g. 43113) |
| `verifyingContract` | DraftClaimManager contract address |

### 2.2 Type String

```
ClaimAndSeed(bytes32 draftId,address asset,uint256 seedAmount,uint256 deadline,uint256 nonce)
```

### 2.3 Params

| Param | Type | Description |
|-------|------|-------------|
| `draftId` | bytes32 | Draft identifier from MarketDraftBoard |
| `asset` | address | Settlement token (must match draft.settlementAsset) |
| `seedAmount` | uint256 | Amount to seed (>= draft.minSeed) |
| `deadline` | uint256 | 0 = no expiry; or Unix timestamp |
| `nonce` | uint256 | From `DraftClaimManager.nonces(signer)` |

### 2.4 Flow

1. **Get nonce:** `draftClaimManager.nonces(user)`
2. **Build typed data** with domain and struct
3. **Sign** with user's wallet (ethers `signTypedData` / viem `signTypedData`)
4. **Call** `draftClaimManager.claimAndSeed(draftId, asset, seedAmount, deadline, sig)`
5. **Pre-requisites:** `asset.approve(DraftClaimManager, seedAmount)` before claimAndSeed

### 2.5 Digest Helper (Optional)

Contract exposes `digestClaimAndSeed(draftId, asset, seedAmount, deadline, signer)` for testing. Frontend typically builds and signs client-side.

---

## 3. PublishFromDraft (CREPublishReceiver)

### 3.1 Domain

| Field | Value |
|-------|-------|
| `name` | `CREPublishReceiver` |
| `version` | `1` |
| `chainId` | Deployment chain ID |
| `verifyingContract` | CREPublishReceiver contract address |

### 3.2 Type String

```
PublishFromDraft(bytes32 draftId,bytes32 paramsHash,uint256 chainId,uint256 nonce)
```

### 3.3 Params

| Param | Type | Description |
|-------|------|-------------|
| `draftId` | bytes32 | Draft identifier |
| `paramsHash` | bytes32 | `keccak256(abi.encode(question, marketType, keccak256(outcomes), keccak256(timelineWindows), resolveTime, tradingOpen, tradingClose))` |
| `chainId` | uint256 | Same as domain chainId |
| `nonce` | uint256 | From `CREPublishReceiver.publishNonces(creator)` |

### 3.4 Flow

- **Backend-driven:** Creator signs when relayer/backend requests publish
- **Get nonce:** `crePublishReceiver.publishNonces(creator)`
- Frontend builds typed data and returns signature
- Backend sends report to CRE workflow; CRE delivers to Forwarder → CREPublishReceiver

### 3.5 Digest Helper (Optional)

Contract exposes `digestPublishFromDraft(draftId, paramsHash, signer)` for verification.

---

## 4. Checkpoint (ChannelSettlement)

### 4.1 Domain

| Field | Value |
|-------|-------|
| `name` | `ShadowPool` |
| `version` | `1` |
| `chainId` | Deployment chain ID |
| `verifyingContract` | ChannelSettlement contract address |

### 4.2 Type String

```
Checkpoint(uint256 marketId,bytes32 sessionId,uint64 nonce,uint64 validAfter,uint64 validBefore,uint48 lastTradeAt,bytes32 stateHash,bytes32 deltasHash,bytes32 riskHash)
```

### 4.3 Flow

- **Frontend does NOT build the digest.** Relayer provides it via `GET /cre/checkpoints/:sessionId`.
- **Response** includes: `digest`, `users`, `chainId`, `channelSettlementAddress`
- **User signs** the digest with their wallet (personal_sign of digest, or EIP-712 with the full Checkpoint struct)
- **Send signatures** to `POST /cre/checkpoints/:sessionId` with body `{ userSigs: { [address]: "0x..." } }`
- Relayer combines operator sig + user sigs and returns `0x03`-prefixed payload for CRE

### 4.4 Delta (For Reference)

```
Delta(address user,uint32 outcomeIndex,int128 sharesDelta,int128 cashDelta)
```

`deltasHash` in Checkpoint = `keccak256(concat(hash(Delta_0), hash(Delta_1), ...))`. Frontend does not compute this; relayer does.

### 4.5 Full Spec

See [CheckpointEIP712.md](../relayer/CheckpointEIP712.md) for struct definitions, delta hashing, and on-chain guarantees.

---

## 5. Quick Reference (viem / ethers)

### ClaimAndSeed (viem)

```ts
import { signTypedData } from 'viem/accounts';

const domain = {
  name: 'DraftClaimManager',
  version: '1',
  chainId: 43113,
  address: DRAFT_CLAIM_MANAGER_ADDRESS,
};

const types = {
  ClaimAndSeed: [
    { name: 'draftId', type: 'bytes32' },
    { name: 'asset', type: 'address' },
    { name: 'seedAmount', type: 'uint256' },
    { name: 'deadline', type: 'uint256' },
    { name: 'nonce', type: 'uint256' },
  ],
};

const message = { draftId, asset, seedAmount, deadline, nonce };
const sig = await signTypedData({ domain, types, primaryType: 'ClaimAndSeed', message });
```

### Checkpoint (viem)

```ts
// Digest comes from relayer GET /cre/checkpoints/:sessionId
// Option 1: Sign the digest directly (some wallets)
const sig = await signMessage({ message: { raw: digest } });

// Option 2: Sign typed data (recommended for better UX)
const domain = {
  name: 'ShadowPool',
  version: '1',
  chainId: chainId,
  address: channelSettlementAddress,
};
const types = {
  Checkpoint: [
    { name: 'marketId', type: 'uint256' },
    { name: 'sessionId', type: 'bytes32' },
    { name: 'nonce', type: 'uint64' },
    { name: 'validAfter', type: 'uint64' },
    { name: 'validBefore', type: 'uint64' },
    { name: 'lastTradeAt', type: 'uint48' },
    { name: 'stateHash', type: 'bytes32' },
    { name: 'deltasHash', type: 'bytes32' },
    { name: 'riskHash', type: 'bytes32' },
  ],
};
const sig = await signTypedData({ domain, types, primaryType: 'Checkpoint', message: checkpoint });
```

---

## 6. References

- [CheckpointEIP712.md](../relayer/CheckpointEIP712.md) — Full checkpoint spec
- [FrontendIntegration.md](../relayer/FrontendIntegration.md) — Checkpoint signing flow
- [DraftClaimManager.md](DraftClaimManager.md) — ClaimAndSeed integration
- [DeploymentConfig.md](DeploymentConfig.md) — Contract addresses
