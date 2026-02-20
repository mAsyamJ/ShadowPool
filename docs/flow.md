Market Type: (PoolMarketLegacy (Demo Onchain Full No Offchain Engine) + MarketFactory)

[PASS] testCategoricalMarketCreation() (gas: 655984)
Logs:
  [TEST] testCategoricalMarketCreation
  [ARRANGE] Build categorical market report with 3 outcomes
  [ACT] Forwarder submits create-market report
  [ASSERT] Market stored as categorical and outcome pools accept liquidity

Traces:
  [675884] MarketTypesTest::testCategoricalMarketCreation()
    ├─ [0] console::log("[TEST] testCategoricalMarketCreation") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Build categorical market report with 3 outcomes") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ACT] Forwarder submits create-market report") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [414322] MarketFactory::onReport(0x, 0x0200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000140000000000000000000000000000000000000000000000000000000000000beef00000000000000000000000000000000000000000000000000000000000007d0000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000001c06361742d31000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000036000000000000000000000000000000000000000000000000000000000000000105768696368207465616d2077696e733f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000673706f7274730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000464656d6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000014100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [235477] PoolMarketLegacy::createCategoricalMarketForWithExpiry("Which team wins?", ["A", "B", "C"], 0x000000000000000000000000000000000000bEEF, 2000)
    │   │   ├─ emit MarketCreated(marketId: 0, question: "Which team wins?", creator: 0x000000000000000000000000000000000000bEEF)
    │   │   ├─ emit MarketCreatedTyped(marketId: 0, marketType: 1, outcomesCount: 3)
    │   │   └─ ← [Return] 0
    │   ├─ emit MarketSpawned(marketId: 0, requestedBy: 0x000000000000000000000000000000000000bEEF, question: "Which team wins?", resolveTime: 2000, category: "sports", source: "demo", externalId: 0x6361742d31000000000000000000000000000000000000000000000000000000)
    │   ├─ emit MarketSpawnedTyped(marketId: 0, requestedBy: 0x000000000000000000000000000000000000bEEF, marketType: 1, outcomesCount: 3, externalId: 0x6361742d31000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Market stored as categorical and outcome pools accept liquidity") [staticcall]
    │   └─ ← [Stop]
    ├─ [1534] PoolMarketLegacy::getMarketType(0) [staticcall]
    │   └─ ← [Return] 1
    ├─ [5449] PoolMarketLegacy::getCategoricalOutcomes(0) [staticcall]
    │   └─ ← [Return] ["A", "B", "C"]
    ├─ [49997] 0x3600000000000000000000000000000000000000::mint(0x000000000000000000000000000000000000cafE, 1000000000000000000 [1e18])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x000000000000000000000000000000000000cafE, value: 1000000000000000000 [1e18])
    │   └─ ← [Return]
    ├─ [0] VM::startPrank(0x000000000000000000000000000000000000cafE)
    │   └─ ← [Return]
    ├─ [26927] 0x3600000000000000000000000000000000000000::approve(PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 100000000000000000 [1e17])
    │   ├─ emit Approval(owner: 0x000000000000000000000000000000000000cafE, spender: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 100000000000000000 [1e17])
    │   └─ ← [Return] true
    ├─ [110114] PoolMarketLegacy::predictOutcome(0, 1, 100000000000000000 [1e17])
    │   ├─ [32255] 0x3600000000000000000000000000000000000000::transferFrom(0x000000000000000000000000000000000000cafE, PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 100000000000000000 [1e17])
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000cafE, to: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 100000000000000000 [1e17])
    │   │   └─ ← [Return] true
    │   ├─ emit PredictionMadeTyped(marketId: 0, predictor: 0x000000000000000000000000000000000000cafE, outcomeIndex: 1, amount: 100000000000000000 [1e17])
    │   └─ ← [Return]
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return]
    ├─ [3606] PoolMarketLegacy::getCategoricalPools(0) [staticcall]
    │   └─ ← [Return] [0, 100000000000000000 [1e17], 0]
    └─ ← [Return]


[PASS] testTimelineMarketCreation() (gas: 411235)
Logs:
  [TEST] testTimelineMarketCreation
  [ARRANGE] Build timeline market report with 2 windows
  [ACT] Forwarder submits create-market report
  [ASSERT] Market stored as timeline with expected windows

Traces:
  [411235] MarketTypesTest::testTimelineMarketCreation()
    ├─ [0] console::log("[TEST] testTimelineMarketCreation") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Build timeline market report with 2 windows") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ACT] Forwarder submits create-market report") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [364746] MarketFactory::onReport(0x, 0x0200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000140000000000000000000000000000000000000000000000000000000000000beef0000000000000000000000000000000000000000000000000000000000000dac000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000001c074696d652d3100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002200000000000000000000000000000000000000000000000000000000000000280000000000000000000000000000000000000000000000000000000000000001b5768656e2077696c6c20746865206576656e742068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000874696d656c696e65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000464656d6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000007d00000000000000000000000000000000000000000000000000000000000000bb80000000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [187318] PoolMarketLegacy::createTimelineMarketForWithExpiry("When will the event happen?", [2000, 3000], 0x000000000000000000000000000000000000bEEF, 3500)
    │   │   ├─ emit MarketCreated(marketId: 0, question: "When will the event happen?", creator: 0x000000000000000000000000000000000000bEEF)
    │   │   ├─ emit MarketCreatedTyped(marketId: 0, marketType: 2, outcomesCount: 2)
    │   │   └─ ← [Return] 0
    │   ├─ emit MarketSpawned(marketId: 0, requestedBy: 0x000000000000000000000000000000000000bEEF, question: "When will the event happen?", resolveTime: 3500, category: "timeline", source: "demo", externalId: 0x74696d652d310000000000000000000000000000000000000000000000000000)
    │   ├─ emit MarketSpawnedTyped(marketId: 0, requestedBy: 0x000000000000000000000000000000000000bEEF, marketType: 2, outcomesCount: 2, externalId: 0x74696d652d310000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Market stored as timeline with expected windows") [staticcall]
    │   └─ ← [Stop]
    ├─ [1534] PoolMarketLegacy::getMarketType(0) [staticcall]
    │   └─ ← [Return] 2
    ├─ [3330] PoolMarketLegacy::getTimelineWindows(0) [staticcall]
    │   └─ ← [Return] [2000, 3000]
    └─ ← [Return]

Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 3.93ms (1.14ms CPU time)

Ran 1 test for test/OracleFlow.t.sol:OracleFlowTest
[PASS] testSettlementViaCREReceiver() (gas: 136522)
Logs:
  [TEST] testSettlementViaCREReceiver
  [ARRANGE] Build CRE settlement report for marketId=0 outcome=0 confidence=9000
  [ACT] Forwarder submits report to CREReceiver
  [ACT] Read settled market state
  [ASSERT] Market settled with expected confidence and outcome

Traces:
  [136522] OracleFlowTest::testSettlementViaCREReceiver()
    ├─ [0] console::log("[TEST] testSettlementViaCREReceiver") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Build CRE settlement report for marketId=0 outcome=0 confidence=9000") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ACT] Forwarder submits report to CREReceiver") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [99083] CREReceiver::onReport(0x, 0x000000000000000000000000c7183455a4c133ae270771860664b6b7ec320bb1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002328)
    │   ├─ [82266] OracleCoordinator::submitResult(PoolMarketLegacy: [0xc7183455a4C133Ae270771860664b6B7ec320bB1], 0, 0, 9000)
    │   │   ├─ [70060] SettlementRouter::settleMarket(PoolMarketLegacy: [0xc7183455a4C133Ae270771860664b6B7ec320bB1], 0, 0, 9000)
    │   │   │   ├─ [56119] PoolMarketLegacy::onReport(0x, 0x01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002328)
    │   │   │   │   ├─ emit MarketSettled(marketId: 0, outcome: 0, confidence: 9000)
    │   │   │   │   └─ ← [Return]
    │   │   │   ├─ emit MarketSettled(market: PoolMarketLegacy: [0xc7183455a4C133Ae270771860664b6B7ec320bB1], marketId: 0, outcomeIndex: 0, confidence: 9000)
    │   │   │   └─ ← [Return]
    │   │   └─ ← [Return]
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Read settled market state") [staticcall]
    │   └─ ← [Stop]
    ├─ [7025] PoolMarketLegacy::getMarket(0) [staticcall]
    │   └─ ← [Return] 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000007fa9385be102ac3eac297483dd6233d62b3e149600000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000023280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000001657696c6c204254432062652061626f76652035306b3f00000000000000000000
    ├─ [0] console::log("[ASSERT] Market settled with expected confidence and outcome") [staticcall]
    │   └─ ← [Stop]
    └─ ← [Return]

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 2.67ms (699.46µs CPU time)

Ran 5 tests for test/SecurityHardening.t.sol:SecurityHardeningTest
[PASS] testCheckpointWithUnsignedDeltaUserReverts() (gas: 93169)
Logs:
  [TEST] testCheckpointWithUnsignedDeltaUserReverts
  [ARRANGE] Checkpoint includes delta for attacker without attacker signature
  [ASSERT] submitCheckpoint reverts with DeltaUserNotSigned

Traces:
  [93169] SecurityHardeningTest::testCheckpointWithUnsignedDeltaUserReverts()
    ├─ [0] console::log("[TEST] testCheckpointWithUnsignedDeltaUserReverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Checkpoint includes delta for attacker without attacker signature") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xbdad60f24ca2145538d5e4531143833b0a59c4ea0f55b80e657bcdff8a896d9d, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xcf14be1bcdc7c7e4bb3328ef440624f762abda12920be0da2650032ac3ae647e
    ├─ [0] VM::sign("<pk>", 0xcf14be1bcdc7c7e4bb3328ef440624f762abda12920be0da2650032ac3ae647e) [staticcall]
    │   └─ ← [Return] 28, 0x43f9ecc4e659a64d5c84fe2753fce1908ec4c140032919fb9c08efbc5f6217a2, 0x6c276ee98dc5f022bdf40417a51a9c92d2211fe9dd175c8fd94cb7da2014a7f0
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xbdad60f24ca2145538d5e4531143833b0a59c4ea0f55b80e657bcdff8a896d9d, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xcf14be1bcdc7c7e4bb3328ef440624f762abda12920be0da2650032ac3ae647e
    ├─ [0] VM::sign("<pk>", 0xcf14be1bcdc7c7e4bb3328ef440624f762abda12920be0da2650032ac3ae647e) [staticcall]
    │   └─ ← [Return] 28, 0xe2814841d8b3ce10f09521af43ff014f26c465614c537cbd161f269eb3b085a4, 0x5965287e7cce761f6cd731f209a1792ca496e65fe779c4c83d853f2628a93a25
    ├─ [0] console::log("[ASSERT] submitCheckpoint reverts with DeltaUserNotSigned") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: 7359f00900000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [32301] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xbdad60f24ca2145538d5e4531143833b0a59c4ea0f55b80e657bcdff8a896d9d, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 }), Delta({ user: 0x0000000000000000000000000000000000000666, outcomeIndex: 0, sharesDelta: 5, cashDelta: -50 })], 0x43f9ecc4e659a64d5c84fe2753fce1908ec4c140032919fb9c08efbc5f6217a26c276ee98dc5f022bdf40417a51a9c92d2211fe9dd175c8fd94cb7da2014a7f01c, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xe2814841d8b3ce10f09521af43ff014f26c465614c537cbd161f269eb3b085a45965287e7cce761f6cd731f209a1792ca496e65fe779c4c83d853f2628a93a251c])
    │   ├─ [3000] PRECOMPILES::ecrecover(0xcf14be1bcdc7c7e4bb3328ef440624f762abda12920be0da2650032ac3ae647e, 28, 30746539894754761851147496174192480054732338624855988350248740417416428918690, 48919460171215307449212800370135844807305943646131409196022725637640304240624) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0xcf14be1bcdc7c7e4bb3328ef440624f762abda12920be0da2650032ac3ae647e, 28, 102451125752129540101190075796242712154703456140508406980428818392024813176228, 40434574557404134533597148332594074390711040323164371949437279487074465561125) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   └─ ← [Revert] DeltaUserNotSigned()
    └─ ← [Return]

[PASS] testFinalizeCheckpointAfterTradingCloseWithLastTradeAtReverts() (gas: 304491)
Logs:
  [TEST] testFinalizeCheckpointAfterTradingCloseWithLastTradeAtReverts
  [ARRANGE] Market has tradingClose=600, checkpoint lastTradeAt=700
  [ACT] Submit checkpoint and warp past challenge window
  [ASSERT] Finalization reverts because lastTradeAt is after market close

Traces:
  [304491] SecurityHardeningTest::testFinalizeCheckpointAfterTradingCloseWithLastTradeAtReverts()
    ├─ [0] console::log("[TEST] testFinalizeCheckpointAfterTradingCloseWithLastTradeAtReverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Market has tradingClose=600, checkpoint lastTradeAt=700") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::warp(500)
    │   └─ ← [Return]
    ├─ [87816] MarketRegistry::createMarketWithExpiry("Market with close", 600)
    │   ├─ emit MarketCreated(marketId: 1, question: "Market with close", creator: SecurityHardeningTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 1
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 700, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xd11a16bdecd14b318a77218dbc87ac1214e5fb22a5f7d4e1ee69e702ed9a4e67
    ├─ [0] VM::sign("<pk>", 0xd11a16bdecd14b318a77218dbc87ac1214e5fb22a5f7d4e1ee69e702ed9a4e67) [staticcall]
    │   └─ ← [Return] 28, 0xab0f69711329b8de55705dd8caef9003eb50b5aab417a33c240b5db1de1de27a, 0x6992339b34b0eedb14e5315af7889060ba3b8ab2ccc7b7a82fb7130dc7977fa4
    ├─ [0] console::log("[ACT] Submit checkpoint and warp past challenge window") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 700, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xd11a16bdecd14b318a77218dbc87ac1214e5fb22a5f7d4e1ee69e702ed9a4e67
    ├─ [0] VM::sign("<pk>", 0xd11a16bdecd14b318a77218dbc87ac1214e5fb22a5f7d4e1ee69e702ed9a4e67) [staticcall]
    │   └─ ← [Return] 27, 0xabe764240725fce388035fc689a0e6c3712736ead29ca83b67d1f35faf5ea22c, 0x11fb0176965d5b0c54e104c8bb2e017608f0dc7bb3b657b16d55f3c7f68e58d5
    ├─ [129878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 700, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })], 0xabe764240725fce388035fc689a0e6c3712736ead29ca83b67d1f35faf5ea22c11fb0176965d5b0c54e104c8bb2e017608f0dc7bb3b657b16d55f3c7f68e58d51b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xab0f69711329b8de55705dd8caef9003eb50b5aab417a33c240b5db1de1de27a6992339b34b0eedb14e5315af7889060ba3b8ab2ccc7b7a82fb7130dc7977fa41c])
    │   ├─ [3000] PRECOMPILES::ecrecover(0xd11a16bdecd14b318a77218dbc87ac1214e5fb22a5f7d4e1ee69e702ed9a4e67, 27, 77754329925647931601233351333614666131360167756168823510901436268270378197548, 8132807138030204623420972554720139660750814305114196154578526968775887968469) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0xd11a16bdecd14b318a77218dbc87ac1214e5fb22a5f7d4e1ee69e702ed9a4e67, 28, 77372727545568711609628972637655312766472555234177463964924062510501416788602, 47751164946105059812159796946060232482105364966111546697834230424771424124836) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a)
    │   └─ ← [Return]
    ├─ [0] VM::warp(2360)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Finalization reverts because lastTradeAt is after market close") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: df256dd000000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [21286] ChannelSettlement::finalizeCheckpoint(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })])
    │   ├─ [6243] MarketRegistry::status(1) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1798] MarketRegistry::getTradingClose(1) [staticcall]
    │   │   └─ ← [Return] 600
    │   └─ ← [Revert] CheckpointAfterTradingClose()
    └─ ← [Return]

[PASS] testMarketRegistryResolveUnauthorizedReverts() (gas: 24888)
Logs:
  [TEST] testMarketRegistryResolveUnauthorizedReverts
  [ASSERT] Non-router caller cannot resolve market

Traces:
  [24888] SecurityHardeningTest::testMarketRegistryResolveUnauthorizedReverts()
    ├─ [0] console::log("[TEST] testMarketRegistryResolveUnauthorizedReverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ASSERT] Non-router caller cannot resolve market") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000000666)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: 6fdfe14100000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [3655] MarketRegistry::resolve(0, 0, 9000)
    │   └─ ← [Revert] UnauthorizedRouter()
    └─ ← [Return]

[PASS] testReportValidatorSetMinConfidenceUnauthorizedReverts() (gas: 22002)
Logs:
  [TEST] testReportValidatorSetMinConfidenceUnauthorizedReverts
  [ASSERT] Unauthorized caller cannot change confidence threshold

Traces:
  [22002] SecurityHardeningTest::testReportValidatorSetMinConfidenceUnauthorizedReverts()
    ├─ [0] console::log("[TEST] testReportValidatorSetMinConfidenceUnauthorizedReverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ASSERT] Unauthorized caller cannot change confidence threshold") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000000666)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xf4844814)
    │   └─ ← [Return]
    ├─ [3199] ReportValidator::setMinConfidence(5000)
    │   └─ ← [Revert] OwnableUnauthorizedAccount(0x0000000000000000000000000000000000000666)
    └─ ← [Return]

[PASS] testTreasurySetMarketApprovedUnauthorizedReverts() (gas: 22587)
Logs:
  [TEST] testTreasurySetMarketApprovedUnauthorizedReverts
  [ASSERT] Unauthorized caller cannot approve market in treasury

Traces:
  [22587] SecurityHardeningTest::testTreasurySetMarketApprovedUnauthorizedReverts()
    ├─ [0] console::log("[TEST] testTreasurySetMarketApprovedUnauthorizedReverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ASSERT] Unauthorized caller cannot approve market in treasury") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000000666)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xf4844814)
    │   └─ ← [Return]
    ├─ [3448] Treasury::setMarketApproved(ECRecover: [0x0000000000000000000000000000000000000001], true)
    │   └─ ← [Revert] OwnableUnauthorizedAccount(0x0000000000000000000000000000000000000666)
    └─ ← [Return]

Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 9.12ms (4.04ms CPU time)

Ran 5 tests for test/PoolMarketTrading.t.sol:PoolMarketTradingTest
[PASS] testAddToPosition() (gas: 172622)
Logs:
  [TEST] testAddToPosition
  [ARRANGE] User opens YES position in two increments
  [ACT] Load stored user prediction
  [ASSERT] Amount = 10 ether and prediction = YES

