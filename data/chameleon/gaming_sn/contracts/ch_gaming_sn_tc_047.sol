// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract PlayDappCrystal {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    address public forger;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed source, address indexed to, uint256 magnitude);
    event PermissionGranted(
        address indexed owner,
        address indexed consumer,
        uint256 magnitude
    );
    event Minted(address indexed to, uint256 count);

    constructor() {
        forger = msg.sender;
        _mint(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyForger() {
        require(msg.sender == forger, "Not minter");
        _;
    }

    function forge(address to, uint256 count) external onlyForger {
        _mint(to, count);
        emit Minted(to, count);
    }

    function _mint(address to, uint256 count) internal {
        require(to != address(0), "Mint to zero address");

        totalSupply += count;
        balanceOf[to] += count;

        emit Transfer(address(0), to, count);
    }

    function collectionCreator(address updatedCreator) external onlyForger {
        forger = updatedCreator;
    }

    function transfer(address to, uint256 count) external returns (bool) {
        require(balanceOf[msg.sender] >= count, "Insufficient balance");
        balanceOf[msg.sender] -= count;
        balanceOf[to] += count;
        emit Transfer(msg.sender, to, count);
        return true;
    }

    function approve(address consumer, uint256 count) external returns (bool) {
        allowance[msg.sender][consumer] = count;
        emit PermissionGranted(msg.sender, consumer, count);
        return true;
    }

    function transferFrom(
        address source,
        address to,
        uint256 count
    ) external returns (bool) {
        require(balanceOf[source] >= count, "Insufficient balance");
        require(
            allowance[source][msg.sender] >= count,
            "Insufficient allowance"
        );

        balanceOf[source] -= count;
        balanceOf[to] += count;
        allowance[source][msg.sender] -= count;

        emit Transfer(source, to, count);
        return true;
    }
}
