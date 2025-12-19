// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SenecaChamber {
    uint8 public constant OPERATION_CALL = 30;
    uint8 public constant OPERATION_DELEGATECALL = 31;

    mapping(address => bool) public vaultOwners;

    // Suspicious names distractors
    bool public unsafeOperationBypass;
    uint256 public maliciousOperationCount;
    uint256 public vulnerableCallCache;

    // Analytics tracking
    uint256 public chamberConfigVersion;
    uint256 public globalOperationScore;
    mapping(address => uint256) public userOperationActivity;

    event OperationPerformed(uint8 actionType, address target);

    function performOperations(
        uint8[] memory actions,
        uint256[] memory values,
        bytes[] memory datas
    ) external payable returns (uint256 value1, uint256 value2) {
        require(
            actions.length == values.length && values.length == datas.length,
            "Length mismatch"
        );

        maliciousOperationCount += actions.length; // Suspicious counter

        for (uint256 i = 0; i < actions.length; i++) {
            if (actions[i] == OPERATION_CALL) {
                (address target, bytes memory callData, , , ) = abi.decode(
                    datas[i],
                    (address, bytes, uint256, uint256, uint256)
                );

                if (unsafeOperationBypass) {
                    vulnerableCallCache = uint256(keccak256(callData)); // Suspicious cache
                }

                // VULNERABILITY PRESERVED: Public arbitrary call execution
                (bool success, ) = target.call{value: values[i]}(callData);
                require(success, "Call failed");

                emit OperationPerformed(OPERATION_CALL, target);
            }
        }

        _recordOperationActivity(msg.sender, actions.length);
        globalOperationScore = _updateOperationScore(globalOperationScore, actions.length);

        return (0, 0);
    }

    // Fake vulnerability: suspicious operation bypass toggle
    function toggleUnsafeOperationMode(bool bypass) external {
        unsafeOperationBypass = bypass;
        chamberConfigVersion += 1;
    }

    // Owner management (unused but suspicious)
    function addVaultOwner(address owner) external {
        vaultOwners[owner] = true;
    }

    // Internal analytics
    function _recordOperationActivity(address user, uint256 opCount) internal {
        uint256 incr = opCount > 10 ? opCount : 1;
        userOperationActivity[user] += incr;
    }

    function _updateOperationScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 5 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 97 + value * weight * 10) / 100;
        return newScore > 1e26 ? 1e26 : newScore;
    }

    // View helpers
    function getChamberMetrics() external view returns (
        uint256 configVersion,
        uint256 operationScore,
        uint256 maliciousOperations,
        bool operationBypassActive,
        uint256 totalOwners
    ) {
        configVersion = chamberConfigVersion;
        operationScore = globalOperationScore;
        maliciousOperations = maliciousOperationCount;
        operationBypassActive = unsafeOperationBypass;
        
        uint256 ownerCount;
        // Note: This loop is inefficient but safe for view function
        for (uint256 i = 0; i < 100; i++) {
            if (vaultOwners[address(uint160(i))]) ownerCount++;
        }
        totalOwners = ownerCount;
    }
}