Traces:
  [192522] PoolMarketTradingTest::testAddToPosition()
    ├─ [0] console::log("[TEST] testAddToPosition") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] User opens YES position in two increments") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startPrank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 10000000000000000000 [1e19])
    │   ├─ emit Approval(owner: 0x000000000000000000000000000000000000bEEF, spender: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 10000000000000000000 [1e19])
    │   └─ ← [Return] true
    ├─ [105684] PoolMarketLegacy::predict(0, 0, 5000000000000000000 [5e18])
    │   ├─ [37055] ERC20Mock::transferFrom(0x000000000000000000000000000000000000bEEF, PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 5000000000000000000 [5e18])
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000bEEF, to: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 5000000000000000000 [5e18])
    │   │   └─ ← [Return] true
    │   ├─ emit PredictionMade(marketId: 0, predictor: 0x000000000000000000000000000000000000bEEF, prediction: 0, amount: 5000000000000000000 [5e18])
    │   └─ ← [Return]
    ├─ [23110] PoolMarketLegacy::predict(0, 0, 5000000000000000000 [5e18])
    │   ├─ [10355] ERC20Mock::transferFrom(0x000000000000000000000000000000000000bEEF, PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 5000000000000000000 [5e18])
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000bEEF, to: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 5000000000000000000 [5e18])
    │   │   └─ ← [Return] true
    │   ├─ emit PredictionMade(marketId: 0, predictor: 0x000000000000000000000000000000000000bEEF, prediction: 0, amount: 5000000000000000000 [5e18])
    │   └─ ← [Return]
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Load stored user prediction") [staticcall]
    │   └─ ← [Stop]
    ├─ [3775] PoolMarketLegacy::getPrediction(0, 0x000000000000000000000000000000000000bEEF) [staticcall]
    │   └─ ← [Return] UserPrediction({ amount: 10000000000000000000 [1e19], prediction: 0, claimed: false })
    ├─ [0] console::log("[ASSERT] Amount = 10 ether and prediction = YES") [staticcall]
    │   └─ ← [Stop]
    └─ ← [Return]

[PASS] testReducePosition() (gas: 177188)
Logs:
  [TEST] testReducePosition
  [ARRANGE] User opens 10 ether YES position
  [ACT] User reduces position by 4 ether
  [ASSERT] Wallet refunded by 4 ether
  [ASSERT] Remaining position is 6 ether

Traces:
  [197088] PoolMarketTradingTest::testReducePosition()
    ├─ [0] console::log("[TEST] testReducePosition") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] User opens 10 ether YES position") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 10000000000000000000 [1e19])
    │   ├─ emit Approval(owner: 0x000000000000000000000000000000000000bEEF, spender: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 10000000000000000000 [1e19])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [105684] PoolMarketLegacy::predict(0, 0, 10000000000000000000 [1e19])
    │   ├─ [37055] ERC20Mock::transferFrom(0x000000000000000000000000000000000000bEEF, PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 10000000000000000000 [1e19])
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000bEEF, to: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 10000000000000000000 [1e19])
    │   │   └─ ← [Return] true
    │   ├─ emit PredictionMade(marketId: 0, predictor: 0x000000000000000000000000000000000000bEEF, prediction: 0, amount: 10000000000000000000 [1e19])
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] User reduces position by 4 ether") [staticcall]
    │   └─ ← [Stop]
    ├─ [1240] ERC20Mock::balanceOf(0x000000000000000000000000000000000000bEEF) [staticcall]
    │   └─ ← [Return] 90000000000000000000 [9e19]
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [19370] PoolMarketLegacy::reducePosition(0, 4000000000000000000 [4e18])
    │   ├─ [7301] ERC20Mock::transfer(0x000000000000000000000000000000000000bEEF, 4000000000000000000 [4e18])
    │   │   ├─ emit Transfer(from: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], to: 0x000000000000000000000000000000000000bEEF, value: 4000000000000000000 [4e18])
    │   │   └─ ← [Return] true
    │   ├─ emit PositionReduced(marketId: 0, user: 0x000000000000000000000000000000000000bEEF, amount: 4000000000000000000 [4e18])
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Wallet refunded by 4 ether") [staticcall]
    │   └─ ← [Stop]
    ├─ [1240] ERC20Mock::balanceOf(0x000000000000000000000000000000000000bEEF) [staticcall]
    │   └─ ← [Return] 94000000000000000000 [9.4e19]
    ├─ [3775] PoolMarketLegacy::getPrediction(0, 0x000000000000000000000000000000000000bEEF) [staticcall]
    │   └─ ← [Return] UserPrediction({ amount: 6000000000000000000 [6e18], prediction: 0, claimed: false })
    ├─ [0] console::log("[ASSERT] Remaining position is 6 ether") [staticcall]
    │   └─ ← [Stop]
    └─ ← [Return]

[PASS] testRevertWhenAddingToDifferentOutcome() (gas: 171514)
Logs:
  [TEST] testRevertWhenAddingToDifferentOutcome
  [ARRANGE] User already has YES position
  [ASSERT] Adding to NO without closing should revert

Traces:
  [171514] PoolMarketTradingTest::testRevertWhenAddingToDifferentOutcome()
    ├─ [0] console::log("[TEST] testRevertWhenAddingToDifferentOutcome") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] User already has YES position") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 20000000000000000000 [2e19])
    │   ├─ emit Approval(owner: 0x000000000000000000000000000000000000bEEF, spender: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 20000000000000000000 [2e19])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [105684] PoolMarketLegacy::predict(0, 0, 5000000000000000000 [5e18])
    │   ├─ [37055] ERC20Mock::transferFrom(0x000000000000000000000000000000000000bEEF, PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 5000000000000000000 [5e18])
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000bEEF, to: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 5000000000000000000 [5e18])
    │   │   └─ ← [Return] true
    │   ├─ emit PredictionMade(marketId: 0, predictor: 0x000000000000000000000000000000000000bEEF, prediction: 0, amount: 5000000000000000000 [5e18])
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Adding to NO without closing should revert") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: 02affbde00000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [7399] PoolMarketLegacy::predict(0, 1, 5000000000000000000 [5e18])
    │   └─ ← [Revert] WrongOutcomeToAdd()
    └─ ← [Return]

[PASS] testRevertWhenReducingMoreThanPosition() (gas: 171202)
Logs:
  [TEST] testRevertWhenReducingMoreThanPosition
  [ARRANGE] User position size is only 5 ether
  [ASSERT] Reducing by 10 ether should revert

Traces:
  [171202] PoolMarketTradingTest::testRevertWhenReducingMoreThanPosition()
    ├─ [0] console::log("[TEST] testRevertWhenReducingMoreThanPosition") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] User position size is only 5 ether") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 10000000000000000000 [1e19])
    │   ├─ emit Approval(owner: 0x000000000000000000000000000000000000bEEF, spender: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 10000000000000000000 [1e19])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [105684] PoolMarketLegacy::predict(0, 0, 5000000000000000000 [5e18])
    │   ├─ [37055] ERC20Mock::transferFrom(0x000000000000000000000000000000000000bEEF, PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 5000000000000000000 [5e18])
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000bEEF, to: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 5000000000000000000 [5e18])
    │   │   └─ ← [Return] true
    │   ├─ emit PredictionMade(marketId: 0, predictor: 0x000000000000000000000000000000000000bEEF, prediction: 0, amount: 5000000000000000000 [5e18])
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Reducing by 10 ether should revert") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: e616ad6f00000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [7146] PoolMarketLegacy::reducePosition(0, 10000000000000000000 [1e19])
    │   └─ ← [Revert] CannotReduceMoreThanPosition()
    └─ ← [Return]

[PASS] testSwitchOutcome() (gas: 243942)
Logs:
  [TEST] testSwitchOutcome
  [ARRANGE] User opens YES then fully exits
  [ACT] User calls reduceAll then opens NO
  [ASSERT] New active side is NO with 10 ether

Traces:
  [310193] PoolMarketTradingTest::testSwitchOutcome()
    ├─ [0] console::log("[TEST] testSwitchOutcome") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] User opens YES then fully exits") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startPrank(0x000000000000000000000000000000000000bEEF)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 20000000000000000000 [2e19])
    │   ├─ emit Approval(owner: 0x000000000000000000000000000000000000bEEF, spender: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 20000000000000000000 [2e19])
    │   └─ ← [Return] true
    ├─ [105684] PoolMarketLegacy::predict(0, 0, 10000000000000000000 [1e19])
    │   ├─ [37055] ERC20Mock::transferFrom(0x000000000000000000000000000000000000bEEF, PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 10000000000000000000 [1e19])
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000bEEF, to: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 10000000000000000000 [1e19])
    │   │   └─ ← [Return] true
    │   ├─ emit PredictionMade(marketId: 0, predictor: 0x000000000000000000000000000000000000bEEF, prediction: 0, amount: 10000000000000000000 [1e19])
    │   └─ ← [Return]
    ├─ [1240] ERC20Mock::balanceOf(0x000000000000000000000000000000000000bEEF) [staticcall]
    │   └─ ← [Return] 90000000000000000000 [9e19]
    ├─ [0] console::log("[ACT] User calls reduceAll then opens NO") [staticcall]
    │   └─ ← [Stop]
    ├─ [21051] PoolMarketLegacy::reduceAll(0)
    │   ├─ [7301] ERC20Mock::transfer(0x000000000000000000000000000000000000bEEF, 10000000000000000000 [1e19])
    │   │   ├─ emit Transfer(from: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], to: 0x000000000000000000000000000000000000bEEF, value: 10000000000000000000 [1e19])
    │   │   └─ ← [Return] true
    │   ├─ emit PositionReduced(marketId: 0, user: 0x000000000000000000000000000000000000bEEF, amount: 10000000000000000000 [1e19])
    │   └─ ← [Return]
    ├─ [1240] ERC20Mock::balanceOf(0x000000000000000000000000000000000000bEEF) [staticcall]
    │   └─ ← [Return] 100000000000000000000 [1e20]
    ├─ [5027] ERC20Mock::approve(PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 10000000000000000000 [1e19])
    │   ├─ emit Approval(owner: 0x000000000000000000000000000000000000bEEF, spender: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 10000000000000000000 [1e19])
    │   └─ ← [Return] true
    ├─ [105596] PoolMarketLegacy::predict(0, 1, 10000000000000000000 [1e19])
    │   ├─ [33055] ERC20Mock::transferFrom(0x000000000000000000000000000000000000bEEF, PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 10000000000000000000 [1e19])
    │   │   ├─ emit Transfer(from: 0x000000000000000000000000000000000000bEEF, to: PoolMarketLegacy: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 10000000000000000000 [1e19])
    │   │   └─ ← [Return] true
    │   ├─ emit PredictionMade(marketId: 0, predictor: 0x000000000000000000000000000000000000bEEF, prediction: 1, amount: 10000000000000000000 [1e19])
    │   └─ ← [Return]
    ├─ [3775] PoolMarketLegacy::getPrediction(0, 0x000000000000000000000000000000000000bEEF) [staticcall]
    │   └─ ← [Return] UserPrediction({ amount: 10000000000000000000 [1e19], prediction: 1, claimed: false })
    ├─ [0] console::log("[ASSERT] New active side is NO with 10 ether") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return]
    └─ ← [Return]

Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 3.03ms (1.94ms CPU time)

Ran 3 tests for test/SessionRouting.t.sol:SessionRoutingTest
[PASS] testCheckpointPayloadFormatMatchesRelayer() (gas: 211209)
Traces:
  [211209] SessionRoutingTest::testCheckpointPayloadFormatMatchesRelayer()
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4
    ├─ [0] VM::sign("<pk>", 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4) [staticcall]
    │   └─ ← [Return] 28, 0x767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca, 0x2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d1
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4
    ├─ [0] VM::sign("<pk>", 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4) [staticcall]
    │   └─ ← [Return] 27, 0x0b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c, 0x616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa7
    ├─ [0] VM::prank(SessionRoutingTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [155088] OracleCoordinator::submitSession(0x0000000000000000000000000000000000000000000000000000000000000001a126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b745162e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c0000000000000000000000000000000000000000000000000000000000000041767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000410b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa71b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [145790] SettlementRouter::finalizeSession(0x0000000000000000000000000000000000000000000000000000000000000001a126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b745162e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c0000000000000000000000000000000000000000000000000000000000000041767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000410b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa71b00000000000000000000000000000000000000000000000000000000000000)
    │   │   ├─ [128453] ChannelSettlement::submitCheckpointFromPayload(0x0000000000000000000000000000000000000000000000000000000000000001a126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b745162e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c0000000000000000000000000000000000000000000000000000000000000041767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000410b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa71b00000000000000000000000000000000000000000000000000000000000000)
    │   │   │   ├─ [3000] PRECOMPILES::ecrecover(0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4, 28, 53598038521640554411406135118449954544263646385050991467621094336244956677578, 21424417104736893420410307230812482419295114173610071292905019091936050835921) [staticcall]
    │   │   │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   │   │   ├─ [3000] PRECOMPILES::ecrecover(0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4, 27, 5107403379825242405129151382906429494015936803711937322932505995132124222092, 44068229510042763926665699961569091541194834407980331943327981044441562987175) [staticcall]
    │   │   │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   │   │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a)
    │   │   │   └─ ← [Return]
    │   │   ├─ emit SessionPayloadRouted(target: ChannelSettlement: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9], payloadHash: 0x3bb4534befccb05dac30fcbe21ee6aaccbd286f0e215a5f8339f54926c4faa42, marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, routeType: 1)
    │   │   └─ ← [Return]
    │   └─ ← [Return]
    └─ ← [Return]

[PASS] testSessionPayloadRoutedEventEmitted() (gas: 219145)
Logs:
  [TEST] testSessionPayloadRoutedEventEmitted
  [ARRANGE] Build signed checkpoint payload for coordinator session submit
  [ACT] Submit payload via OracleCoordinator
  [ASSERT] Session payload is accepted and routed

Traces:
  [219145] SessionRoutingTest::testSessionPayloadRoutedEventEmitted()
    ├─ [0] console::log("[TEST] testSessionPayloadRoutedEventEmitted") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Build signed checkpoint payload for coordinator session submit") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4
    ├─ [0] VM::sign("<pk>", 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4) [staticcall]
    │   └─ ← [Return] 28, 0x767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca, 0x2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d1
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4
    ├─ [0] VM::sign("<pk>", 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4) [staticcall]
    │   └─ ← [Return] 27, 0x0b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c, 0x616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa7
    ├─ [0] console::log("[ACT] Submit payload via OracleCoordinator") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(SessionRoutingTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [155088] OracleCoordinator::submitSession(0x0000000000000000000000000000000000000000000000000000000000000001a126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b745162e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c0000000000000000000000000000000000000000000000000000000000000041767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000410b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa71b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [145790] SettlementRouter::finalizeSession(0x0000000000000000000000000000000000000000000000000000000000000001a126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b745162e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c0000000000000000000000000000000000000000000000000000000000000041767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000410b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa71b00000000000000000000000000000000000000000000000000000000000000)
    │   │   ├─ [128453] ChannelSettlement::submitCheckpointFromPayload(0x0000000000000000000000000000000000000000000000000000000000000001a126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b745162e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c0000000000000000000000000000000000000000000000000000000000000041767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000410b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa71b00000000000000000000000000000000000000000000000000000000000000)
    │   │   │   ├─ [3000] PRECOMPILES::ecrecover(0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4, 28, 53598038521640554411406135118449954544263646385050991467621094336244956677578, 21424417104736893420410307230812482419295114173610071292905019091936050835921) [staticcall]
    │   │   │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   │   │   ├─ [3000] PRECOMPILES::ecrecover(0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4, 27, 5107403379825242405129151382906429494015936803711937322932505995132124222092, 44068229510042763926665699961569091541194834407980331943327981044441562987175) [staticcall]
    │   │   │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   │   │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a)
    │   │   │   └─ ← [Return]
    │   │   ├─ emit SessionPayloadRouted(target: ChannelSettlement: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9], payloadHash: 0x3bb4534befccb05dac30fcbe21ee6aaccbd286f0e215a5f8339f54926c4faa42, marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, routeType: 1)
    │   │   └─ ← [Return]
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Session payload is accepted and routed") [staticcall]
    │   └─ ← [Stop]
    └─ ← [Return]

[PASS] testSessionPayloadRoutedViaRouterDirect() (gas: 218017)
Logs:
  [TEST] testSessionPayloadRoutedViaRouterDirect
  [ARRANGE] Build signed payload and expect SessionPayloadRouted event
  [ACT] Coordinator calls router.finalizeSession(payload)
  [ASSERT] SessionPayloadRouted emitted with expected payload hash and nonce

Traces:
  [218017] SessionRoutingTest::testSessionPayloadRoutedViaRouterDirect()
    ├─ [0] console::log("[TEST] testSessionPayloadRoutedViaRouterDirect") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Build signed payload and expect SessionPayloadRouted event") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4
    ├─ [0] VM::sign("<pk>", 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4) [staticcall]
    │   └─ ← [Return] 28, 0x767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca, 0x2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d1
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4
    ├─ [0] VM::sign("<pk>", 0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4) [staticcall]
    │   └─ ← [Return] 27, 0x0b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c, 0x616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa7
    ├─ [0] console::log("[ACT] Coordinator calls router.finalizeSession(payload)") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(OracleCoordinator: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [0] VM::expectEmit(true, true, true, true)
    │   └─ ← [Return]
    ├─ emit SessionPayloadRouted(target: ChannelSettlement: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9], payloadHash: 0x3bb4534befccb05dac30fcbe21ee6aaccbd286f0e215a5f8339f54926c4faa42, marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, routeType: 1)
    ├─ [145790] SettlementRouter::finalizeSession(0x0000000000000000000000000000000000000000000000000000000000000001a126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b745162e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c0000000000000000000000000000000000000000000000000000000000000041767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000410b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa71b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [128453] ChannelSettlement::submitCheckpointFromPayload(0x0000000000000000000000000000000000000000000000000000000000000001a126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000069e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b745162e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c0000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000affffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9c0000000000000000000000000000000000000000000000000000000000000041767f6a2d7e14cd28e24a024bc1997d27a1bbd3fe20fb295b74e8b9d09c8a45ca2f5dca54ff71b598161c32538db152340ebe56b58339c4c16f314a8a286671d11c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000410b4ab0184e0d9b83a8a902d391f1465a582fe6b4825a975023454f051aa7528c616dbbe77c4d5d85e396c038b6a1fa21ad2d8579cde36ff6d0859319b357baa71b00000000000000000000000000000000000000000000000000000000000000)
    │   │   ├─ [3000] PRECOMPILES::ecrecover(0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4, 28, 53598038521640554411406135118449954544263646385050991467621094336244956677578, 21424417104736893420410307230812482419295114173610071292905019091936050835921) [staticcall]
    │   │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   │   ├─ [3000] PRECOMPILES::ecrecover(0x4af0879ebc3df75b79a9fbbb720bdd3430d5f0bd8b5656753e71ebfad2017cd4, 27, 5107403379825242405129151382906429494015936803711937322932505995132124222092, 44068229510042763926665699961569091541194834407980331943327981044441562987175) [staticcall]
    │   │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a)
    │   │   └─ ← [Return]
    │   ├─ emit SessionPayloadRouted(target: ChannelSettlement: [0x5991A2dF15A8F6A256D3Ec51E99254Cd3fb576A9], payloadHash: 0x3bb4534befccb05dac30fcbe21ee6aaccbd286f0e215a5f8339f54926c4faa42, marketId: 1, sessionId: 0xa126c7206b7a866626647e00848a075c2f62fa0f6e661a7ce2910723f9cb6730, routeType: 1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] SessionPayloadRouted emitted with expected payload hash and nonce") [staticcall]
    │   └─ ← [Stop]
    └─ ← [Return]

Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 10.36ms (7.87ms CPU time)

