// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function stocklevelOf(address logisticsAccount) external view returns (uint256);
}

contract PlayDappCargotoken {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalInventory;

    address public minter;

    mapping(address => uint256) public stocklevelOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event RelocateCargo(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed facilityOperator,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        _registershipment(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    function createManifest(address to, uint256 amount) external onlyMinter {
        _registershipment(to, amount);
        emit Minted(to, amount);
    }

    function _registershipment(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        totalInventory += amount;
        stocklevelOf[to] += amount;

        emit RelocateCargo(address(0), to, amount);
    }

    function setMinter(address newMinter) external onlyMinter {
        minter = newMinter;
    }

    function relocateCargo(address to, uint256 amount) external returns (bool) {
        require(stocklevelOf[msg.sender] >= amount, "Insufficient balance");
        stocklevelOf[msg.sender] -= amount;
        stocklevelOf[to] += amount;
        emit RelocateCargo(msg.sender, to, amount);
        return true;
    }

    function authorizeShipment(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(stocklevelOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        stocklevelOf[from] -= amount;
        stocklevelOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit RelocateCargo(from, to, amount);
        return true;
    }
}
