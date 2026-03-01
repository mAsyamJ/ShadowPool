# CRE Workflow: Publish from Draft

**Last updated:** 2026-03-01  
**Context:** [CREOverview.md](CREOverview.md) | [CREPipelineDiagram.md](CREPipelineDiagram.md)

---

## 1. Overview

The publish workflow creates a market from a claimed draft. The creator (claimer) signs EIP-712 `PublishFromDraft`; the workflow encodes the payload and sends it to **CREPublishReceiver**. The workflow must target CREPublishReceiver (different receiver than CREReceiver).

---

## 2. Prerequisites

- Draft must be **Claimed** (via `DraftClaimManager.claimAndSeed` or `claimDraft`)
- Creator must match `DraftClaimManager.getClaimer(draftId)`
- Creator signs `PublishFromDraft` EIP-712 typed data

---

## 3. EIP-712 PublishFromDraft

**Domain:** `CREPublishReceiver` v1  
**Type:** `PublishFromDraft(bytes32 draftId, bytes32 paramsHash, uint256 chainId, uint256 nonce)`

- `paramsHash` = `keccak256(abi.encode(question, marketType, keccak256(outcomes), keccak256(timelineWindows), resolveTime, tradingOpen, tradingClose))`
- `nonce` = `CREPublishReceiver.publishNonces(creator)` (increment after successful publish)

---

## 4. Payload Encoding

```
0x04 || abi.encode(bytes32 draftId, address creator, DraftPublishParams params, bytes claimerSig)
```

**DraftPublishParams:**

```solidity
struct DraftPublishParams {
    string question;
    uint8 marketType;
    string[] outcomes;
    uint48[] timelineWindows;
    uint48 resolveTime;
    uint48 tradingOpen;
    uint48 tradingClose;
}
```

| marketType | Meaning |
|------------|---------|
| 0 | Binary |
| 1 | Categorical (outcomes array) |
| 2 | Timeline (timelineWindows array) |

**Note:** CREPublishReceiver accepts payload with or without `0x04` prefix; if `report[0] == 0x04`, it uses `report[1:]`.

---

## 5. Flow

1. **Creator** signs `PublishFromDraft` (EIP-712)
2. **Workflow** receives signed params (HTTP, queue, etc.)
3. **Encode** — `abi.encode(draftId, creator, params, claimerSig)`
4. **Submit** — `evmClient.writeReport(0x04 || payload)`
5. **Target** — Workflow must be configured to send to **CREPublishReceiver** (not CREReceiver)
6. **CREPublishReceiver** validates:
   - `DraftBoard.getStatus(draftId) == Claimed`
   - `DraftClaimManager.getClaimer(draftId) == creator`
   - Signature recovers to creator
7. **MarketFactory.createFromDraft** creates market, sets liquidity vault, risk cap, etc.

---

## 6. Validation Errors

| Error | Cause |
|-------|-------|
| `DraftNotClaimed` | Draft status is not Claimed |
| `InvalidCreator` | Creator does not match claimer |
| `InvalidSignature` | EIP-712 signature does not recover to creator |

---

## 7. Configuration

| Variable | Description |
|----------|-------------|
| Receiver | Workflow must target **CREPublishReceiver** |
| Forwarder | Same Forwarder can be used; workflow config selects receiver |

---

## 8. References

- [CREPipelineDiagram.md](CREPipelineDiagram.md) — Publish sequence diagram
- [CREReportFormats.md](CREReportFormats.md) — Publish payload schema
- [CREContractReference.md](CREContractReference.md) — CREPublishReceiver validation
- [CurrentSmartContract.md](../CurrentSmartContract.md) §6.2 — Curated claim-and-seed + publish flow