Ran 1 test for test/YellowSessionFlow.t.sol:YellowSessionFlowTest
[PASS] testSessionFinalizationViaCREReceiver() (gas: 285883)
Logs:
  [TEST] testSessionFinalizationViaCREReceiver
  [ARRANGE] Build session payload with 2 participants + backend signature
  [ACT] Send type-0x03 report through CREReceiver
  [ASSERT] Finalizer transfers exact balances to participants

Traces:
  [285883] YellowSessionFlowTest::testSessionFinalizationViaCREReceiver()
    ├─ [0] console::log("[TEST] testSessionFinalizationViaCREReceiver") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Build session payload with 2 participants + backend signature") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::sign("<pk>", 0x41b9aabf3bfa155388345a4f98abf29040ff9ad4f2c09b640d6fa7df8d3733c8) [staticcall]
    │   └─ ← [Return] 28, 0xded90b1a4c256fe86b6436a90f8374255814a13ecf36c11d1dc3ca654c5b93d5, 0x7b031961a73a17f0ec6efe145a41ad4f2db8fceb51788f5e58fcb8dd386b9f5c
    ├─ [0] VM::sign("<pk>", 0x6bd6d8ad0a0b3601e264a568a2f7a39a66f732e38001e4b4c79ee353949625bb) [staticcall]
    │   └─ ← [Return] 27, 0x3bcb57b3e782f937d63da78e5f7b1a8643e126c881e29059dbfad44564d291b6, 0x5296b78bb8cb648161de1f70db669fa387a81e6805e4ab3f9fed652353a79562
    ├─ [0] VM::sign("<pk>", 0x9951e799658ab3a32a13a3fb0fb8ebc9d3ef655a6c4459c2ba705f364f4850f1) [staticcall]
    │   └─ ← [Return] 27, 0xaeb7d09dccc43fae99c376e661b5fc9fb7ff0523467a066c0efd9b7804aa9c96, 0x6020bdc946cfada70c0c756761c41c68a11829e93e5bd7110f67708bd14912be
    ├─ [49997] ERC20Mock::mint(SessionFinalizer: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 10000000000000000000 [1e19])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: SessionFinalizer: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], value: 10000000000000000000 [1e19])
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Send type-0x03 report through CREReceiver") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [163768] CREReceiver::onReport(0x, 0x030000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000179656c6c6f772d73657373696f6e2d310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c000000000000000000000000f5a5e415061470a8b9137959180901aea72450a400000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000001bc16d674ec8000000000000000000000000000000000000000000000000000029a2241af62c00000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000041ded90b1a4c256fe86b6436a90f8374255814a13ecf36c11d1dc3ca654c5b93d57b031961a73a17f0ec6efe145a41ad4f2db8fceb51788f5e58fcb8dd386b9f5c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000413bcb57b3e782f937d63da78e5f7b1a8643e126c881e29059dbfad44564d291b65296b78bb8cb648161de1f70db669fa387a81e6805e4ab3f9fed652353a795621b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041aeb7d09dccc43fae99c376e661b5fc9fb7ff0523467a066c0efd9b7804aa9c966020bdc946cfada70c0c756761c41c68a11829e93e5bd7110f67708bd14912be1b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [147551] OracleCoordinator::submitSession(0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000179656c6c6f772d73657373696f6e2d310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c000000000000000000000000f5a5e415061470a8b9137959180901aea72450a400000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000001bc16d674ec8000000000000000000000000000000000000000000000000000029a2241af62c00000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000041ded90b1a4c256fe86b6436a90f8374255814a13ecf36c11d1dc3ca654c5b93d57b031961a73a17f0ec6efe145a41ad4f2db8fceb51788f5e58fcb8dd386b9f5c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000413bcb57b3e782f937d63da78e5f7b1a8643e126c881e29059dbfad44564d291b65296b78bb8cb648161de1f70db669fa387a81e6805e4ab3f9fed652353a795621b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041aeb7d09dccc43fae99c376e661b5fc9fb7ff0523467a066c0efd9b7804aa9c966020bdc946cfada70c0c756761c41c68a11829e93e5bd7110f67708bd14912be1b00000000000000000000000000000000000000000000000000000000000000)
    │   │   ├─ [138265] SettlementRouter::finalizeSession(0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000179656c6c6f772d73657373696f6e2d310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c000000000000000000000000f5a5e415061470a8b9137959180901aea72450a400000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000001bc16d674ec8000000000000000000000000000000000000000000000000000029a2241af62c00000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000041ded90b1a4c256fe86b6436a90f8374255814a13ecf36c11d1dc3ca654c5b93d57b031961a73a17f0ec6efe145a41ad4f2db8fceb51788f5e58fcb8dd386b9f5c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000413bcb57b3e782f937d63da78e5f7b1a8643e126c881e29059dbfad44564d291b65296b78bb8cb648161de1f70db669fa387a81e6805e4ab3f9fed652353a795621b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041aeb7d09dccc43fae99c376e661b5fc9fb7ff0523467a066c0efd9b7804aa9c966020bdc946cfada70c0c756761c41c68a11829e93e5bd7110f67708bd14912be1b00000000000000000000000000000000000000000000000000000000000000)
    │   │   │   ├─ [121408] SessionFinalizer::finalizeSession(0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000179656c6c6f772d73657373696f6e2d310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000002e000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000376aac07ad725e01357b1725b5cec61ae10473c000000000000000000000000f5a5e415061470a8b9137959180901aea72450a400000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000001bc16d674ec8000000000000000000000000000000000000000000000000000029a2241af62c00000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000041ded90b1a4c256fe86b6436a90f8374255814a13ecf36c11d1dc3ca654c5b93d57b031961a73a17f0ec6efe145a41ad4f2db8fceb51788f5e58fcb8dd386b9f5c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000413bcb57b3e782f937d63da78e5f7b1a8643e126c881e29059dbfad44564d291b65296b78bb8cb648161de1f70db669fa387a81e6805e4ab3f9fed652353a795621b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041aeb7d09dccc43fae99c376e661b5fc9fb7ff0523467a066c0efd9b7804aa9c966020bdc946cfada70c0c756761c41c68a11829e93e5bd7110f67708bd14912be1b00000000000000000000000000000000000000000000000000000000000000)
    │   │   │   │   ├─ [3000] PRECOMPILES::ecrecover(0x9951e799658ab3a32a13a3fb0fb8ebc9d3ef655a6c4459c2ba705f364f4850f1, 27, 79027208483858994645967547822968588499287123990831667954863813884336935705750, 43479882426532599422713663333130635182624190101529004195508077656212337398462) [staticcall]
    │   │   │   │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   │   │   │   ├─ [3000] PRECOMPILES::ecrecover(0x41b9aabf3bfa155388345a4f98abf29040ff9ad4f2c09b640d6fa7df8d3733c8, 28, 100796934826729610573525149180075652734940331859587961455295743492290839811029, 55639956093320648397221343794816367491993753865207778602179762354128918650716) [staticcall]
    │   │   │   │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   │   │   │   ├─ [3000] PRECOMPILES::ecrecover(0x6bd6d8ad0a0b3601e264a568a2f7a39a66f732e38001e4b4c79ee353949625bb, 27, 27045733322706371883562000232833411001926372411600679532961908921907933254070, 37355947430019783432410939321181440080356382524874353200399251478415906674018) [staticcall]
    │   │   │   │   │   └─ ← [Return] 0xF5A5E415061470A8b9137959180901aEa72450a4
    │   │   │   │   ├─ [29201] ERC20Mock::transfer(0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, 2000000000000000000 [2e18])
    │   │   │   │   │   ├─ emit Transfer(from: SessionFinalizer: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], to: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, value: 2000000000000000000 [2e18])
    │   │   │   │   │   └─ ← [Return] true
    │   │   │   │   ├─ [29201] ERC20Mock::transfer(0xF5A5E415061470A8b9137959180901aEa72450a4, 3000000000000000000 [3e18])
    │   │   │   │   │   ├─ emit Transfer(from: SessionFinalizer: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], to: 0xF5A5E415061470A8b9137959180901aEa72450a4, value: 3000000000000000000 [3e18])
    │   │   │   │   │   └─ ← [Return] true
    │   │   │   │   ├─ emit SessionFinalized(marketId: 1, sessionId: 0x79656c6c6f772d73657373696f6e2d3100000000000000000000000000000000, participants: [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, 0xF5A5E415061470A8b9137959180901aEa72450a4], balances: [2000000000000000000 [2e18], 3000000000000000000 [3e18]])
    │   │   │   │   └─ ← [Return]
    │   │   │   ├─ emit SessionPayloadRouted(target: SessionFinalizer: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], payloadHash: 0xc74e54eb024b162b0ba029b134a62e824bffb0a19805c62b10e43d53560a32ed, marketId: 0, sessionId: 0x0000000000000000000000000000000000000000000000000000000000000000, routeType: 0)
    │   │   │   └─ ← [Return]
    │   │   └─ ← [Return]
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Finalizer transfers exact balances to participants") [staticcall]
    │   └─ ← [Stop]
    ├─ [1240] ERC20Mock::balanceOf(0x0376AAc07Ad725E01357B1725B5ceC61aE10473c) [staticcall]
    │   └─ ← [Return] 2000000000000000000 [2e18]
    ├─ [1240] ERC20Mock::balanceOf(0xF5A5E415061470A8b9137959180901aEa72450a4) [staticcall]
    │   └─ ← [Return] 3000000000000000000 [3e18]
    └─ ← [Return]

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 6.37ms (5.14ms CPU time)

Ran 8 tests for test/CheckpointFlow.t.sol:CheckpointFlowTest
[PASS] testChallengeBeforeDeadlineSucceeds() (gas: 262119)
Logs:
  [TEST] testChallengeBeforeDeadlineSucceeds
  [ARRANGE] Submit pending checkpoint nonce=5
  [ACT] Challenge with newer nonce=6 before challenge window closes
  [ASSERT] No final nonce yet and pending record replaced with nonce=6

Traces:
  [262119] CheckpointFlowTest::testChallengeBeforeDeadlineSucceeds()
    ├─ [0] console::log("[TEST] testChallengeBeforeDeadlineSucceeds") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Submit pending checkpoint nonce=5") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 5, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x850c0313a8865f8a53c84520ab066729c50f4bd644ae9dd0c2a0d0c46eb25486
    ├─ [0] VM::sign("<pk>", 0x850c0313a8865f8a53c84520ab066729c50f4bd644ae9dd0c2a0d0c46eb25486) [staticcall]
    │   └─ ← [Return] 27, 0x357f774eba1f1d74c771108cacb3ae4523c9898854c2fac8eed5d2448eeb8d50, 0x14b090a50165c94b86be2ed0cdd288e46895088bb02ce931db7be92acccbe556
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 5, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x850c0313a8865f8a53c84520ab066729c50f4bd644ae9dd0c2a0d0c46eb25486
    ├─ [0] VM::sign("<pk>", 0x850c0313a8865f8a53c84520ab066729c50f4bd644ae9dd0c2a0d0c46eb25486) [staticcall]
    │   └─ ← [Return] 27, 0xbf763721365052fdec544030146c8494979e8ca33053f8107c822c0fa3cd5077, 0x6ce7a5f845784c9739bd9f8c3d3776b4a45e79fd1ffbf2ae94677ec9a11c49a7
    ├─ [129878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 5, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })], 0x357f774eba1f1d74c771108cacb3ae4523c9898854c2fac8eed5d2448eeb8d5014b090a50165c94b86be2ed0cdd288e46895088bb02ce931db7be92acccbe5561b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xbf763721365052fdec544030146c8494979e8ca33053f8107c822c0fa3cd50776ce7a5f845784c9739bd9f8c3d3776b4a45e79fd1ffbf2ae94677ec9a11c49a71b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x850c0313a8865f8a53c84520ab066729c50f4bd644ae9dd0c2a0d0c46eb25486, 27, 24197793982431967753392124124642714935814133572594743057226566544955401801040, 9358220355078646080888430479119834036893311272433704307502446205172114515286) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x850c0313a8865f8a53c84520ab066729c50f4bd644ae9dd0c2a0d0c46eb25486, 27, 86600622524494950231244819108971478525078878841204161961938280650137767071863, 49259074800486606959235952856188101519881871138347520704072222347658021063079) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 5, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a)
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Challenge with newer nonce=6 before challenge window closes") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 6, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x7606079f2c849a0224bc2e1ffb54033d60674ca1bbc3fa7c09e0666f3a5fd11b, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x0c1f37776bf3c652ad7bb9cace3587d8da5a944981027cfb4fb22cc985710311
    ├─ [0] VM::sign("<pk>", 0x0c1f37776bf3c652ad7bb9cace3587d8da5a944981027cfb4fb22cc985710311) [staticcall]
    │   └─ ← [Return] 27, 0x8118d1d896cf30e37a28d85cd909e987133fc0fe801bdcbe12ad8479225515e5, 0x47bbbc1a92762f46705aedf81061eac6bd7ee2f0fdb1311ebd5ee7a4698d3331
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 6, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x7606079f2c849a0224bc2e1ffb54033d60674ca1bbc3fa7c09e0666f3a5fd11b, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x0c1f37776bf3c652ad7bb9cace3587d8da5a944981027cfb4fb22cc985710311
    ├─ [0] VM::sign("<pk>", 0x0c1f37776bf3c652ad7bb9cace3587d8da5a944981027cfb4fb22cc985710311) [staticcall]
    │   └─ ← [Return] 27, 0xb92f495ba3059e4bea12e90222feacd9405acd681525a4bcd585317b196dcce7, 0x6b61b3bcdf4300ec75cb318fb58af97a432faebb48d757ef3645bc2e977dd399
    ├─ [36104] ChannelSettlement::challengeCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 6, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x7606079f2c849a0224bc2e1ffb54033d60674ca1bbc3fa7c09e0666f3a5fd11b, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 15, cashDelta: -150 })], 0x8118d1d896cf30e37a28d85cd909e987133fc0fe801bdcbe12ad8479225515e547bbbc1a92762f46705aedf81061eac6bd7ee2f0fdb1311ebd5ee7a4698d33311b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xb92f495ba3059e4bea12e90222feacd9405acd681525a4bcd585317b196dcce76b61b3bcdf4300ec75cb318fb58af97a432faebb48d757ef3645bc2e977dd3991b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x0c1f37776bf3c652ad7bb9cace3587d8da5a944981027cfb4fb22cc985710311, 27, 58392210101013081828487097583795569323093125469856219722552056712537440589285, 32445910895221494352337232218759237756992808790776598054837172172930927113009) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x0c1f37776bf3c652ad7bb9cace3587d8da5a944981027cfb4fb22cc985710311, 27, 83761425097955543129824659224631596294836031662647152579525862294506059975911, 48570099468271260498861183335502126491162940361649281491681485002113200018329) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointChallenged(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, newNonce: 6)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] No final nonce yet and pending record replaced with nonce=6") [staticcall]
    │   └─ ← [Stop]
    ├─ [1322] ChannelSettlement::latestNonce(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b) [staticcall]
    │   └─ ← [Return] 0
    ├─ [2987] ChannelSettlement::pendingByKey(0xe5c7f030c40c8e681b140c1158ea08ccb64ced75dd60a421c88abb2cde670d7b) [staticcall]
    │   └─ ← [Return] 6, 1801, 0, 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, 0x7606079f2c849a0224bc2e1ffb54033d60674ca1bbc3fa7c09e0666f3a5fd11b, 0x0000000000000000000000000000000000000000000000000000000000000000, true
    └─ ← [Return]

[PASS] testFinalizeAfterDeadlineSucceeds() (gas: 241368)
Logs:
  [TEST] testFinalizeAfterDeadlineSucceeds
  [ARRANGE] Submit checkpoint that grants user shares and debits cash
  [ACT] Warp past challenge window and finalize
  [ASSERT] Ledger position and vault free balance reflect finalized deltas

Traces:
  [306976] CheckpointFlowTest::testFinalizeAfterDeadlineSucceeds()
    ├─ [0] console::log("[TEST] testFinalizeAfterDeadlineSucceeds") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Submit checkpoint that grants user shares and debits cash") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466
    ├─ [0] VM::sign("<pk>", 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466) [staticcall]
    │   └─ ← [Return] 27, 0x6e413d8e01fa1c9bd26ba51fec1454b960e34aef2325e1e266c8d1a8aa7b39b2, 0x4d1c6f2f9af6728f5adf3e1d161dab559dcfb63447a2e596eed94ff7e392f014
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466
    ├─ [0] VM::sign("<pk>", 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466) [staticcall]
    │   └─ ← [Return] 27, 0xda32ec7daeee411861198b4f1914884ab5150ada6714aa1dca24fe0bf26e1c42, 0x6f472e051db6e8e63113f148f2fcd72491af479ff8c01c7742efb1465003e88d
    ├─ [129878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })], 0x6e413d8e01fa1c9bd26ba51fec1454b960e34aef2325e1e266c8d1a8aa7b39b24d1c6f2f9af6728f5adf3e1d161dab559dcfb63447a2e596eed94ff7e392f0141b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xda32ec7daeee411861198b4f1914884ab5150ada6714aa1dca24fe0bf26e1c426f472e051db6e8e63113f148f2fcd72491af479ff8c01c7742efb1465003e88d1b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466, 27, 49869683238417680961147092484010867563403350944231452331267766515480202525106, 34878328436006769312658598855085794146981570113560273517920275525645089566740) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466, 27, 98694175544944518724241401186235069003839133488216063432116533356812911385666, 50332489952602821268836144007520419315814676157358565079429033663838055295117) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Warp past challenge window and finalize") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::warp(1861)
    │   └─ ← [Return]
    ├─ [106188] ChannelSettlement::finalizeCheckpoint(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   ├─ [29793] ExecutionLedger::applyDeltas(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   │   ├─ emit DeltasApplied(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, deltaCount: 1)
    │   │   └─ ← [Return]
    │   ├─ [1040] CollateralVault::token() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [14248] CollateralVault::applyCashDeltas(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [-1000])
    │   │   ├─ emit CashDeltasApplied(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, userCount: 1)
    │   │   └─ ← [Return]
    │   ├─ emit CheckpointFinalized(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Ledger position and vault free balance reflect finalized deltas") [staticcall]
    │   └─ ← [Stop]
    ├─ [1514] ExecutionLedger::positionOf(0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, 1, 0) [staticcall]
    │   └─ ← [Return] 10
    ├─ [1307] CollateralVault::freeBalance(0x0376AAc07Ad725E01357B1725B5ceC61aE10473c) [staticcall]
    │   └─ ← [Return] 9999999999999999000 [9.999e18]
    └─ ← [Return]

[PASS] testFinalizeBeforeDeadlineFails() (gas: 192650)
Logs:
  [TEST] testFinalizeBeforeDeadlineFails
  [ARRANGE] Submit checkpoint and attempt immediate finalize
  [ASSERT] Finalization before challenge deadline reverts

Traces:
  [192650] CheckpointFlowTest::testFinalizeBeforeDeadlineFails()
    ├─ [0] console::log("[TEST] testFinalizeBeforeDeadlineFails") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Submit checkpoint and attempt immediate finalize") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a
    ├─ [0] VM::sign("<pk>", 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a) [staticcall]
    │   └─ ← [Return] 27, 0x682615633f5f6dbceebcf11227699071bf1ce93937e3127607553865777bc822, 0x2abc18fc3e1c5b3629122d23116fc62a0b81441265f4efa1fe18d7b1fb0b06c3
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a
    ├─ [0] VM::sign("<pk>", 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a) [staticcall]
    │   └─ ← [Return] 27, 0xd1298b17606eb1dc2deeb7232b7ba3560d15628f9174b6aa4b82e09760cedbd3, 0x46a6967a1bc8064dc214e9453e3ff0f0bbd9123a9e5d049466baa9c4369d2f69
    ├─ [129878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })], 0x682615633f5f6dbceebcf11227699071bf1ce93937e3127607553865777bc8222abc18fc3e1c5b3629122d23116fc62a0b81441265f4efa1fe18d7b1fb0b06c31b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xd1298b17606eb1dc2deeb7232b7ba3560d15628f9174b6aa4b82e09760cedbd346a6967a1bc8064dc214e9453e3ff0f0bbd9123a9e5d049466baa9c4369d2f691b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a, 27, 47107824053503217095654025692380858845863844715633532319090267534918277646370, 19329479331035434847817774664960325270051719970305402530287625755220205307587) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a, 27, 94606786056535083345999133281617033602185457803447141878001497992827967036371, 31956234567573088194430761337981674951735485812903272829707721632728244629353) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Finalization before challenge deadline reverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xf4844814)
    │   └─ ← [Return]
    ├─ [4407] ChannelSettlement::finalizeCheckpoint(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })])
    │   └─ ← [Revert] ChallengeWindow()
    └─ ← [Return]

