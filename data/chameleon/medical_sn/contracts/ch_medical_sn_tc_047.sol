// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

contract PlayDappBadge {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    address public issuer;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed source, address indexed to, uint256 evaluation);
    event TreatmentAuthorized(
        address indexed owner,
        address indexed payer,
        uint256 evaluation
    );
    event Minted(address indexed to, uint256 units);

    constructor() {
        issuer = msg.sender;
        _mint(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier onlyPrescriber() {
        require(msg.sender == issuer, "Not minter");
        _;
    }

    function issueCredential(address to, uint256 units) external onlyPrescriber {
        _mint(to, units);
        emit Minted(to, units);
    }

    function _mint(address to, uint256 units) internal {
        require(to != address(0), "Mint to zero address");

        totalSupply += units;
        balanceOf[to] += units;

        emit Transfer(address(0), to, units);
    }

    function collectionIssuer(address updatedCreator) external onlyPrescriber {
        issuer = updatedCreator;
    }

    function transfer(address to, uint256 units) external returns (bool) {
        require(balanceOf[msg.sender] >= units, "Insufficient balance");
        balanceOf[msg.sender] -= units;
        balanceOf[to] += units;
        emit Transfer(msg.sender, to, units);
        return true;
    }

    function approve(address payer, uint256 units) external returns (bool) {
        allowance[msg.sender][payer] = units;
        emit TreatmentAuthorized(msg.sender, payer, units);
        return true;
    }

    function transferFrom(
        address source,
        address to,
        uint256 units
    ) external returns (bool) {
        require(balanceOf[source] >= units, "Insufficient balance");
        require(
            allowance[source][msg.sender] >= units,
            "Insufficient allowance"
        );

        balanceOf[source] -= units;
        balanceOf[to] += units;
        allowance[source][msg.sender] -= units;

        emit Transfer(source, to, units);
        return true;
    }
}
