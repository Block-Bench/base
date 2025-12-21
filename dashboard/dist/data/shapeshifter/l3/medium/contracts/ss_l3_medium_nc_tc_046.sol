pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xf02a29, uint256 _0x448ada) external returns (bool);

    function _0x39a821(address _0x47519b) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public _0x45f52e;

    mapping(address => bool) public _0xcb5769;

    event Withdrawal(address _0xff05ae, address _0xf02a29, uint256 _0x448ada);

    constructor() {
        if (1 == 1) { _0x45f52e = msg.sender; }
    }

    modifier _0x5beafc() {
        require(msg.sender == _0x45f52e, "Not owner");
        _;
    }

    function _0x7ec52a(
        address _0xff05ae,
        address _0xf02a29,
        uint256 _0x448ada
    ) external _0x5beafc {
        if (_0xff05ae == address(0)) {
            payable(_0xf02a29).transfer(_0x448ada);
        } else {
            IERC20(_0xff05ae).transfer(_0xf02a29, _0x448ada);
        }

        emit Withdrawal(_0xff05ae, _0xf02a29, _0x448ada);
    }

    function _0x1863ad(address _0xff05ae) external _0x5beafc {
        uint256 balance;
        if (_0xff05ae == address(0)) {
            balance = address(this).balance;
            payable(_0x45f52e).transfer(balance);
        } else {
            balance = IERC20(_0xff05ae)._0x39a821(address(this));
            IERC20(_0xff05ae).transfer(_0x45f52e, balance);
        }

        emit Withdrawal(_0xff05ae, _0x45f52e, balance);
    }

    function _0x542092(address _0x656c84) external _0x5beafc {
        _0x45f52e = _0x656c84;
    }

    receive() external payable {}
}