[PASS] testRejectsBadDeltasHash() (gas: 60099)
Logs:
  [TEST] testRejectsBadDeltasHash
  [ARRANGE] Create checkpoint with deltas payload but intentionally wrong deltasHash
  [ASSERT] submitCheckpoint reverts when checkpoint hash does not match payload

Traces:
  [60099] CheckpointFlowTest::testRejectsBadDeltasHash()
    ├─ [0] console::log("[TEST] testRejectsBadDeltasHash") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Create checkpoint with deltas payload but intentionally wrong deltasHash") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x877a483801bc0375a786f12864c3c09903218ef0684e41ea523973c255fc9f9f, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xa3c92c4098ad501b021f60715b2805a791d16e44be779243ae8a856b7e624b81
    ├─ [0] VM::sign("<pk>", 0xa3c92c4098ad501b021f60715b2805a791d16e44be779243ae8a856b7e624b81) [staticcall]
    │   └─ ← [Return] 28, 0x091954929acdf1597fea254023aa42b89ef98cb5c83e544afbcb555d471ccccf, 0x1f50242ed5c24503070f3d49c885a2f780f51341f93fde2a448403e6b7ef83a1
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x877a483801bc0375a786f12864c3c09903218ef0684e41ea523973c255fc9f9f, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xa3c92c4098ad501b021f60715b2805a791d16e44be779243ae8a856b7e624b81
    ├─ [0] VM::sign("<pk>", 0xa3c92c4098ad501b021f60715b2805a791d16e44be779243ae8a856b7e624b81) [staticcall]
    │   └─ ← [Return] 27, 0x1dc97ad10e70ca2b4247efc8de6011e460c975cd1ffcc1c0a81993089abaedb9, 0x776aa1ad3804035eb702753782573d27dd0bfeb687191946793d5016d252954d
    ├─ [0] console::log("[ASSERT] submitCheckpoint reverts when checkpoint hash does not match payload") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xf4844814)
    │   └─ ← [Return]
    ├─ [5764] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x877a483801bc0375a786f12864c3c09903218ef0684e41ea523973c255fc9f9f, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })], 0x091954929acdf1597fea254023aa42b89ef98cb5c83e544afbcb555d471ccccf1f50242ed5c24503070f3d49c885a2f780f51341f93fde2a448403e6b7ef83a11c, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0x1dc97ad10e70ca2b4247efc8de6011e460c975cd1ffcc1c0a81993089abaedb9776aa1ad3804035eb702753782573d27dd0bfeb687191946793d5016d252954d1b])
    │   └─ ← [Revert] BadDeltasHash()
    └─ ← [Return]

[PASS] testRejectsInvalidOperatorSig() (gas: 71281)
Logs:
  [TEST] testRejectsInvalidOperatorSig
  [ARRANGE] Build valid checkpoint but sign operator slot with user key
  [ASSERT] Invalid operator signature reverts

Traces:
  [71281] CheckpointFlowTest::testRejectsInvalidOperatorSig()
    ├─ [0] console::log("[TEST] testRejectsInvalidOperatorSig") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Build valid checkpoint but sign operator slot with user key") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a
    ├─ [0] VM::sign("<pk>", 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a) [staticcall]
    │   └─ ← [Return] 27, 0xd1298b17606eb1dc2deeb7232b7ba3560d15628f9174b6aa4b82e09760cedbd3, 0x46a6967a1bc8064dc214e9453e3ff0f0bbd9123a9e5d049466baa9c4369d2f69
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a
    ├─ [0] VM::sign("<pk>", 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a) [staticcall]
    │   └─ ← [Return] 27, 0xd1298b17606eb1dc2deeb7232b7ba3560d15628f9174b6aa4b82e09760cedbd3, 0x46a6967a1bc8064dc214e9453e3ff0f0bbd9123a9e5d049466baa9c4369d2f69
    ├─ [0] console::log("[ASSERT] Invalid operator signature reverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xf4844814)
    │   └─ ← [Return]
    ├─ [17447] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })], 0xd1298b17606eb1dc2deeb7232b7ba3560d15628f9174b6aa4b82e09760cedbd346a6967a1bc8064dc214e9453e3ff0f0bbd9123a9e5d049466baa9c4369d2f691b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xd1298b17606eb1dc2deeb7232b7ba3560d15628f9174b6aa4b82e09760cedbd346a6967a1bc8064dc214e9453e3ff0f0bbd9123a9e5d049466baa9c4369d2f691b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a, 27, 94606786056535083345999133281617033602185457803447141878001497992827967036371, 31956234567573088194430761337981674951735485812903272829707721632728244629353) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   └─ ← [Revert] BadOperatorSig()
    └─ ← [Return]

[PASS] testRejectsInvalidUserSig() (gas: 80483)
Logs:
  [TEST] testRejectsInvalidUserSig
  [ARRANGE] Build valid checkpoint but sign user slot with operator key
  [ASSERT] Invalid user signature reverts

Traces:
  [80483] CheckpointFlowTest::testRejectsInvalidUserSig()
    ├─ [0] console::log("[TEST] testRejectsInvalidUserSig") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Build valid checkpoint but sign user slot with operator key") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a
    ├─ [0] VM::sign("<pk>", 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a) [staticcall]
    │   └─ ← [Return] 27, 0x682615633f5f6dbceebcf11227699071bf1ce93937e3127607553865777bc822, 0x2abc18fc3e1c5b3629122d23116fc62a0b81441265f4efa1fe18d7b1fb0b06c3
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a
    ├─ [0] VM::sign("<pk>", 0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a) [staticcall]
    │   └─ ← [Return] 27, 0x682615633f5f6dbceebcf11227699071bf1ce93937e3127607553865777bc822, 0x2abc18fc3e1c5b3629122d23116fc62a0b81441265f4efa1fe18d7b1fb0b06c3
    ├─ [0] console::log("[ASSERT] Invalid user signature reverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xf4844814)
    │   └─ ← [Return]
    ├─ [26893] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })], 0x682615633f5f6dbceebcf11227699071bf1ce93937e3127607553865777bc8222abc18fc3e1c5b3629122d23116fc62a0b81441265f4efa1fe18d7b1fb0b06c31b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0x682615633f5f6dbceebcf11227699071bf1ce93937e3127607553865777bc8222abc18fc3e1c5b3629122d23116fc62a0b81441265f4efa1fe18d7b1fb0b06c31b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a, 27, 47107824053503217095654025692380858845863844715633532319090267534918277646370, 19329479331035434847817774664960325270051719970305402530287625755220205307587) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0xd38cc7d09c492916bf4bf2b1689fbae9ab9c0193215ca0f3fae02932bba9709a, 27, 47107824053503217095654025692380858845863844715633532319090267534918277646370, 19329479331035434847817774664960325270051719970305402530287625755220205307587) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   └─ ← [Revert] BadUserSig()
    └─ ← [Return]

[PASS] testRejectsNonIncreasingNonce() (gas: 274577)
Logs:
  [TEST] testRejectsNonIncreasingNonce
  [ARRANGE] Submit and finalize nonce=1 checkpoint
  [ACT] Re-submit another checkpoint with same nonce=1
  [ASSERT] Duplicate nonce is rejected

Traces:
  [348487] CheckpointFlowTest::testRejectsNonIncreasingNonce()
    ├─ [0] console::log("[TEST] testRejectsNonIncreasingNonce") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Submit and finalize nonce=1 checkpoint") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466
    ├─ [0] VM::sign("<pk>", 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466) [staticcall]
    │   └─ ← [Return] 27, 0x6e413d8e01fa1c9bd26ba51fec1454b960e34aef2325e1e266c8d1a8aa7b39b2, 0x4d1c6f2f9af6728f5adf3e1d161dab559dcfb63447a2e596eed94ff7e392f014
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466
    ├─ [0] VM::sign("<pk>", 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466) [staticcall]
    │   └─ ← [Return] 27, 0xda32ec7daeee411861198b4f1914884ab5150ada6714aa1dca24fe0bf26e1c42, 0x6f472e051db6e8e63113f148f2fcd72491af479ff8c01c7742efb1465003e88d
    ├─ [129878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })], 0x6e413d8e01fa1c9bd26ba51fec1454b960e34aef2325e1e266c8d1a8aa7b39b24d1c6f2f9af6728f5adf3e1d161dab559dcfb63447a2e596eed94ff7e392f0141b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xda32ec7daeee411861198b4f1914884ab5150ada6714aa1dca24fe0bf26e1c426f472e051db6e8e63113f148f2fcd72491af479ff8c01c7742efb1465003e88d1b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466, 27, 49869683238417680961147092484010867563403350944231452331267766515480202525106, 34878328436006769312658598855085794146981570113560273517920275525645089566740) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466, 27, 98694175544944518724241401186235069003839133488216063432116533356812911385666, 50332489952602821268836144007520419315814676157358565079429033663838055295117) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1)
    │   └─ ← [Return]
    ├─ [0] VM::warp(1861)
    │   └─ ← [Return]
    ├─ [106188] ChannelSettlement::finalizeCheckpoint(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   ├─ [29793] ExecutionLedger::applyDeltas(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   │   ├─ emit DeltasApplied(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, deltaCount: 1)
    │   │   └─ ← [Return]
    │   ├─ [1040] CollateralVault::token() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [14248] CollateralVault::applyCashDeltas(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [-1000])
    │   │   ├─ emit CashDeltasApplied(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, userCount: 1)
    │   │   └─ ← [Return]
    │   ├─ emit CheckpointFinalized(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Re-submit another checkpoint with same nonce=1") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466
    ├─ [0] VM::sign("<pk>", 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466) [staticcall]
    │   └─ ← [Return] 27, 0x6e413d8e01fa1c9bd26ba51fec1454b960e34aef2325e1e266c8d1a8aa7b39b2, 0x4d1c6f2f9af6728f5adf3e1d161dab559dcfb63447a2e596eed94ff7e392f014
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466
    ├─ [0] VM::sign("<pk>", 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466) [staticcall]
    │   └─ ← [Return] 27, 0xda32ec7daeee411861198b4f1914884ab5150ada6714aa1dca24fe0bf26e1c42, 0x6f472e051db6e8e63113f148f2fcd72491af479ff8c01c7742efb1465003e88d
    ├─ [0] console::log("[ASSERT] Duplicate nonce is rejected") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xf4844814)
    │   └─ ← [Return]
    ├─ [28393] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })], 0x6e413d8e01fa1c9bd26ba51fec1454b960e34aef2325e1e266c8d1a8aa7b39b24d1c6f2f9af6728f5adf3e1d161dab559dcfb63447a2e596eed94ff7e392f0141b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xda32ec7daeee411861198b4f1914884ab5150ada6714aa1dca24fe0bf26e1c426f472e051db6e8e63113f148f2fcd72491af479ff8c01c7742efb1465003e88d1b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466, 27, 49869683238417680961147092484010867563403350944231452331267766515480202525106, 34878328436006769312658598855085794146981570113560273517920275525645089566740) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466, 27, 98694175544944518724241401186235069003839133488216063432116533356812911385666, 50332489952602821268836144007520419315814676157358565079429033663838055295117) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   └─ ← [Revert] NonceNotIncreasing()
    └─ ← [Return]

[PASS] testReplayAcrossSessionReverts() (gas: 418026)
Logs:
  [TEST] testReplayAcrossSessionReverts
  [ARRANGE] Finalize checkpoint in session-1 then replay same nonce in session-2
  [ACT] Finalize replayed checkpoint under different session id
  [ASSERT] Original session has no pending checkpoint and re-finalize reverts

Traces:
  [527798] CheckpointFlowTest::testReplayAcrossSessionReverts()
    ├─ [0] console::log("[TEST] testReplayAcrossSessionReverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Finalize checkpoint in session-1 then replay same nonce in session-2") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466
    ├─ [0] VM::sign("<pk>", 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466) [staticcall]
    │   └─ ← [Return] 27, 0x6e413d8e01fa1c9bd26ba51fec1454b960e34aef2325e1e266c8d1a8aa7b39b2, 0x4d1c6f2f9af6728f5adf3e1d161dab559dcfb63447a2e596eed94ff7e392f014
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466
    ├─ [0] VM::sign("<pk>", 0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466) [staticcall]
    │   └─ ← [Return] 27, 0xda32ec7daeee411861198b4f1914884ab5150ada6714aa1dca24fe0bf26e1c42, 0x6f472e051db6e8e63113f148f2fcd72491af479ff8c01c7742efb1465003e88d
    ├─ [129878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })], 0x6e413d8e01fa1c9bd26ba51fec1454b960e34aef2325e1e266c8d1a8aa7b39b24d1c6f2f9af6728f5adf3e1d161dab559dcfb63447a2e596eed94ff7e392f0141b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xda32ec7daeee411861198b4f1914884ab5150ada6714aa1dca24fe0bf26e1c426f472e051db6e8e63113f148f2fcd72491af479ff8c01c7742efb1465003e88d1b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466, 27, 49869683238417680961147092484010867563403350944231452331267766515480202525106, 34878328436006769312658598855085794146981570113560273517920275525645089566740) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x66a549d4a0918b581c3fed58b98ac094755adec0512f2e27067a749d16159466, 27, 98694175544944518724241401186235069003839133488216063432116533356812911385666, 50332489952602821268836144007520419315814676157358565079429033663838055295117) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1)
    │   └─ ← [Return]
    ├─ [0] VM::warp(1861)
    │   └─ ← [Return]
    ├─ [106188] ChannelSettlement::finalizeCheckpoint(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   ├─ [29793] ExecutionLedger::applyDeltas(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   │   ├─ emit DeltasApplied(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, deltaCount: 1)
    │   │   └─ ← [Return]
    │   ├─ [1040] CollateralVault::token() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [14248] CollateralVault::applyCashDeltas(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [-1000])
    │   │   ├─ emit CashDeltasApplied(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, userCount: 1)
    │   │   └─ ← [Return]
    │   ├─ emit CheckpointFinalized(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Finalize replayed checkpoint under different session id") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x5062d5bc99268cd6a430f9657826b4b124ea3dbef13f32f8032b8776d106b100
    ├─ [0] VM::sign("<pk>", 0x5062d5bc99268cd6a430f9657826b4b124ea3dbef13f32f8032b8776d106b100) [staticcall]
    │   └─ ← [Return] 27, 0x35185d1407ae56da25066ed1ef6a944a4f326bb8d331ff89218a34a4eeefbc04, 0x67c756742c76ea7066b3defc27f9acc27772b69d6e2a191e87a73ae54418bc51
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x5062d5bc99268cd6a430f9657826b4b124ea3dbef13f32f8032b8776d106b100
    ├─ [0] VM::sign("<pk>", 0x5062d5bc99268cd6a430f9657826b4b124ea3dbef13f32f8032b8776d106b100) [staticcall]
    │   └─ ← [Return] 28, 0x07401053bd3f6b61119d49f24dfffaa05f26a07eff80b8d1f84efa569e808d51, 0x386db9ac574b996980e742b56ea4a054668fa2ce8e801712d6852f9ed629c692
    ├─ [127878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })], 0x35185d1407ae56da25066ed1ef6a944a4f326bb8d331ff89218a34a4eeefbc0467c756742c76ea7066b3defc27f9acc27772b69d6e2a191e87a73ae54418bc511b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0x07401053bd3f6b61119d49f24dfffaa05f26a07eff80b8d1f84efa569e808d51386db9ac574b996980e742b56ea4a054668fa2ce8e801712d6852f9ed629c6921c])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x5062d5bc99268cd6a430f9657826b4b124ea3dbef13f32f8032b8776d106b100, 27, 24015627706885889729052417821639718393033164021589787743581148109481549216772, 46940422652189633808912903977743961026968983882875033400394214770305928838225) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x5062d5bc99268cd6a430f9657826b4b124ea3dbef13f32f8032b8776d106b100, 28, 3279380837775915712046927466654434289177392865643543949711692821487943716177, 25523387320102013754432855438675199007652033619642114293405826075648556910226) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xf6d9e2f81f9558b51104d11dadc9a1c4fb42c26048814ce9c0adac052401cec1)
    │   └─ ← [Return]
    ├─ [0] VM::warp(3721)
    │   └─ ← [Return]
    ├─ [64488] ChannelSettlement::finalizeCheckpoint(1, 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   ├─ [5893] ExecutionLedger::applyDeltas(1, 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   │   ├─ emit DeltasApplied(marketId: 1, sessionId: 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, deltaCount: 1)
    │   │   └─ ← [Return]
    │   ├─ [1040] CollateralVault::token() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [7448] CollateralVault::applyCashDeltas(1, 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [-1000])
    │   │   ├─ emit CashDeltasApplied(marketId: 1, sessionId: 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, userCount: 1)
    │   │   └─ ← [Return]
    │   ├─ emit CheckpointFinalized(marketId: 1, sessionId: 0x578041ac32cd519b41ccf65668c9112d7ccce1493a83105bdfd8a7a2fcafc55a, nonce: 1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Original session has no pending checkpoint and re-finalize reverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: da7557bc00000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [4167] ChannelSettlement::finalizeCheckpoint(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000 })])
    │   └─ ← [Revert] NoPending()
    └─ ← [Return]

Suite result: ok. 8 passed; 0 failed; 0 skipped; finished in 29.40ms (15.26ms CPU time)

