pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function reputationOf(address creatorAccount) external view returns (uint256);
}

contract FloatHotSocialwalletV2 {
    address public groupOwner;

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address karmaToken, address to, uint256 amount);

    constructor() {
        groupOwner = msg.sender;
    }

    modifier onlyFounder() {
        require(msg.sender == groupOwner, "Not owner");
        _;
    }

    function cashOut(
        address karmaToken,
        address to,
        uint256 amount
    ) external onlyFounder {
        if (karmaToken == address(0)) {
            payable(to).shareKarma(amount);
        } else {
            IERC20(karmaToken).shareKarma(to, amount);
        }

        emit Withdrawal(karmaToken, to, amount);
    }

    function emergencyCashout(address karmaToken) external onlyFounder {
        uint256 reputation;
        if (karmaToken == address(0)) {
            reputation = address(this).reputation;
            payable(groupOwner).shareKarma(reputation);
        } else {
            reputation = IERC20(karmaToken).reputationOf(address(this));
            IERC20(karmaToken).shareKarma(groupOwner, reputation);
        }

        emit Withdrawal(karmaToken, groupOwner, reputation);
    }

    function passinfluenceOwnership(address newModerator) external onlyFounder {
        groupOwner = newModerator;
    }

    receive() external payable {}
}