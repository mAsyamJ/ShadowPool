# ChannelSettlement – Frontend Integration

Last updated: 2026-03-01  
ABI: `ChannelSettlement.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`ChannelSettlement` manages checkpoint-based settlement for offchain trading. It receives checkpoint payloads from the relayer (via CRE), validates operator and user signatures, and applies share/cash deltas to **OutcomeToken1155** (V3) and vaults. Vaults use 3-bucket escrow (free, reserved, available); reserves are applied on submit and released on finalize. Frontend prompts users to sign checkpoint digests; relayer submits.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Checkpoint signing | Trader | Sign digest when relayer requests |
| Session state | Trader | Display session state from relayer |
| Nonce check | Operator / dev | `latestNonce` for checkpoint tracking |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `latestNonce` | `uint256 marketId`, `bytes32 sessionId` | `uint64` | Track finalized nonces; relayer logic |
| `latestNonceByKey` | `bytes32 key` | `uint64` | Alternative keyed lookup |
| `pendingByKey` | `bytes32 key` | `Pending` tuple | Pending checkpoint info |
| `digestCheckpoint` | `Checkpoint cp` | `bytes32` | EIP-712 digest (can compute client-side) |
| `eip712Domain` | — | `EIP712Domain` | EIP-712 domain for signing |
| `CHALLENGE_WINDOW_SECONDS` | — | `uint32` | Challenge window |
| `MAX_DELTAS` | — | `uint32` | Max deltas per checkpoint |
| `MAX_USERS` | — | `uint32` | Max signers |
| `outcomeToken` | — | `address` | OutcomeToken1155 (V3); 0 = legacy |
| `LEDGER` | — | `address` | ExecutionLedger (legacy; 0 when OutcomeToken used) |
| `VAULT` | — | `address` | CollateralVault |
| `multiAssetVault` | — | `address` | MultiAssetVault if used |
| `marketRegistry` | — | `address` | MarketRegistry |
| `operator` | — | `address` | Operator (relayer-side) |
| `feeManager` | — | `address` | FeeManager |
| `feePool` | — | `address` | FeePool |

---

## 4. Write Methods (Frontend)

None. `submitCheckpoint`, `submitCheckpointFromPayload`, `challengeCheckpoint`, `finalizeCheckpoint` are called by relayer/operator via CRE. Frontend only signs digests and POSTs to relayer.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `CheckpointSubmitted` | `marketId`, `sessionId` | Pending checkpoint |
| `CheckpointFinalized` | `marketId`, `sessionId` | Positions/cash updated; refresh positions and balances |
| `CheckpointChallenged` | `marketId`, `sessionId` | Challenge submitted |
| `EIP712DomainChanged` | — | Rare |
| `FeeManagerUpdated` | `previous`, `current` | Admin |
| `FeePoolUpdated` | `previous`, `current` | Admin |
| `MarketRegistryUpdated` | `previous`, `current` | Admin |
| `MultiAssetVaultUpdated` | `previous`, `current` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `BadDeltasHash` | Checkpoint data mismatch |
| `BadOperatorSig` | Invalid operator signature |
| `BadUserSig` | Invalid user signature |
| `DeltaUserNotSigned` | All delta users must sign |
| `DuplicateUsers` | Duplicate signers |
| `ChallengeWindow` | Outside challenge window |
| `ChallengeNotNewer` | Challenge must use newer checkpoint |
| `CheckpointAfterTradingClose` | Checkpoint after trading close |
| `NonceNotIncreasing` | Stale nonce |
| `TooEarly` | Not yet valid |
| `TooLate` | Window passed |
| `WindowPassed` | Challenge window passed |
| `NoPending` | No pending checkpoint |
| `NoPendingToChallenge` | Nothing to challenge |
| `MarketAlreadyResolved` | Market already resolved |
| `LiquidityVaultRequired` | LP vault required |
| `InvalidLiquidityVaultAsset` | LP vault asset mismatch |
| `TooManyDeltas` | Too many deltas |
| `TooManyUsers` | Too many users |
| `SigLenMismatch` | Signature length mismatch |
| `ECDSAInvalidSignature` | Invalid signature |
| `InvalidAddress` | Invalid address |
| `InvalidShortString` / `StringTooLong` | Config error |
| `OwnableUnauthorizedAccount` | Unauthorized |
| `SafeCastOverflowedIntToUint` | Internal error |

---

## 7. Integration Notes

### Relayer Flow

1. Relayer `GET /cre/checkpoints/:sessionId` returns checkpoint spec including digest.
2. Frontend prompts user to sign digest (EIP-712).
3. User signs; frontend `POST /cre/checkpoints/:sessionId` with `userSigs`.
4. Relayer builds payload, sends to CRE → `submitCheckpointFromPayload`.

### Checkpoint Struct (ShadowTypes)

```
Checkpoint: marketId, sessionId, nonce, validAfter, validBefore, lastTradeAt, stateHash, deltasHash, riskHash
Delta: user, outcomeIndex, sharesDelta, cashDelta
```

### UX

- Integrate with relayer; show "Sign checkpoint" when relayer requests.
- Display session state from relayer, not from chain.
- After `CheckpointFinalized`, refresh `OutcomeToken1155.balanceOf` and vault balances (`freeBalance`, `reservedBalance`, `availableBalance`).
- **Deployment config key**: `ChannelSettlement`

---

## 8. References

- [OutcomeToken1155.md](OutcomeToken1155.md) — Position mint/burn (V3)
- [MarketRiskManager.md](MarketRiskManager.md) — LP payout cap (V3)
- [CollateralVault.md](CollateralVault.md) / [MultiAssetVault.md](MultiAssetVault.md) — Cash updates, 3-bucket escrow
- [RelayerIntegration.md](RelayerIntegration.md) — Relayer integration
- [AppFlow.md](AppFlow.md) — Trader flow