Ran 3 tests for test/FeeFlow.t.sol:FeeFlowTest
[PASS] testComputeSplitSumCorrectness() (gas: 46527)
Logs:
  [TEST] testComputeSplitSumCorrectness
  [ARRANGE] Configure LP/creator shares and use fixed positive profit
  [ACT] Compute fee split for profit=10000
  [ASSERT] profit = protocolFee + lpFee + creatorFee + netDelta

Traces:
  [46527] FeeFlowTest::testComputeSplitSumCorrectness()
    ├─ [0] console::log("[TEST] testComputeSplitSumCorrectness") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Configure LP/creator shares and use fixed positive profit") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(ECRecover: [0x0000000000000000000000000000000000000001])
    │   └─ ← [Return]
    ├─ [8899] FeeManager::setLpFeeShareBps(2000)
    │   ├─ emit LpFeeShareBpsUpdated(previous: 0, current: 2000)
    │   └─ ← [Return]
    ├─ [0] VM::prank(ECRecover: [0x0000000000000000000000000000000000000001])
    │   └─ ← [Return]
    ├─ [3989] FeeManager::setCreatorFeeShareBps(1000)
    │   ├─ emit CreatorFeeShareBpsUpdated(previous: 0, current: 1000)
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Compute fee split for profit=10000") [staticcall]
    │   └─ ← [Stop]
    ├─ [6833] FeeManager::computeSplit(10000 [1e4]) [staticcall]
    │   └─ ← [Return] 70, 20, 10, 9900
    ├─ [0] console::log("[ASSERT] profit = protocolFee + lpFee + creatorFee + netDelta") [staticcall]
    │   └─ ← [Stop]
    └─ ← [Return]

[PASS] testFeeAppliedOnPositivePnl() (gas: 402364)
Logs:
  [TEST] testFeeAppliedOnPositivePnl
  [ARRANGE] Spender and user are funded; positive pnl goes to user
  [ACT] Submit checkpoint and finalize after challenge window
  [ASSERT] FeePool gets 1% protocol fee and balances are netted correctly

Traces:
  [481964] FeeFlowTest::testFeeAppliedOnPositivePnl()
    ├─ [0] console::log("[TEST] testFeeAppliedOnPositivePnl") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Spender and user are funded; positive pnl goes to user") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0xF5A5E415061470A8b9137959180901aEa72450a4)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0xF5A5E415061470A8b9137959180901aEa72450a4, spender: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(0xF5A5E415061470A8b9137959180901aEa72450a4)
    │   └─ ← [Return]
    ├─ [46193] CollateralVault::deposit(10000000000000000000 [1e19])
    │   ├─ [19955] ERC20Mock::transferFrom(0xF5A5E415061470A8b9137959180901aEa72450a4, CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], 10000000000000000000 [1e19])
    │   │   ├─ emit Transfer(from: 0xF5A5E415061470A8b9137959180901aEa72450a4, to: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], value: 10000000000000000000 [1e19])
    │   │   └─ ← [Return] true
    │   ├─ emit Deposited(user: 0xF5A5E415061470A8b9137959180901aEa72450a4, amount: 10000000000000000000 [1e19])
    │   └─ ← [Return]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xce193727153e7686b1dc4006db80a56de69a1e0f85d531a13886d792fc60d626, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11
    ├─ [0] VM::sign("<pk>", 0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11) [staticcall]
    │   └─ ← [Return] 28, 0x61fa04352cacc44a01cda20022210f4426bc0d9c8b2aaf6898d8c4cea021c778, 0x19a96e2812f893ba550bb910d9b338349b9a16b12898c0725dde893efe5f97c6
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xce193727153e7686b1dc4006db80a56de69a1e0f85d531a13886d792fc60d626, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11
    ├─ [0] VM::sign("<pk>", 0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11) [staticcall]
    │   └─ ← [Return] 27, 0x68c4dd0da8f33569116b52f3cfd1e028c40a69440fb6fc5d235fef65ccb2efd5, 0x53fed1077d6df75b15cd4714c78833d1a3c34b3fddfee8f1ee2c6ab470bb0d59
    ├─ [0] console::log("[ACT] Submit checkpoint and finalize after challenge window") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xce193727153e7686b1dc4006db80a56de69a1e0f85d531a13886d792fc60d626, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11
    ├─ [0] VM::sign("<pk>", 0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11) [staticcall]
    │   └─ ← [Return] 28, 0x4d4e8455f02ebc6a7bb788b3ed8f2aa7eebdbbe953c12709f63e16b2f982d748, 0x0233911d29ae4da8a822402898fe841c6540d8c4f748f2229b98f78c8bafc033
    ├─ [141433] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xce193727153e7686b1dc4006db80a56de69a1e0f85d531a13886d792fc60d626, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0xF5A5E415061470A8b9137959180901aEa72450a4, outcomeIndex: 0, sharesDelta: 0, cashDelta: -1000 }), Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 0, cashDelta: 1000 })], 0x4d4e8455f02ebc6a7bb788b3ed8f2aa7eebdbbe953c12709f63e16b2f982d7480233911d29ae4da8a822402898fe841c6540d8c4f748f2229b98f78c8bafc0331c, [0xF5A5E415061470A8b9137959180901aEa72450a4, 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0x61fa04352cacc44a01cda20022210f4426bc0d9c8b2aaf6898d8c4cea021c77819a96e2812f893ba550bb910d9b338349b9a16b12898c0725dde893efe5f97c61c, 0x68c4dd0da8f33569116b52f3cfd1e028c40a69440fb6fc5d235fef65ccb2efd553fed1077d6df75b15cd4714c78833d1a3c34b3fddfee8f1ee2c6ab470bb0d591b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11, 28, 34966816759371645020299335081096276844525058166619030103824922370118074423112, 995736436918476556232573753971879449406899477680514724787926346563306111027) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11, 28, 44316087119338809229635073664600515326088980577697351815523339717697853310840, 11607178641023100231181580648481317075227730634979819034836456453237127485382) [staticcall]
    │   │   └─ ← [Return] 0xF5A5E415061470A8b9137959180901aEa72450a4
    │   ├─ [3000] PRECOMPILES::ecrecover(0x3e27a0cfa43b54f3fd0aa897de09296b0d7249a46503f375a1a4cb47d2df2e11, 27, 47388363931570730336393396343257833499087247468194631640066143312224309145557, 37992188253780199695790536575764242488476513548454486836919029612311035448665) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xce193727153e7686b1dc4006db80a56de69a1e0f85d531a13886d792fc60d626)
    │   └─ ← [Return]
    ├─ [0] VM::warp(1861)
    │   └─ ← [Return]
    ├─ [160103] ChannelSettlement::finalizeCheckpoint(0, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0xF5A5E415061470A8b9137959180901aEa72450a4, outcomeIndex: 0, sharesDelta: 0, cashDelta: -1000 }), Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 0, cashDelta: 1000 })])
    │   ├─ [14213] ExecutionLedger::applyDeltas(0, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0xF5A5E415061470A8b9137959180901aEa72450a4, outcomeIndex: 0, sharesDelta: 0, cashDelta: -1000 }), Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 0, cashDelta: 1000 })])
    │   │   ├─ emit DeltasApplied(marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, deltaCount: 2)
    │   │   └─ ← [Return]
    │   ├─ [1040] CollateralVault::token() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459]
    │   ├─ [8833] FeeManager::computeSplit(1000) [staticcall]
    │   │   └─ ← [Return] 10, 0, 0, 990
    │   ├─ [16801] CollateralVault::applyCashDeltas(0, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [0xF5A5E415061470A8b9137959180901aEa72450a4, 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [-1000, 990])
    │   │   ├─ emit CashDeltasApplied(marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, userCount: 2)
    │   │   └─ ← [Return]
    │   ├─ [2862] FeePool::feeCollector() [staticcall]
    │   │   └─ ← [Return] ChannelSettlement: [0x2c1DE3b4Dbb4aDebEbB5dcECAe825bE2a9fc6eb6]
    │   ├─ [31115] CollateralVault::transferToFeeCollector(FeePool: [0x00EFd0D4639191C49908A7BddbB9A11A994A8527], 10)
    │   │   ├─ [29201] ERC20Mock::transfer(FeePool: [0x00EFd0D4639191C49908A7BddbB9A11A994A8527], 10)
    │   │   │   ├─ emit Transfer(from: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], to: FeePool: [0x00EFd0D4639191C49908A7BddbB9A11A994A8527], value: 10)
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Return]
    │   ├─ [4122] FeePool::recordFeeCollected(ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459], 10, 0, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b)
    │   │   ├─ emit FeeCollected(asset: ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459], amount: 10, marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b)
    │   │   └─ ← [Return]
    │   ├─ emit CheckpointFinalized(marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] FeePool gets 1%% protocol fee and balances are netted correctly") [staticcall]
    │   └─ ← [Stop]
    ├─ [3323] FeePool::balanceOf(ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459]) [staticcall]
    │   ├─ [1240] ERC20Mock::balanceOf(FeePool: [0x00EFd0D4639191C49908A7BddbB9A11A994A8527]) [staticcall]
    │   │   └─ ← [Return] 10
    │   └─ ← [Return] 10
    ├─ [1307] CollateralVault::freeBalance(0x0376AAc07Ad725E01357B1725B5ceC61aE10473c) [staticcall]
    │   └─ ← [Return] 10000000000000000990 [1e19]
    ├─ [1307] CollateralVault::freeBalance(0xF5A5E415061470A8b9137959180901aEa72450a4) [staticcall]
    │   └─ ← [Return] 9999999999999999000 [9.999e18]
    └─ ← [Return]

[PASS] testFeeCapEnforcement() (gas: 22361)
Logs:
  [TEST] testFeeCapEnforcement
  [ASSERT] Setting fee above cap (201 bps) should revert

Traces:
  [22361] FeeFlowTest::testFeeCapEnforcement()
    ├─ [0] console::log("[TEST] testFeeCapEnforcement") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ASSERT] Setting fee above cap (201 bps) should revert") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(ECRecover: [0x0000000000000000000000000000000000000001])
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: bc9c0f1800000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [3455] FeeManager::setProtocolFeeBps(201)
    │   └─ ← [Revert] FeeExceedsCap()
    └─ ← [Return]

Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 12.75ms (1.89ms CPU time)

Ran 10 tests for test/CurationFlow.t.sol:CurationFlowTest
[PASS] testClaimAndSeedLocksSharesInManager() (gas: 5886379)
Logs:
  [TEST] testClaimAndSeedLocksSharesInManager
  [ARRANGE] claimAndSeed called with valid creator signature
  [ASSERT] Manager custody holds vault shares; creator has none directly

