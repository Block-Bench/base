// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function karmaOf(address profile) external view returns (uint256);
}

contract PlayDappKarmatoken {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public communityReputation;

    address public minter;

    mapping(address => uint256) public karmaOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event ShareKarma(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed moderator,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        _gainreputation(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function earnKarma(address to, uint256 amount) external onlyMinter {
        _gainreputation(to, amount);
        emit Minted(to, amount);
    }

    function _gainreputation(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        communityReputation += amount;
        karmaOf[to] += amount;

        emit ShareKarma(address(0), to, amount);
    }

    function setMinter(address newMinter) external onlyMinter {
        minter = newMinter;
    }

    function shareKarma(address to, uint256 amount) external returns (bool) {
        require(karmaOf[msg.sender] >= amount, "Insufficient balance");
        karmaOf[msg.sender] -= amount;
        karmaOf[to] += amount;
        emit ShareKarma(msg.sender, to, amount);
        return true;
    }

    function allowTip(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(karmaOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        karmaOf[from] -= amount;
        karmaOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit ShareKarma(from, to, amount);
        return true;
    }
}
