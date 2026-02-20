# CREPublishReceiver – Frontend Integration

Last updated: 2026-02-20  
ABI: `CREPublishReceiver.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`CREPublishReceiver` is the CRE workflow receiver for market publish from draft. It verifies the creator's EIP-712 `PublishFromDraft` signature and calls `MarketFactory.createFromDraft`. Publish is backend-driven; frontend signs when relayer requests.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Publish signature | Creator | Sign `PublishFromDraft` when backend/relayer requests |
| Nonce lookup | Creator | `publishNonces(creator)` for EIP-712 |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `publishNonces` | `address creator` | `uint256` | EIP-712 nonce for `PublishFromDraft` |
| `digestPublishFromDraft` | `draftId`, `paramsHash`, `signer` | `bytes32` | EIP-712 digest (optional) |
| `PUBLISH_FROM_DRAFT_TYPEHASH` | — | `bytes32` | EIP-712 type hash |
| `eip712Domain` | — | `EIP712Domain` | EIP-712 domain |
| `DRAFT_BOARD` | — | `address` | MarketDraftBoard |
| `DRAFT_CLAIM_MANAGER` | — | `address` | DraftClaimManager |
| `MARKET_FACTORY` | — | `address` | MarketFactory |
| `MARKET_POLICY` | — | `address` | MarketPolicy |
| `getForwarderAddress` | — | `address` | CRE forwarder |
| `getExpectedAuthor` | — | `address` | Optional workflow author |
| `getExpectedWorkflowId` | — | `bytes32` | Optional workflow ID |
| `getExpectedWorkflowName` | — | `bytes10` | Optional workflow name |
| `owner` | — | `address` | Admin |

---

## 4. Write Methods (Frontend)

None. `onReport` is called by CRE/relayer. Creator signs offchain; backend submits.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `DraftPublished` | `draftId`, `creator`, `marketId` | Draft went live; update status, show market link |
| `EIP712DomainChanged` | — | Rare |
| `ExpectedAuthorUpdated` | `previousAuthor`, `newAuthor` | Admin |
| `ExpectedWorkflowIdUpdated` | `previousId`, `newId` | Admin |
| `ExpectedWorkflowNameUpdated` | `previousName`, `newName` | Admin |
| `ForwarderAddressUpdated` | `previousForwarder`, `newForwarder` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |
| `SecurityWarning` | — | Security notice |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `DraftNotClaimed` | Draft must be claimed before publish |
| `InvalidCreator` | Creator signature mismatch |
| `InvalidSignature` | Signature invalid or expired; try again |
| `InvalidParamsHash` | Invalid publish params |
| `InvalidSender` | Invalid CRE sender |
| `InvalidForwarderAddress` | Invalid forwarder |
| `InvalidAuthor` | Author validation failed |
| `InvalidWorkflowId` | Workflow ID mismatch |
| `InvalidWorkflowName` | Workflow name mismatch |
| `ECDSAInvalidSignature` | Invalid signature |
| `OwnableUnauthorizedAccount` | Unauthorized |
| `WorkflowNameRequiresAuthorValidation` | Config error |

---

## 7. Integration Notes

### EIP-712 PublishFromDraft

- **Domain**: `CREPublishReceiver`, version `1`
- **TypeHash**: `PublishFromDraft(bytes32 draftId,bytes32 paramsHash,uint256 chainId,uint256 nonce)`
- **Nonce**: `crePublishReceiver.publishNonces(creator)`
- **Flow**: Backend/relayer requests signature; frontend signs when prompted. `paramsHash` and `chainId` come from relayer.

### UX

- Show "Pending publish" or link to CRE workflow if user is creator.
- Subscribe to `DraftPublished` to update draft status and show market link.
- Typically not deployed-address config for frontend (relayer handles CRE); optional for wallet/signing UX.

---

## 8. References

- [DraftClaimManager.md](DraftClaimManager.md) — Claim before publish
- [MarketFactory.md](MarketFactory.md) — `createFromDraft`
- [MarketDraftBoard.md](MarketDraftBoard.md) — Draft status
- [AppFlow.md](AppFlow.md) — Creator flow