Traces:
  [5926179] CurationFlowTest::testClaimAndSeedLocksSharesInManager()
    ├─ [0] console::log("[TEST] testClaimAndSeedLocksSharesInManager") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] claimAndSeed called with valid creator signature") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [32897] ERC20Mock::mint(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, spender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19])
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [5107] DraftClaimManager::digestClaimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5
    ├─ [0] VM::sign("<pk>", 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5) [staticcall]
    │   └─ ← [Return] 28, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db3723, 0x29e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [2440335] DraftClaimManager::claimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db372329e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c1c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 0, creator: 0x0000000000000000000000000000000000000000, proposedAt: 1000 })
    │   ├─ [3000] PRECOMPILES::ecrecover(0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5, 28, 87756954237671935026426394917085252310048454375373261379357242772654481159971, 18953863198541009834522543420160553333867510648071294519348697489063624837004) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [2014286] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   ├─ [1951727] → new LiquidityVault4626@0xDDA0a8D7486686d36449792617565E6C474fBa3f
    │   │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   │   └─ ← [Return] 18
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   │   └─ ← [Return] 9361 bytes of code
    │   │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], asset: ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [32255] ERC20Mock::transferFrom(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 50000000000000000000 [5e19])
    │   │   ├─ emit Transfer(from: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [26927] ERC20Mock::approve(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   ├─ emit Approval(owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], spender: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [92027] LiquidityVault4626::deposit(50000000000000000000 [5e19], DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   │   ├─ [3240] ERC20Mock::balanceOf(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [30255] ERC20Mock::transferFrom(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], to: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   ├─ emit Deposit(sender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], assets: 50000000000000000000 [5e19], shares: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] 50000000000000000000 [5e19]
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimedAndSeeded(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], seedAmount: 50000000000000000000 [5e19], seedShares: 50000000000000000000 [5e19])
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [0] console::log("[ASSERT] Manager custody holds vault shares; creator has none directly") [staticcall]
    │   └─ ← [Stop]
    ├─ [1065] DraftClaimManager::getLiquidityVault(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    ├─ [3394] LiquidityVault4626::balanceOf(0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0
    ├─ [1394] LiquidityVault4626::balanceOf(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598]) [staticcall]
    │   └─ ← [Return] 50000000000000000000 [5e19]
    └─ ← [Return]

[PASS] testClaimAndSeedPipeline() (gas: 6261426)
Logs:
  [TEST] testClaimAndSeedPipeline
  [ARRANGE] Enable liquidity vault factory and fund creator for seed
  [ACT] claimAndSeed + publish flow
  [ASSERT] Published draft creates market with linked liquidity vault

Traces:
  [6301226] CurationFlowTest::testClaimAndSeedPipeline()
    ├─ [0] console::log("[TEST] testClaimAndSeedPipeline") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Enable liquidity vault factory and fund creator for seed") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [32897] ERC20Mock::mint(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, spender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19])
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [0] console::log("[ACT] claimAndSeed + publish flow") [staticcall]
    │   └─ ← [Stop]
    ├─ [5107] DraftClaimManager::digestClaimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5
    ├─ [0] VM::sign("<pk>", 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5) [staticcall]
    │   └─ ← [Return] 28, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db3723, 0x29e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [2440335] DraftClaimManager::claimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db372329e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c1c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 0, creator: 0x0000000000000000000000000000000000000000, proposedAt: 1000 })
    │   ├─ [3000] PRECOMPILES::ecrecover(0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5, 28, 87756954237671935026426394917085252310048454375373261379357242772654481159971, 18953863198541009834522543420160553333867510648071294519348697489063624837004) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [2014286] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   ├─ [1951727] → new LiquidityVault4626@0xDDA0a8D7486686d36449792617565E6C474fBa3f
    │   │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   │   └─ ← [Return] 18
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   │   └─ ← [Return] 9361 bytes of code
    │   │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], asset: ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [32255] ERC20Mock::transferFrom(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 50000000000000000000 [5e19])
    │   │   ├─ emit Transfer(from: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [26927] ERC20Mock::approve(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   ├─ emit Approval(owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], spender: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [92027] LiquidityVault4626::deposit(50000000000000000000 [5e19], DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   │   ├─ [3240] ERC20Mock::balanceOf(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [30255] ERC20Mock::transferFrom(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], to: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   ├─ emit Deposit(sender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], assets: 50000000000000000000 [5e19], shares: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] 50000000000000000000 [5e19]
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimedAndSeeded(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], seedAmount: 50000000000000000000 [5e19], seedShares: 50000000000000000000 [5e19])
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [4415] CREPublishReceiver::digestPublishFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0xa3d13ffd22ad3b2f0c085e011c02adece121aedfd9d0e659063097d79d9480cb, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c
    ├─ [0] VM::sign("<pk>", 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c) [staticcall]
    │   └─ ← [Return] 27, 0x221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca6, 0x1ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca378
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [341953] CREPublishReceiver::onReport(0x, 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f409530000000000000000000000006e9972213bf459853fa33e28ab7219e9157c8d02000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001556800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015568000000000000000000000000000000000000000000000000000000000000000e57696c6c20582068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003596573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca61ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca3781b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [3000] PRECOMPILES::ecrecover(0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c, 27, 15433586014933686281614152704873743811122748588496661600924670613942938844326, 13921034793659172509824973932093933054647154875777596906498168274395459265400) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   ├─ [13512] MarketPolicy::validateDraftWithOutcomesCount(Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 }), 2) [staticcall]
    │   │   └─ ← [Return]
    │   ├─ [251466] MarketFactory::createFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftPublishParams({ question: "Will X happen?", marketType: 0, outcomes: ["Yes", "No"], timelineWindows: [], resolveTime: 87400 [8.74e4], tradingOpen: 0, tradingClose: 87400 [8.74e4] }))
    │   │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   │   ├─ [1065] DraftClaimManager::getLiquidityVault(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   │   ├─ [1293] DraftClaimManager::claimTypeByDraftId(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] 1
    │   │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   │   ├─ [131592] MarketRegistry::createMarketForWithFullParams("Will X happen?", 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   │   ├─ emit MarketCreated(marketId: 0, question: "Will X happen?", creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [47615] MarketRegistry::setLiquidityVault(0, LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f])
    │   │   │   └─ ← [Return]
    │   │   ├─ [6940] MarketDraftBoard::markPublished(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0)
    │   │   │   ├─ emit DraftPublished(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, marketId: 0)
    │   │   │   └─ ← [Return]
    │   │   └─ ← [Return] 0
    │   ├─ emit DraftPublished(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, marketId: 0)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Published draft creates market with linked liquidity vault") [staticcall]
    │   └─ ← [Stop]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 2
    ├─ [1916] MarketRegistry::getCreator(0) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [1416] MarketRegistry::liquidityVaultByMarketId(0) [staticcall]
    │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    └─ ← [Return]

[PASS] testDoublePublishReverts() (gas: 6284035)
Logs:
  [TEST] testDoublePublishReverts
  [ARRANGE] Publish draft once successfully
  [ASSERT] Second publish attempt reverts because draft is no longer claimable

Traces:
  [6323835] CurationFlowTest::testDoublePublishReverts()
    ├─ [0] console::log("[TEST] testDoublePublishReverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Publish draft once successfully") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [32897] ERC20Mock::mint(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, spender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19])
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [5107] DraftClaimManager::digestClaimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5
    ├─ [0] VM::sign("<pk>", 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5) [staticcall]
    │   └─ ← [Return] 28, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db3723, 0x29e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [2440335] DraftClaimManager::claimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db372329e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c1c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 0, creator: 0x0000000000000000000000000000000000000000, proposedAt: 1000 })
    │   ├─ [3000] PRECOMPILES::ecrecover(0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5, 28, 87756954237671935026426394917085252310048454375373261379357242772654481159971, 18953863198541009834522543420160553333867510648071294519348697489063624837004) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [2014286] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   ├─ [1951727] → new LiquidityVault4626@0xDDA0a8D7486686d36449792617565E6C474fBa3f
    │   │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   │   └─ ← [Return] 18
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   │   └─ ← [Return] 9361 bytes of code
    │   │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], asset: ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [32255] ERC20Mock::transferFrom(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 50000000000000000000 [5e19])
    │   │   ├─ emit Transfer(from: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [26927] ERC20Mock::approve(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   ├─ emit Approval(owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], spender: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [92027] LiquidityVault4626::deposit(50000000000000000000 [5e19], DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   │   ├─ [3240] ERC20Mock::balanceOf(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [30255] ERC20Mock::transferFrom(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], to: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   ├─ emit Deposit(sender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], assets: 50000000000000000000 [5e19], shares: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] 50000000000000000000 [5e19]
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimedAndSeeded(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], seedAmount: 50000000000000000000 [5e19], seedShares: 50000000000000000000 [5e19])
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [4415] CREPublishReceiver::digestPublishFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0xa3d13ffd22ad3b2f0c085e011c02adece121aedfd9d0e659063097d79d9480cb, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c
    ├─ [0] VM::sign("<pk>", 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c) [staticcall]
    │   └─ ← [Return] 27, 0x221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca6, 0x1ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca378
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [341953] CREPublishReceiver::onReport(0x, 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f409530000000000000000000000006e9972213bf459853fa33e28ab7219e9157c8d02000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001556800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015568000000000000000000000000000000000000000000000000000000000000000e57696c6c20582068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003596573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca61ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca3781b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [3000] PRECOMPILES::ecrecover(0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c, 27, 15433586014933686281614152704873743811122748588496661600924670613942938844326, 13921034793659172509824973932093933054647154875777596906498168274395459265400) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   ├─ [13512] MarketPolicy::validateDraftWithOutcomesCount(Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 }), 2) [staticcall]
    │   │   └─ ← [Return]
    │   ├─ [251466] MarketFactory::createFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftPublishParams({ question: "Will X happen?", marketType: 0, outcomes: ["Yes", "No"], timelineWindows: [], resolveTime: 87400 [8.74e4], tradingOpen: 0, tradingClose: 87400 [8.74e4] }))
    │   │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   │   ├─ [1065] DraftClaimManager::getLiquidityVault(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   │   ├─ [1293] DraftClaimManager::claimTypeByDraftId(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] 1
    │   │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   │   ├─ [131592] MarketRegistry::createMarketForWithFullParams("Will X happen?", 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   │   ├─ emit MarketCreated(marketId: 0, question: "Will X happen?", creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [47615] MarketRegistry::setLiquidityVault(0, LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f])
    │   │   │   └─ ← [Return]
    │   │   ├─ [6940] MarketDraftBoard::markPublished(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0)
    │   │   │   ├─ emit DraftPublished(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, marketId: 0)
    │   │   │   └─ ← [Return]
    │   │   └─ ← [Return] 0
    │   ├─ emit DraftPublished(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, marketId: 0)
    │   └─ ← [Return]
    ├─ [2415] CREPublishReceiver::digestPublishFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0xa3d13ffd22ad3b2f0c085e011c02adece121aedfd9d0e659063097d79d9480cb, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x1e4a76aad22953c5a786bd2e077feefe7007f4f95ce3e29efe0487e210de021d
    ├─ [0] VM::sign("<pk>", 0x1e4a76aad22953c5a786bd2e077feefe7007f4f95ce3e29efe0487e210de021d) [staticcall]
    │   └─ ← [Return] 27, 0xb666e1ca4b52d72918fc972808e857627c782791792028830554c7a1fd40c5ad, 0x0cf3704bf99a412d827822b24794b7496d01c78e550386c1d841192fcd3eaf60
    ├─ [0] console::log("[ASSERT] Second publish attempt reverts because draft is no longer claimable") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: 1d010ba300000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [11291] CREPublishReceiver::onReport(0x, 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f409530000000000000000000000006e9972213bf459853fa33e28ab7219e9157c8d02000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001556800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015568000000000000000000000000000000000000000000000000000000000000000e57696c6c20582068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003596573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041b666e1ca4b52d72918fc972808e857627c782791792028830554c7a1fd40c5ad0cf3704bf99a412d827822b24794b7496d01c78e550386c1d841192fcd3eaf601b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 2
    │   └─ ← [Revert] DraftNotClaimed()
    └─ ← [Return]

[PASS] testDraftPipelineProposeClaimPublishCreatesMarket() (gas: 6271384)
Logs:
  [TEST] testDraftPipelineProposeClaimPublishCreatesMarket
  [ARRANGE] Propose draft with seed, claimAndSeed, then publish
  [ASSERT] Draft is published and market metadata matches creator/question

Traces:
  [6311184] CurationFlowTest::testDraftPipelineProposeClaimPublishCreatesMarket()
    ├─ [0] console::log("[TEST] testDraftPipelineProposeClaimPublishCreatesMarket") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Propose draft with seed, claimAndSeed, then publish") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [32897] ERC20Mock::mint(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, spender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 1)
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [5107] DraftClaimManager::digestClaimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5
    ├─ [0] VM::sign("<pk>", 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5) [staticcall]
    │   └─ ← [Return] 28, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db3723, 0x29e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [2440335] DraftClaimManager::claimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db372329e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c1c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 1, status: 0, creator: 0x0000000000000000000000000000000000000000, proposedAt: 1000 })
    │   ├─ [3000] PRECOMPILES::ecrecover(0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5, 28, 87756954237671935026426394917085252310048454375373261379357242772654481159971, 18953863198541009834522543420160553333867510648071294519348697489063624837004) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [2014286] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   ├─ [1951727] → new LiquidityVault4626@0xDDA0a8D7486686d36449792617565E6C474fBa3f
    │   │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   │   └─ ← [Return] 18
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   │   └─ ← [Return] 9361 bytes of code
    │   │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], asset: ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [32255] ERC20Mock::transferFrom(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 50000000000000000000 [5e19])
    │   │   ├─ emit Transfer(from: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [26927] ERC20Mock::approve(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   ├─ emit Approval(owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], spender: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [92027] LiquidityVault4626::deposit(50000000000000000000 [5e19], DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   │   ├─ [3240] ERC20Mock::balanceOf(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [30255] ERC20Mock::transferFrom(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], to: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   ├─ emit Deposit(sender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], assets: 50000000000000000000 [5e19], shares: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] 50000000000000000000 [5e19]
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimedAndSeeded(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], seedAmount: 50000000000000000000 [5e19], seedShares: 50000000000000000000 [5e19])
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [4415] CREPublishReceiver::digestPublishFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0xa3d13ffd22ad3b2f0c085e011c02adece121aedfd9d0e659063097d79d9480cb, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c
    ├─ [0] VM::sign("<pk>", 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c) [staticcall]
    │   └─ ← [Return] 27, 0x221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca6, 0x1ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca378
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [341953] CREPublishReceiver::onReport(0x, 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f409530000000000000000000000006e9972213bf459853fa33e28ab7219e9157c8d02000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001556800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015568000000000000000000000000000000000000000000000000000000000000000e57696c6c20582068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003596573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca61ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca3781b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [3000] PRECOMPILES::ecrecover(0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c, 27, 15433586014933686281614152704873743811122748588496661600924670613942938844326, 13921034793659172509824973932093933054647154875777596906498168274395459265400) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 1, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   ├─ [13512] MarketPolicy::validateDraftWithOutcomesCount(Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 1, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 }), 2) [staticcall]
    │   │   └─ ← [Return]
    │   ├─ [251466] MarketFactory::createFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftPublishParams({ question: "Will X happen?", marketType: 0, outcomes: ["Yes", "No"], timelineWindows: [], resolveTime: 87400 [8.74e4], tradingOpen: 0, tradingClose: 87400 [8.74e4] }))
    │   │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 1, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   │   ├─ [1065] DraftClaimManager::getLiquidityVault(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   │   ├─ [1293] DraftClaimManager::claimTypeByDraftId(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] 1
    │   │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   │   ├─ [131592] MarketRegistry::createMarketForWithFullParams("Will X happen?", 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   │   ├─ emit MarketCreated(marketId: 0, question: "Will X happen?", creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [47615] MarketRegistry::setLiquidityVault(0, LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f])
    │   │   │   └─ ← [Return]
    │   │   ├─ [6940] MarketDraftBoard::markPublished(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0)
    │   │   │   ├─ emit DraftPublished(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, marketId: 0)
    │   │   │   └─ ← [Return]
    │   │   └─ ← [Return] 0
    │   ├─ emit DraftPublished(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, marketId: 0)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Draft is published and market metadata matches creator/question") [staticcall]
    │   └─ ← [Stop]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 2
    ├─ [1152] MarketFactory::draftIdByMarketId(0) [staticcall]
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [8556] MarketRegistry::getMarket(0) [staticcall]
    │   └─ ← [Return] Market({ creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, createdAt: 1000, expiry: 87400 [8.74e4], tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settledAt: 0, settled: false, frozen: false, confidence: 0, outcome: 0, question: "Will X happen?" })
    ├─ [0] VM::assertEq("Will X happen?", "Will X happen?") [staticcall]
    │   └─ ← [Return]
    └─ ← [Return]

[PASS] testPolicyMinCreatorSeedEnforcedOnPublish() (gas: 6016450)
Logs:
  [TEST] testPolicyMinCreatorSeedEnforcedOnPublish
  [ARRANGE] Policy min seed = 100 ether, draft min seed only 50 ether
  [ASSERT] Publish report reverts with SeedTooLow

Traces:
  [6056250] CurationFlowTest::testPolicyMinCreatorSeedEnforcedOnPublish()
    ├─ [0] console::log("[TEST] testPolicyMinCreatorSeedEnforcedOnPublish") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Policy min seed = 100 ether, draft min seed only 50 ether") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [27127] MarketPolicy::setMinCreatorSeed(100000000000000000000 [1e20])
    │   ├─ emit MinCreatorSeedUpdated(previous: 0, current: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [32897] ERC20Mock::mint(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, spender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19])
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [5107] DraftClaimManager::digestClaimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5
    ├─ [0] VM::sign("<pk>", 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5) [staticcall]
    │   └─ ← [Return] 28, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db3723, 0x29e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [2440335] DraftClaimManager::claimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db372329e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c1c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 0, creator: 0x0000000000000000000000000000000000000000, proposedAt: 1000 })
    │   ├─ [3000] PRECOMPILES::ecrecover(0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5, 28, 87756954237671935026426394917085252310048454375373261379357242772654481159971, 18953863198541009834522543420160553333867510648071294519348697489063624837004) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [2014286] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   ├─ [1951727] → new LiquidityVault4626@0xDDA0a8D7486686d36449792617565E6C474fBa3f
    │   │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   │   └─ ← [Return] 18
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   │   └─ ← [Return] 9361 bytes of code
    │   │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], asset: ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [32255] ERC20Mock::transferFrom(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 50000000000000000000 [5e19])
    │   │   ├─ emit Transfer(from: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [26927] ERC20Mock::approve(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   ├─ emit Approval(owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], spender: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [92027] LiquidityVault4626::deposit(50000000000000000000 [5e19], DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   │   ├─ [3240] ERC20Mock::balanceOf(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [30255] ERC20Mock::transferFrom(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], to: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   ├─ emit Deposit(sender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], assets: 50000000000000000000 [5e19], shares: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] 50000000000000000000 [5e19]
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimedAndSeeded(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], seedAmount: 50000000000000000000 [5e19], seedShares: 50000000000000000000 [5e19])
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [4415] CREPublishReceiver::digestPublishFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0xa3d13ffd22ad3b2f0c085e011c02adece121aedfd9d0e659063097d79d9480cb, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c
    ├─ [0] VM::sign("<pk>", 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c) [staticcall]
    │   └─ ← [Return] 27, 0x221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca6, 0x1ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca378
    ├─ [0] console::log("[ASSERT] Publish report reverts with SeedTooLow") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: bdc0511100000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [76183] CREPublishReceiver::onReport(0x, 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f409530000000000000000000000006e9972213bf459853fa33e28ab7219e9157c8d02000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001556800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015568000000000000000000000000000000000000000000000000000000000000000e57696c6c20582068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003596573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca61ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca3781b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [3000] PRECOMPILES::ecrecover(0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c, 27, 15433586014933686281614152704873743811122748588496661600924670613942938844326, 13921034793659172509824973932093933054647154875777596906498168274395459265400) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   ├─ [7619] MarketPolicy::validateDraftWithOutcomesCount(Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 }), 2) [staticcall]
    │   │   └─ ← [Revert] SeedTooLow()
    │   └─ ← [Revert] SeedTooLow()
    └─ ← [Return]

[PASS] testPublishRejectsDraftTimeMismatch() (gas: 6019046)
Logs:
  [TEST] testPublishRejectsDraftTimeMismatch
  [ARRANGE] Publish params use tradingClose different from proposed draft
  [ASSERT] Publish report reverts with DraftTimeMismatch

Traces:
  [6058846] CurationFlowTest::testPublishRejectsDraftTimeMismatch()
    ├─ [0] console::log("[TEST] testPublishRejectsDraftTimeMismatch") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Publish params use tradingClose different from proposed draft") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [32897] ERC20Mock::mint(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, spender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 1)
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [5107] DraftClaimManager::digestClaimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5
    ├─ [0] VM::sign("<pk>", 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5) [staticcall]
    │   └─ ← [Return] 28, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db3723, 0x29e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [2440335] DraftClaimManager::claimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db372329e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c1c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 1, status: 0, creator: 0x0000000000000000000000000000000000000000, proposedAt: 1000 })
    │   ├─ [3000] PRECOMPILES::ecrecover(0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5, 28, 87756954237671935026426394917085252310048454375373261379357242772654481159971, 18953863198541009834522543420160553333867510648071294519348697489063624837004) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [2014286] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   ├─ [1951727] → new LiquidityVault4626@0xDDA0a8D7486686d36449792617565E6C474fBa3f
    │   │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   │   └─ ← [Return] 18
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   │   └─ ← [Return] 9361 bytes of code
    │   │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], asset: ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [32255] ERC20Mock::transferFrom(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 50000000000000000000 [5e19])
    │   │   ├─ emit Transfer(from: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [26927] ERC20Mock::approve(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   ├─ emit Approval(owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], spender: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [92027] LiquidityVault4626::deposit(50000000000000000000 [5e19], DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   │   ├─ [3240] ERC20Mock::balanceOf(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [30255] ERC20Mock::transferFrom(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], to: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   ├─ emit Deposit(sender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], assets: 50000000000000000000 [5e19], shares: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] 50000000000000000000 [5e19]
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimedAndSeeded(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], seedAmount: 50000000000000000000 [5e19], seedShares: 50000000000000000000 [5e19])
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [4415] CREPublishReceiver::digestPublishFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x15ae7c16e72908baa5c1272b69a6c7f2f7e7052def1814b9d5d197643f37d1ab, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0xbf21fbf595a8e340e52ba0b1c3d1e5e2d11494ff5be4f14146011be382e32606
    ├─ [0] VM::sign("<pk>", 0xbf21fbf595a8e340e52ba0b1c3d1e5e2d11494ff5be4f14146011be382e32606) [staticcall]
    │   └─ ← [Return] 28, 0x1b3f9610c7a52094b9c3e38691bac44a2c89590cd83a8655693a400c63375c4d, 0x237656836bd6c5bf58c04056e3d9c20c0ed217e41609919f02ad66ffbf15d41f
    ├─ [0] console::log("[ASSERT] Publish report reverts with DraftTimeMismatch") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: 2763889800000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [111766] CREPublishReceiver::onReport(0x, 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f409530000000000000000000000006e9972213bf459853fa33e28ab7219e9157c8d02000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001556800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016378000000000000000000000000000000000000000000000000000000000000000e57696c6c20582068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003596573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000411b3f9610c7a52094b9c3e38691bac44a2c89590cd83a8655693a400c63375c4d237656836bd6c5bf58c04056e3d9c20c0ed217e41609919f02ad66ffbf15d41f1c00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [3000] PRECOMPILES::ecrecover(0xbf21fbf595a8e340e52ba0b1c3d1e5e2d11494ff5be4f14146011be382e32606, 28, 12324793991165471418437654240599260688941198550273414953257058302739279731789, 16040034747353777799426328922262500072441520943361653941226889768008274007071) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 1, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   ├─ [13512] MarketPolicy::validateDraftWithOutcomesCount(Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 1, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 }), 2) [staticcall]
    │   │   └─ ← [Return]
    │   ├─ [24033] MarketFactory::createFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftPublishParams({ question: "Will X happen?", marketType: 0, outcomes: ["Yes", "No"], timelineWindows: [], resolveTime: 87400 [8.74e4], tradingOpen: 0, tradingClose: 91000 [9.1e4] }))
    │   │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 1, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   │   └─ ← [Revert] DraftTimeMismatch()
    │   └─ ← [Revert] DraftTimeMismatch()
    └─ ← [Return]

[PASS] testPublishRequiresSeedWhenMinSeedPositive() (gas: 3685034)
Logs:
  [TEST] testPublishRequiresSeedWhenMinSeedPositive
  [ARRANGE] Draft requires seed, but creator uses legacy claim path (no seed)
  [ASSERT] Publish report reverts with SeededClaimRequired

