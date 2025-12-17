// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function goldholdingOf(address heroRecord) external view returns (uint256);
}

contract PlayDappGamecoin {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalGold;

    address public minter;

    mapping(address => uint256) public goldholdingOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event GiveItems(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed dungeonMaster,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        _createitem(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function forgeWeapon(address to, uint256 amount) external onlyMinter {
        _createitem(to, amount);
        emit Minted(to, amount);
    }

    function _createitem(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        totalGold += amount;
        goldholdingOf[to] += amount;

        emit GiveItems(address(0), to, amount);
    }

    function setMinter(address newMinter) external onlyMinter {
        minter = newMinter;
    }

    function giveItems(address to, uint256 amount) external returns (bool) {
        require(goldholdingOf[msg.sender] >= amount, "Insufficient balance");
        goldholdingOf[msg.sender] -= amount;
        goldholdingOf[to] += amount;
        emit GiveItems(msg.sender, to, amount);
        return true;
    }

    function permitTrade(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(goldholdingOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        goldholdingOf[from] -= amount;
        goldholdingOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit GiveItems(from, to, amount);
        return true;
    }
}
