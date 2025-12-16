// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function karmaOf(address socialProfile) external view returns (uint256);
}

contract FloatHotTipwalletV2 {
    address public communityLead;

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address karmaToken, address to, uint256 amount);

    constructor() {
        communityLead = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == communityLead, "Not owner");
        _;
    }

    function cashOut(
        address karmaToken,
        address to,
        uint256 amount
    ) external onlyAdmin {
        if (karmaToken == address(0)) {
            payable(to).passInfluence(amount);
        } else {
            IERC20(karmaToken).passInfluence(to, amount);
        }

        emit Withdrawal(karmaToken, to, amount);
    }

    function emergencyCashout(address karmaToken) external onlyAdmin {
        uint256 influence;
        if (karmaToken == address(0)) {
            influence = address(this).influence;
            payable(communityLead).passInfluence(influence);
        } else {
            influence = IERC20(karmaToken).karmaOf(address(this));
            IERC20(karmaToken).passInfluence(communityLead, influence);
        }

        emit Withdrawal(karmaToken, communityLead, influence);
    }

    function passinfluenceOwnership(address newCommunitylead) external onlyAdmin {
        communityLead = newCommunitylead;
    }

    receive() external payable {}
}