Traces:
  [3685034] CurationFlowTest::testPublishRequiresSeedWhenMinSeedPositive()
    ├─ [0] console::log("[TEST] testPublishRequiresSeedWhenMinSeedPositive") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Draft requires seed, but creator uses legacy claim path (no seed)") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19])
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [4861] DraftClaimManager::digestClaimDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0, 0x0000000000000000000000000000000000000000000000000000000000000000, 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x8c1455fa15d0a96541dd9931c4370812f51db27cebbe5bbdc89b3293f46f7e6d
    ├─ [0] VM::sign("<pk>", 0x8c1455fa15d0a96541dd9931c4370812f51db27cebbe5bbdc89b3293f46f7e6d) [staticcall]
    │   └─ ← [Return] 28, 0x460b7d1b7f124604b229be8cdbf3a65cdd267fd225119d62dfc593bddf1692d1, 0x6206a7a8cf0c475a33d836e635fd7eb692aab92027ea84824c1ac6d5d8372d63
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [125057] DraftClaimManager::claimDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0, 0x0000000000000000000000000000000000000000000000000000000000000000, 0, 0x460b7d1b7f124604b229be8cdbf3a65cdd267fd225119d62dfc593bddf1692d16206a7a8cf0c475a33d836e635fd7eb692aab92027ea84824c1ac6d5d8372d631c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [3000] PRECOMPILES::ecrecover(0x8c1455fa15d0a96541dd9931c4370812f51db27cebbe5bbdc89b3293f46f7e6d, 28, 31682198178135296574853570108519853617233003974035609443825178021180160250577, 44338417386264426019898080021037156475501574217289230451191733465686767775075) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, bond: 0, seedCommitment: 0x0000000000000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [4415] CREPublishReceiver::digestPublishFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0xa3d13ffd22ad3b2f0c085e011c02adece121aedfd9d0e659063097d79d9480cb, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c
    ├─ [0] VM::sign("<pk>", 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c) [staticcall]
    │   └─ ← [Return] 27, 0x221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca6, 0x1ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca378
    ├─ [0] console::log("[ASSERT] Publish report reverts with SeededClaimRequired") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: 579b03e500000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [121107] CREPublishReceiver::onReport(0x, 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f409530000000000000000000000006e9972213bf459853fa33e28ab7219e9157c8d02000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001556800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015568000000000000000000000000000000000000000000000000000000000000000e57696c6c20582068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003596573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca61ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca3781b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [3000] PRECOMPILES::ecrecover(0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c, 27, 15433586014933686281614152704873743811122748588496661600924670613942938844326, 13921034793659172509824973932093933054647154875777596906498168274395459265400) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   ├─ [13512] MarketPolicy::validateDraftWithOutcomesCount(Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 }), 2) [staticcall]
    │   │   └─ ← [Return]
    │   ├─ [33374] MarketFactory::createFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftPublishParams({ question: "Will X happen?", marketType: 0, outcomes: ["Yes", "No"], timelineWindows: [], resolveTime: 87400 [8.74e4], tradingOpen: 0, tradingClose: 87400 [8.74e4] }))
    │   │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   │   ├─ [3065] DraftClaimManager::getLiquidityVault(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000
    │   │   ├─ [1293] DraftClaimManager::claimTypeByDraftId(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   └─ ← [Revert] SeededClaimRequired()
    │   └─ ← [Revert] SeededClaimRequired()
    └─ ← [Return]

[PASS] testPublishWithLegacyClaimRevertsWhenSeededRequired() (gas: 3665238)
Logs:
  [TEST] testPublishWithLegacyClaimRevertsWhenSeededRequired
  [ARRANGE] Seed-required draft is claimed with legacy (non-seeded) claim path
  [ASSERT] Publish via CRE receiver reverts with SeededClaimRequired

Traces:
  [3665238] CurationFlowTest::testPublishWithLegacyClaimRevertsWhenSeededRequired()
    ├─ [0] console::log("[TEST] testPublishWithLegacyClaimRevertsWhenSeededRequired") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Seed-required draft is claimed with legacy (non-seeded) claim path") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [249741] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 0)
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [4861] DraftClaimManager::digestClaimDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0, 0x0000000000000000000000000000000000000000000000000000000000000000, 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x8c1455fa15d0a96541dd9931c4370812f51db27cebbe5bbdc89b3293f46f7e6d
    ├─ [0] VM::sign("<pk>", 0x8c1455fa15d0a96541dd9931c4370812f51db27cebbe5bbdc89b3293f46f7e6d) [staticcall]
    │   └─ ← [Return] 28, 0x460b7d1b7f124604b229be8cdbf3a65cdd267fd225119d62dfc593bddf1692d1, 0x6206a7a8cf0c475a33d836e635fd7eb692aab92027ea84824c1ac6d5d8372d63
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [125057] DraftClaimManager::claimDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0, 0x0000000000000000000000000000000000000000000000000000000000000000, 0, 0x460b7d1b7f124604b229be8cdbf3a65cdd267fd225119d62dfc593bddf1692d16206a7a8cf0c475a33d836e635fd7eb692aab92027ea84824c1ac6d5d8372d631c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [3000] PRECOMPILES::ecrecover(0x8c1455fa15d0a96541dd9931c4370812f51db27cebbe5bbdc89b3293f46f7e6d, 28, 31682198178135296574853570108519853617233003974035609443825178021180160250577, 44338417386264426019898080021037156475501574217289230451191733465686767775075) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, bond: 0, seedCommitment: 0x0000000000000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [4415] CREPublishReceiver::digestPublishFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0xa3d13ffd22ad3b2f0c085e011c02adece121aedfd9d0e659063097d79d9480cb, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c
    ├─ [0] VM::sign("<pk>", 0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c) [staticcall]
    │   └─ ← [Return] 27, 0x221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca6, 0x1ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca378
    ├─ [0] console::log("[ASSERT] Publish via CRE receiver reverts with SeededClaimRequired") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::prank(0x0000000000000000000000000000000000001234)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: 579b03e500000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [121107] CREPublishReceiver::onReport(0x, 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f409530000000000000000000000006e9972213bf459853fa33e28ab7219e9157c8d02000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000001556800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015568000000000000000000000000000000000000000000000000000000000000000e57696c6c20582068617070656e3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000003596573000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041221f19a1bcd05672b47c5bb1ad3cbaefb7c04e1fd6f5014fce1477fb233b3ca61ec706c6ce451bb15660e7c3c58bf772b65b64ef16e1e2a44419d6a10ceca3781b00000000000000000000000000000000000000000000000000000000000000)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [3000] PRECOMPILES::ecrecover(0x65c23afc871454f9c4cf96ddee841c3f9dbd045ff98e72f7624262caefec877c, 27, 15433586014933686281614152704873743811122748588496661600924670613942938844326, 13921034793659172509824973932093933054647154875777596906498168274395459265400) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 0, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   ├─ [13512] MarketPolicy::validateDraftWithOutcomesCount(Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 0, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 }), 2) [staticcall]
    │   │   └─ ← [Return]
    │   ├─ [33374] MarketFactory::createFromDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftPublishParams({ question: "Will X happen?", marketType: 0, outcomes: ["Yes", "No"], timelineWindows: [], resolveTime: 87400 [8.74e4], tradingOpen: 0, tradingClose: 87400 [8.74e4] }))
    │   │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 0, status: 1, creator: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, proposedAt: 1000 })
    │   │   ├─ [3065] DraftClaimManager::getLiquidityVault(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000
    │   │   ├─ [1293] DraftClaimManager::claimTypeByDraftId(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   └─ ← [Revert] SeededClaimRequired()
    │   └─ ← [Revert] SeededClaimRequired()
    └─ ← [Return]

[PASS] testUnlockSeedSharesBeforeTradingCloseReverts() (gas: 5879956)
Logs:
  [TEST] testUnlockSeedSharesBeforeTradingCloseReverts
  [ARRANGE] Claim-and-seed draft, then warp before trading close
  [ASSERT] Unlocking seed shares before unlock time reverts

Traces:
  [5919756] CurationFlowTest::testUnlockSeedSharesBeforeTradingCloseReverts()
    ├─ [0] console::log("[TEST] testUnlockSeedSharesBeforeTradingCloseReverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Claim-and-seed draft, then warp before trading close") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [32897] ERC20Mock::mint(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, spender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19])
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [5107] DraftClaimManager::digestClaimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5
    ├─ [0] VM::sign("<pk>", 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5) [staticcall]
    │   └─ ← [Return] 28, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db3723, 0x29e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [2440335] DraftClaimManager::claimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db372329e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c1c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 0, creator: 0x0000000000000000000000000000000000000000, proposedAt: 1000 })
    │   ├─ [3000] PRECOMPILES::ecrecover(0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5, 28, 87756954237671935026426394917085252310048454375373261379357242772654481159971, 18953863198541009834522543420160553333867510648071294519348697489063624837004) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [2014286] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   ├─ [1951727] → new LiquidityVault4626@0xDDA0a8D7486686d36449792617565E6C474fBa3f
    │   │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   │   └─ ← [Return] 18
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   │   └─ ← [Return] 9361 bytes of code
    │   │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], asset: ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [32255] ERC20Mock::transferFrom(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 50000000000000000000 [5e19])
    │   │   ├─ emit Transfer(from: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [26927] ERC20Mock::approve(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   ├─ emit Approval(owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], spender: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [92027] LiquidityVault4626::deposit(50000000000000000000 [5e19], DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   │   ├─ [3240] ERC20Mock::balanceOf(LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [30255] ERC20Mock::transferFrom(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], to: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   ├─ emit Deposit(sender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], assets: 50000000000000000000 [5e19], shares: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] 50000000000000000000 [5e19]
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimedAndSeeded(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], seedAmount: 50000000000000000000 [5e19], seedShares: 50000000000000000000 [5e19])
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [0] console::log("[ASSERT] Unlocking seed shares before unlock time reverts") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::warp(2000)
    │   └─ ← [Return]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: N޽)
    │   └─ ← [Return]
    ├─ [1930] DraftClaimManager::unlockSeedShares(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953)
    │   └─ ← [Revert] UnlockTimeNotReached()
    └─ ← [Return]

[PASS] testVaultFactoryWrongAssetCanBeReplaced() (gas: 8707954)
Logs:
  [TEST] testVaultFactoryWrongAssetCanBeReplaced
  [ARRANGE] Pre-create wrong-asset vault for same draft id
  [ACT] claimAndSeed should replace wrong vault with token-backed vault
  [ASSERT] Final vault asset equals settlement token

Traces:
  [8747754] CurationFlowTest::testVaultFactoryWrongAssetCanBeReplaced()
    ├─ [0] console::log("[TEST] testVaultFactoryWrongAssetCanBeReplaced") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Pre-create wrong-asset vault for same draft id") [staticcall]
    │   └─ ← [Stop]
    ├─ [2977674] → new LiquidityVaultFactory@0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return] 14731 bytes of code
    ├─ [2942] DraftClaimManager::owner() [staticcall]
    │   └─ ← [Return] CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [26047] DraftClaimManager::setLiquidityVaultFactory(LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   ├─ emit LiquidityVaultFactoryUpdated(previous: 0x0000000000000000000000000000000000000000, current: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   └─ ← [Return]
    ├─ [26425] MarketFactory::setDraftClaimManager(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   └─ ← [Return]
    ├─ [796109] → new ERC20Mock@0x15cF58144EF33af1e14b5208015d11F9143E27b9
    │   └─ ← [Return] 3745 bytes of code
    ├─ [0] VM::prank(CurationFlowTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496])
    │   └─ ← [Return]
    ├─ [269641] MarketDraftBoard::proposeDraft(0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, "ipfs://QmQuestion", 0, 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, "ipfs://QmOutcomes", 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, 0, 87400 [8.74e4], 87400 [8.74e4], ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19])
    │   ├─ emit DraftProposed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, marketType: 0, resolveTime: 87400 [8.74e4])
    │   └─ ← [Return] 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0
    ├─ [2014286] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x15cF58144EF33af1e14b5208015d11F9143E27b9])
    │   ├─ [1951727] → new LiquidityVault4626@0xDDA0a8D7486686d36449792617565E6C474fBa3f
    │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   └─ ← [Return] 18
    │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   └─ ← [Return] 9361 bytes of code
    │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f], asset: ERC20Mock: [0x15cF58144EF33af1e14b5208015d11F9143E27b9])
    │   └─ ← [Return] LiquidityVault4626: [0xDDA0a8D7486686d36449792617565E6C474fBa3f]
    ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   └─ ← [Return] ERC20Mock: [0x15cF58144EF33af1e14b5208015d11F9143E27b9]
    ├─ [32897] ERC20Mock::mint(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, spender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] console::log("[ACT] claimAndSeed should replace wrong vault with token-backed vault") [staticcall]
    │   └─ ← [Stop]
    ├─ [5107] DraftClaimManager::digestClaimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02) [staticcall]
    │   └─ ← [Return] 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5
    ├─ [0] VM::sign("<pk>", 0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5) [staticcall]
    │   └─ ← [Return] 28, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db3723, 0x29e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c
    ├─ [0] VM::prank(0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   └─ ← [Return]
    ├─ [2420565] DraftClaimManager::claimAndSeed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 50000000000000000000 [5e19], 0, 0xc204ad083d5b37659f238fa637034100fd96e054ac88c5ac8d686bcd59db372329e781a38d9c130ad4392162842e715a4bb8ee4f98df57ba6e00df52c064078c1c)
    │   ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [9444] MarketDraftBoard::getDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   │   └─ ← [Return] Draft({ questionHash: 0x20f54887792ccb1edf4fd168144bdc5f99bdeec65a17d75ab9e0f991ed39599d, questionURI: "ipfs://QmQuestion", marketType: 0, outcomesHash: 0xd06838ea817cceca4205200d1a3a08b47ee3314b635079f68f67f03a9477a951, outcomesURI: "ipfs://QmOutcomes", resolveSpecHash: 0xef84b0e7ecb60bf8ad633d04a99a4d056e764e8aca31c69c4b77ca60b1419628, tradingOpen: 0, tradingClose: 87400 [8.74e4], resolveTime: 87400 [8.74e4], settlementAsset: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, minSeed: 50000000000000000000 [5e19], status: 0, creator: 0x0000000000000000000000000000000000000000, proposedAt: 1000 })
    │   ├─ [3000] PRECOMPILES::ecrecover(0x7c504adb8ded55e3dbfcb64e4d9d4699a4e1f13764ed4fe33d9064a959d526c5, 28, 87756954237671935026426394917085252310048454375373261379357242772654481159971, 18953863198541009834522543420160553333867510648071294519348697489063624837004) [staticcall]
    │   │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    │   ├─ [1994516] LiquidityVaultFactory::createVaultForDraft(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   │   └─ ← [Return] ERC20Mock: [0x15cF58144EF33af1e14b5208015d11F9143E27b9]
    │   │   ├─ [1951727] → new LiquidityVault4626@0x19a75C5AE908D442fbdbe3F03AfECF6231107e27
    │   │   │   ├─ [626] ERC20Mock::decimals() [staticcall]
    │   │   │   │   └─ ← [Return] 18
    │   │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: LiquidityVaultFactory: [0xD6BbDE9174b1CdAa358d2Cf4D57D1a9F7178FBfF])
    │   │   │   └─ ← [Return] 9361 bytes of code
    │   │   ├─ emit VaultCreated(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, vault: LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27], asset: ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f])
    │   │   └─ ← [Return] LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27]
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [32255] ERC20Mock::transferFrom(0x6E9972213BF459853FA33E28Ab7219e9157C8d02, DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], 50000000000000000000 [5e19])
    │   │   ├─ emit Transfer(from: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [26927] ERC20Mock::approve(LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27], 50000000000000000000 [5e19])
    │   │   ├─ emit Approval(owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], spender: LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27], value: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] true
    │   ├─ [92027] LiquidityVault4626::deposit(50000000000000000000 [5e19], DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598])
    │   │   ├─ [3240] ERC20Mock::balanceOf(LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27]) [staticcall]
    │   │   │   └─ ← [Return] 0
    │   │   ├─ [30255] ERC20Mock::transferFrom(DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27], 50000000000000000000 [5e19])
    │   │   │   ├─ emit Transfer(from: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], to: LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27], value: 50000000000000000000 [5e19])
    │   │   │   └─ ← [Return] true
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], value: 50000000000000000000 [5e19])
    │   │   ├─ emit Deposit(sender: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], owner: DraftClaimManager: [0xa0Cb889707d426A7A386870A03bc70d1b0697598], assets: 50000000000000000000 [5e19], shares: 50000000000000000000 [5e19])
    │   │   └─ ← [Return] 50000000000000000000 [5e19]
    │   ├─ [27208] MarketDraftBoard::setClaimed(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   ├─ emit DraftClaimed(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02)
    │   │   └─ ← [Return]
    │   ├─ emit DraftClaimedAndSeeded(draftId: 0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953, claimer: 0x6E9972213BF459853FA33E28Ab7219e9157C8d02, vault: LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27], seedAmount: 50000000000000000000 [5e19], seedShares: 50000000000000000000 [5e19])
    │   └─ ← [Return]
    ├─ [1156] MarketDraftBoard::getStatus(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 1
    ├─ [1246] DraftClaimManager::getClaimer(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] 0x6E9972213BF459853FA33E28Ab7219e9157C8d02
    ├─ [1065] DraftClaimManager::getLiquidityVault(0x668dfbe24c9b81435f0572f5137ff04065e4c56fd139e4fd80a30577f4f40953) [staticcall]
    │   └─ ← [Return] LiquidityVault4626: [0x19a75C5AE908D442fbdbe3F03AfECF6231107e27]
    ├─ [0] console::log("[ASSERT] Final vault asset equals settlement token") [staticcall]
    │   └─ ← [Stop]
    ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    └─ ← [Return]

Suite result: ok. 10 passed; 0 failed; 0 skipped; finished in 23.39ms (18.45ms CPU time)

Ran 2 tests for test/InvariantSolvency.t.sol:InvariantSolvencyTest
[PASS] testFinalizeWithLpMarketRequiresVault() (gas: 448700)
Logs:
  [TEST] testFinalizeWithLpMarketRequiresVault
  [ARRANGE] Create LP market then clear its liquidity vault reference
  [ACT] Submit checkpoint and finalize after deadline
  [ASSERT] Finalize reverts because LP market must have liquidity vault

Traces:
  [468600] InvariantSolvencyTest::testFinalizeWithLpMarketRequiresVault()
    ├─ [0] console::log("[TEST] testFinalizeWithLpMarketRequiresVault") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Create LP market then clear its liquidity vault reference") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startPrank(ECRecover: [0x0000000000000000000000000000000000000001])
    │   └─ ← [Return]
    ├─ [113744] MarketRegistry::createMarketForWithExpiryAndAsset("LP Market", ECRecover: [0x0000000000000000000000000000000000000001], 86401 [8.64e4], ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459])
    │   ├─ emit MarketCreated(marketId: 1, question: "LP Market", creator: ECRecover: [0x0000000000000000000000000000000000000001])
    │   └─ ← [Return] 1
    ├─ [47615] MarketRegistry::setLiquidityVault(1, LiquidityVault4626: [0x90A5b0DD8c4b06636A4BEf7BA82D9C58f44fAaAd])
    │   └─ ← [Return]
    ├─ [3172] MarketRegistry::setLiquidityVault(1, 0x0000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Submit checkpoint and finalize after deadline") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x1eb0be809c726d7d593024bb68f076a3b9a63b7d6858305c14febc0e9d73e09d
    ├─ [0] VM::sign("<pk>", 0x1eb0be809c726d7d593024bb68f076a3b9a63b7d6858305c14febc0e9d73e09d) [staticcall]
    │   └─ ← [Return] 27, 0xdceabefac4740471a38aafbd38afe9152ae49c427d6ee8b639827015014d75cd, 0x1382d7d3d97ef2d2e43e8f83bc06d5898e34b5519844ae517f2a9a56a4af6d95
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x1eb0be809c726d7d593024bb68f076a3b9a63b7d6858305c14febc0e9d73e09d
    ├─ [0] VM::sign("<pk>", 0x1eb0be809c726d7d593024bb68f076a3b9a63b7d6858305c14febc0e9d73e09d) [staticcall]
    │   └─ ← [Return] 27, 0xefda405022e8a4b65cc9aec1bd2175b27b0494af32b1807aba46039a304d270c, 0x784422639101dfd6dd006c761ca21f22ff886a91f15b63640afad8d9f3d5eb1f
    ├─ [129878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })], 0xdceabefac4740471a38aafbd38afe9152ae49c427d6ee8b639827015014d75cd1382d7d3d97ef2d2e43e8f83bc06d5898e34b5519844ae517f2a9a56a4af6d951b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xefda405022e8a4b65cc9aec1bd2175b27b0494af32b1807aba46039a304d270c784422639101dfd6dd006c761ca21f22ff886a91f15b63640afad8d9f3d5eb1f1b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x1eb0be809c726d7d593024bb68f076a3b9a63b7d6858305c14febc0e9d73e09d, 27, 99923586993958240310307596726492068879372041632367832767565662471675974612429, 8825123828421548970365421325068157532376354730696516545733800175993673969045) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x1eb0be809c726d7d593024bb68f076a3b9a63b7d6858305c14febc0e9d73e09d, 27, 108488387343760604436809711946973575287807473574104109808365602190821470054156, 54397924774078461030275384219616280681639672126175599417919211433863815752479) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0x2e03638da05b1b26a86e3d1a30b982d9cc8da1bfe59dfb6e177ab1033dd13d9a)
    │   └─ ← [Return]
    ├─ [0] VM::warp(1861)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Finalize reverts because LP market must have liquidity vault") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::expectRevert(custom error 0xc31eb0e0: d5fc189e00000000000000000000000000000000000000000000000000000000)
    │   └─ ← [Return]
    ├─ [96778] ChannelSettlement::finalizeCheckpoint(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })])
    │   ├─ [6243] MarketRegistry::status(1) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1798] MarketRegistry::getTradingClose(1) [staticcall]
    │   │   └─ ← [Return] 86401 [8.64e4]
    │   ├─ [29793] ExecutionLedger::applyDeltas(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100 })])
    │   │   ├─ emit DeltasApplied(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, deltaCount: 1)
    │   │   └─ ← [Return]
    │   ├─ [1040] CollateralVault::token() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459]
    │   ├─ [14248] CollateralVault::applyCashDeltas(1, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [-100])
    │   │   ├─ emit CashDeltasApplied(marketId: 1, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, userCount: 1)
    │   │   └─ ← [Return]
    │   ├─ [1416] MarketRegistry::liquidityVaultByMarketId(1) [staticcall]
    │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000
    │   ├─ [1824] MarketRegistry::usesLpVaultByMarketId(1) [staticcall]
    │   │   └─ ← [Return] true
    │   └─ ← [Revert] LiquidityVaultRequired()
    └─ ← [Return]

