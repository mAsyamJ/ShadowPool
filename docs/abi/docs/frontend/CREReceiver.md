# CREReceiver – Frontend Integration

Last updated: 2026-02-20  
ABI: `CREReceiver.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`CREReceiver` is the oracle ingress for Chainlink CRE. It receives reports from the forwarder and forwards to `OracleCoordinator`. It does not store state; it routes payloads. Backend/infrastructure only.

---

## 2. Frontend Relevance

**Backend / Oracle only.** Frontend does not interact with this contract. Documented for completeness and architecture reference.

---

## 3. Read Methods (Frontend)

None used by frontend. Config getters (`getForwarderAddress`, `getExpectedAuthor`, `getExpectedWorkflowId`, `getExpectedWorkflowName`, `oracleCoordinator`) are for deployment verification.

---

## 4. Write Methods (Frontend)

None. `onReport` is called by Chainlink CRE/forwarder.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `ExpectedAuthorUpdated` | `previousAuthor`, `newAuthor` | Admin |
| `ExpectedWorkflowIdUpdated` | `previousId`, `newId` | Admin |
| `ExpectedWorkflowNameUpdated` | `previousName`, `newName` | Admin |
| `ForwarderAddressUpdated` | `previousForwarder`, `newForwarder` | Admin |
| `OracleCoordinatorUpdated` | `previous`, `current` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |
| `SecurityWarning` | — | Security |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
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

- No frontend integration.
- Part of oracle pipeline: Forwarder → CREReceiver → OracleCoordinator → SettlementRouter.

---

## 8. References

- [OracleCoordinator.md](OracleCoordinator.md) — Next in pipeline
- [CurrentSmartContract.md](../CurrentSmartContract.md) — Oracle topology
- [AppFlow.md](AppFlow.md) — Resolution flow