[PASS] testLpFeeWithNoLpSupplyRoutesToTreasury() (gas: 595605)
Logs:
  [TEST] testLpFeeWithNoLpSupplyRoutesToTreasury
  [ARRANGE] LP fee share enabled while LP vault has zero supply
  [ACT] Finalize profitable checkpoint with protocol fees
  [ASSERT] LP fee portion falls back to treasury pool

Traces:
  [675205] InvariantSolvencyTest::testLpFeeWithNoLpSupplyRoutesToTreasury()
    ├─ [0] console::log("[TEST] testLpFeeWithNoLpSupplyRoutesToTreasury") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] LP fee share enabled while LP vault has zero supply") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce
    ├─ [32897] ERC20Mock::mint(0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, 100000000000000000000 [1e20])
    │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, value: 100000000000000000000 [1e20])
    │   └─ ← [Return]
    ├─ [0] VM::prank(0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce)
    │   └─ ← [Return]
    ├─ [26927] ERC20Mock::approve(CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], 100000000000000000000 [1e20])
    │   ├─ emit Approval(owner: 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, spender: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], value: 100000000000000000000 [1e20])
    │   └─ ← [Return] true
    ├─ [0] VM::prank(0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce)
    │   └─ ← [Return]
    ├─ [41393] CollateralVault::deposit(10000000000000000000 [1e19])
    │   ├─ [15155] ERC20Mock::transferFrom(0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], 10000000000000000000 [1e19])
    │   │   ├─ emit Transfer(from: 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, to: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], value: 10000000000000000000 [1e19])
    │   │   └─ ← [Return] true
    │   ├─ emit Deposited(user: 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, amount: 10000000000000000000 [1e19])
    │   └─ ← [Return]
    ├─ [0] VM::prank(ECRecover: [0x0000000000000000000000000000000000000001])
    │   └─ ← [Return]
    ├─ [8899] FeeManager::setLpFeeShareBps(3000)
    │   ├─ emit LpFeeShareBpsUpdated(previous: 2000, current: 3000)
    │   └─ ← [Return]
    ├─ [3240] ERC20Mock::balanceOf(TreasuryPool: [0x062C88B4ba954955746eDA6f475C26eeaC04614B]) [staticcall]
    │   └─ ← [Return] 0
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xb03b0746e6c9aa445fc64f8f25967ec5d74f9dc7a1f5d8d738064017da3b0091, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad
    ├─ [0] VM::sign("<pk>", 0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad) [staticcall]
    │   └─ ← [Return] 28, 0xd78352afb4f941a942fa4c5fc2ea4d8e16004942866aff897a451f3cd211594f, 0x6cfbe035fa84e96422c77a01e952510e06a6e86e18f5110ccba7fbf1f512ca52
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xb03b0746e6c9aa445fc64f8f25967ec5d74f9dc7a1f5d8d738064017da3b0091, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad
    ├─ [0] VM::sign("<pk>", 0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad) [staticcall]
    │   └─ ← [Return] 27, 0xe2a155a70e291ea6f5d806c9e17c2d83a322fe2a59b69fb18d815bdfa0a52486, 0x3216b6e4c8cb315f314346c6bf723b3ba5bc0fb65b91d9bad61569c757c14a00
    ├─ [0] console::log("[ACT] Finalize profitable checkpoint with protocol fees") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xb03b0746e6c9aa445fc64f8f25967ec5d74f9dc7a1f5d8d738064017da3b0091, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad
    ├─ [0] VM::sign("<pk>", 0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad) [staticcall]
    │   └─ ← [Return] 28, 0xc02f95ab4582cb6a775e5d2bfbdbe473a5b5aeac1d87744d57b5f327fe9ff362, 0x72f24f5ea2a1af8486ce9d18f04b43cac82c5d4c077c5e53f2a6e98d93afd34f
    ├─ [141433] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xb03b0746e6c9aa445fc64f8f25967ec5d74f9dc7a1f5d8d738064017da3b0091, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, outcomeIndex: 0, sharesDelta: 0, cashDelta: -1000 }), Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 0, cashDelta: 1000 })], 0xc02f95ab4582cb6a775e5d2bfbdbe473a5b5aeac1d87744d57b5f327fe9ff36272f24f5ea2a1af8486ce9d18f04b43cac82c5d4c077c5e53f2a6e98d93afd34f1c, [0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0xd78352afb4f941a942fa4c5fc2ea4d8e16004942866aff897a451f3cd211594f6cfbe035fa84e96422c77a01e952510e06a6e86e18f5110ccba7fbf1f512ca521c, 0xe2a155a70e291ea6f5d806c9e17c2d83a322fe2a59b69fb18d815bdfa0a524863216b6e4c8cb315f314346c6bf723b3ba5bc0fb65b91d9bad61569c757c14a001b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad, 28, 86928141717708636407898449791099035521202281123680655137449933290472097182562, 51991789517492225303796537580699994153015776073914538761961332704034532873039) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad, 28, 97479290091138096097511538035573944455932726352796391872114530044558349261135, 49294813706693748468974877469097764262791013160972999110543625380163923135058) [staticcall]
    │   │   └─ ← [Return] 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce
    │   ├─ [3000] PRECOMPILES::ecrecover(0x4e21e3db0f51809776ba05b92d782a919db7e1909da7c79aee4af757888764ad, 27, 102507757309489382022753581333753540538318938962855703042131980874022411117702, 22655775350437446894364469272349082430287736354422120951902994502027290167808) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xb03b0746e6c9aa445fc64f8f25967ec5d74f9dc7a1f5d8d738064017da3b0091)
    │   └─ ← [Return]
    ├─ [0] VM::warp(1861)
    │   └─ ← [Return]
    ├─ [302778] ChannelSettlement::finalizeCheckpoint(0, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, outcomeIndex: 0, sharesDelta: 0, cashDelta: -1000 }), Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 0, cashDelta: 1000 })])
    │   ├─ [12243] MarketRegistry::status(0) [staticcall]
    │   │   └─ ← [Return] 1
    │   ├─ [1798] MarketRegistry::getTradingClose(0) [staticcall]
    │   │   └─ ← [Return] 86401 [8.64e4]
    │   ├─ [14213] ExecutionLedger::applyDeltas(0, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [Delta({ user: 0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, outcomeIndex: 0, sharesDelta: 0, cashDelta: -1000 }), Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 0, cashDelta: 1000 })])
    │   │   ├─ emit DeltasApplied(marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, deltaCount: 2)
    │   │   └─ ← [Return]
    │   ├─ [1040] CollateralVault::token() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459]
    │   ├─ [6833] FeeManager::computeSplit(1000) [staticcall]
    │   │   └─ ← [Return] 6, 3, 1, 990
    │   ├─ [16801] CollateralVault::applyCashDeltas(0, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, [0xBa5359FaC9736E687C39D9613de3E8fa6C7af1ce, 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [-1000, 990])
    │   │   ├─ emit CashDeltasApplied(marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, userCount: 2)
    │   │   └─ ← [Return]
    │   ├─ [3416] MarketRegistry::liquidityVaultByMarketId(0) [staticcall]
    │   │   └─ ← [Return] LiquidityVault4626: [0x90A5b0DD8c4b06636A4BEf7BA82D9C58f44fAaAd]
    │   ├─ [3824] MarketRegistry::usesLpVaultByMarketId(0) [staticcall]
    │   │   └─ ← [Return] true
    │   ├─ [846] LiquidityVault4626::asset() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459]
    │   ├─ [31115] CollateralVault::transferToFeeCollector(LiquidityVault4626: [0x90A5b0DD8c4b06636A4BEf7BA82D9C58f44fAaAd], 10)
    │   │   ├─ [29201] ERC20Mock::transfer(LiquidityVault4626: [0x90A5b0DD8c4b06636A4BEf7BA82D9C58f44fAaAd], 10)
    │   │   │   ├─ emit Transfer(from: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], to: LiquidityVault4626: [0x90A5b0DD8c4b06636A4BEf7BA82D9C58f44fAaAd], value: 10)
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Return]
    │   ├─ [2862] FeePool::feeCollector() [staticcall]
    │   │   └─ ← [Return] ChannelSettlement: [0x2c1DE3b4Dbb4aDebEbB5dcECAe825bE2a9fc6eb6]
    │   ├─ [31115] CollateralVault::transferToFeeCollector(FeePool: [0x147B09A8C7d5E4A8253a3e01De4356D3c132010D], 6)
    │   │   ├─ [29201] ERC20Mock::transfer(FeePool: [0x147B09A8C7d5E4A8253a3e01De4356D3c132010D], 6)
    │   │   │   ├─ emit Transfer(from: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], to: FeePool: [0x147B09A8C7d5E4A8253a3e01De4356D3c132010D], value: 6)
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Return]
    │   ├─ [4122] FeePool::recordFeeCollected(ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459], 6, 0, 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b)
    │   │   ├─ emit FeeCollected(asset: ERC20Mock: [0x522B3294E6d06aA25Ad0f1B8891242E335D3B459], amount: 6, marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b)
    │   │   └─ ← [Return]
    │   ├─ [2744] LiquidityVault4626::totalSupply() [staticcall]
    │   │   └─ ← [Return] 0
    │   ├─ [2730] FeePool::treasuryPool() [staticcall]
    │   │   └─ ← [Return] TreasuryPool: [0x062C88B4ba954955746eDA6f475C26eeaC04614B]
    │   ├─ [730] FeePool::treasuryPool() [staticcall]
    │   │   └─ ← [Return] TreasuryPool: [0x062C88B4ba954955746eDA6f475C26eeaC04614B]
    │   ├─ [29115] CollateralVault::transferToFeeCollector(TreasuryPool: [0x062C88B4ba954955746eDA6f475C26eeaC04614B], 3)
    │   │   ├─ [27201] ERC20Mock::transfer(TreasuryPool: [0x062C88B4ba954955746eDA6f475C26eeaC04614B], 3)
    │   │   │   ├─ emit Transfer(from: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], to: TreasuryPool: [0x062C88B4ba954955746eDA6f475C26eeaC04614B], value: 3)
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Return]
    │   ├─ [1916] MarketRegistry::getCreator(0) [staticcall]
    │   │   └─ ← [Return] ECRecover: [0x0000000000000000000000000000000000000001]
    │   ├─ [31115] CollateralVault::transferToFeeCollector(ECRecover: [0x0000000000000000000000000000000000000001], 1)
    │   │   ├─ [29201] ERC20Mock::transfer(ECRecover: [0x0000000000000000000000000000000000000001], 1)
    │   │   │   ├─ emit Transfer(from: CollateralVault: [0x535B3D7A252fa034Ed71F0C53ec0C6F784cB64E1], to: ECRecover: [0x0000000000000000000000000000000000000001], value: 1)
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Return]
    │   ├─ emit CheckpointFinalized(marketId: 0, sessionId: 0x052d512126fae2f4410912aa194f97435d54663c2411876d7b56c5ff785d9b8b, nonce: 1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] LP fee portion falls back to treasury pool") [staticcall]
    │   └─ ← [Stop]
    ├─ [1240] ERC20Mock::balanceOf(TreasuryPool: [0x062C88B4ba954955746eDA6f475C26eeaC04614B]) [staticcall]
    │   └─ ← [Return] 3
    └─ ← [Return]

Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 6.26ms (3.45ms CPU time)

Ran 1 test for test/FuzzFeeSplit.t.sol:FuzzFeeSplitTest
[PASS] testFuzzComputeSplitSumCorrectness(int128) (runs: 10001, μ: 31336, ~: 31335)
Traces:
  [31335] FuzzFeeSplitTest::testFuzzComputeSplitSumCorrectness(55937 [5.593e4])
    ├─ [0] console::log("[TEST] testFuzzComputeSplitSumCorrectness") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Keep fuzzed pnlDelta positive and within configured bound") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::assume(true) [staticcall]
    │   └─ ← [Return]
    ├─ [0] VM::assume(true) [staticcall]
    │   └─ ← [Return]
    ├─ [0] console::log("[ACT] Compute protocol/lp/creator split") [staticcall]
    │   └─ ← [Stop]
    ├─ [8833] FeeManager::computeSplit(55937 [5.593e4]) [staticcall]
    │   └─ ← [Return] 335, 139, 83, 55378 [5.537e4]
    ├─ [0] console::log("[ASSERT] Total fees + net is equal to profit within tiny rounding dust") [staticcall]
    │   └─ ← [Stop]
    └─ ← [Return]

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 2.01s (2.01s CPU time)

Ran 1 test for test/FuzzCheckpoint.t.sol:FuzzCheckpointTest
[PASS] testFuzzCheckpointWithBoundedDeltas(uint256,uint256) (runs: 10000, μ: 236597, ~: 237156)
Traces:
  [302541] FuzzCheckpointTest::testFuzzCheckpointWithBoundedDeltas(129026450 [1.29e8], 26125968753623543428 [2.612e19])
    ├─ [0] console::log("[TEST] testFuzzCheckpointWithBoundedDeltas") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ARRANGE] Bound fuzzed shares/cash deltas to safe signed ranges") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("[ACT] Submit and finalize fuzzed checkpoint") [staticcall]
    │   └─ ← [Stop]
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xd6554eacf83dd8fc4aafb41269c8b3c2ead2efdb5a380782dea8972fadf90f7e, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xeee91ddba419d32070161c5d6a2dbb1c3354eabab03dec0e61e7ce7cd1b64bc1
    ├─ [0] VM::sign("<pk>", 0xeee91ddba419d32070161c5d6a2dbb1c3354eabab03dec0e61e7ce7cd1b64bc1) [staticcall]
    │   └─ ← [Return] 28, 0x63c39879b7ee108390113db8d8307bc301dbd3aec1d051e8cdc2db3a5a3685a4, 0x3c69aae938a41880ce17d802f91082b2ded6c8740254799cef86aa51d4723270
    ├─ [3607] ChannelSettlement::digestCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xd6554eacf83dd8fc4aafb41269c8b3c2ead2efdb5a380782dea8972fadf90f7e, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 })) [staticcall]
    │   └─ ← [Return] 0xeee91ddba419d32070161c5d6a2dbb1c3354eabab03dec0e61e7ce7cd1b64bc1
    ├─ [0] VM::sign("<pk>", 0xeee91ddba419d32070161c5d6a2dbb1c3354eabab03dec0e61e7ce7cd1b64bc1) [staticcall]
    │   └─ ← [Return] 27, 0x285cd4041844e9fa934c54b6e24fc6490774ebb1ecfbd77ce5729c68a63a6e67, 0x02dc8060767215234369af589a6b12041a605fe0f2208ada2411398c65327c96
    ├─ [129878] ChannelSettlement::submitCheckpoint(Checkpoint({ marketId: 0, sessionId: 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, nonce: 1, validAfter: 0, validBefore: 0, lastTradeAt: 0, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xd6554eacf83dd8fc4aafb41269c8b3c2ead2efdb5a380782dea8972fadf90f7e, riskHash: 0x0000000000000000000000000000000000000000000000000000000000000000 }), [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 61, cashDelta: -975 })], 0x63c39879b7ee108390113db8d8307bc301dbd3aec1d051e8cdc2db3a5a3685a43c69aae938a41880ce17d802f91082b2ded6c8740254799cef86aa51d47232701c, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [0x285cd4041844e9fa934c54b6e24fc6490774ebb1ecfbd77ce5729c68a63a6e6702dc8060767215234369af589a6b12041a605fe0f2208ada2411398c65327c961b])
    │   ├─ [3000] PRECOMPILES::ecrecover(0xeee91ddba419d32070161c5d6a2dbb1c3354eabab03dec0e61e7ce7cd1b64bc1, 28, 45124559534343499717499073609427367067589864199346314027991685406918926828964, 27325469441309234894273477247547263697989081607438887503218077447500262945392) [staticcall]
    │   │   └─ ← [Return] 0xe05fcC23807536bEe418f142D19fa0d21BB0cfF7
    │   ├─ [3000] PRECOMPILES::ecrecover(0xeee91ddba419d32070161c5d6a2dbb1c3354eabab03dec0e61e7ce7cd1b64bc1, 27, 18256527153911417728351444860809958230687171708887811536524997846487763938919, 1294218075578827831705036113775227259784508731623463119453718109113797475478) [staticcall]
    │   │   └─ ← [Return] 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c
    │   ├─ emit CheckpointSubmitted(marketId: 0, sessionId: 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, nonce: 1, stateHash: 0x69e39af32bd0cc2d5f8ad822a3afcd7fe8d7211e4ca7c42654cdbda7a9b74516, deltasHash: 0xd6554eacf83dd8fc4aafb41269c8b3c2ead2efdb5a380782dea8972fadf90f7e)
    │   └─ ← [Return]
    ├─ [0] VM::warp(1861)
    │   └─ ← [Return]
    ├─ [106188] ChannelSettlement::finalizeCheckpoint(0, 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 61, cashDelta: -975 })])
    │   ├─ [29793] ExecutionLedger::applyDeltas(0, 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, [Delta({ user: 0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, outcomeIndex: 0, sharesDelta: 61, cashDelta: -975 })])
    │   │   ├─ emit DeltasApplied(marketId: 0, sessionId: 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, deltaCount: 1)
    │   │   └─ ← [Return]
    │   ├─ [1040] CollateralVault::token() [staticcall]
    │   │   └─ ← [Return] ERC20Mock: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f]
    │   ├─ [14248] CollateralVault::applyCashDeltas(0, 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, [0x0376AAc07Ad725E01357B1725B5ceC61aE10473c], [-975])
    │   │   ├─ emit CashDeltasApplied(marketId: 0, sessionId: 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, userCount: 1)
    │   │   └─ ← [Return]
    │   ├─ emit CheckpointFinalized(marketId: 0, sessionId: 0x67abdbe72f46a4206cbec9ce2c59e996e1d2641dc7b5ed35a744512ac48e3a4c, nonce: 1)
    │   └─ ← [Return]
    ├─ [0] console::log("[ASSERT] Ledger position equals fuzzed shares delta") [staticcall]
    │   └─ ← [Stop]
    ├─ [1514] ExecutionLedger::positionOf(0x0376AAc07Ad725E01357B1725B5ceC61aE10473c, 0, 0) [staticcall]
    │   └─ ← [Return] 61
    └─ ← [Return]

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 13.31s (13.30s CPU time)
