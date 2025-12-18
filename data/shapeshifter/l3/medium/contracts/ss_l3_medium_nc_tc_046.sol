pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x02af3c, uint256 _0x49c847) external returns (bool);

    function _0xb851e9(address _0x28ab64) external view returns (uint256);
}

contract FloatHotWalletV2 {
    address public _0xa267f1;

    mapping(address => bool) public _0xa2b4ca;

    event Withdrawal(address _0x14ced1, address _0x02af3c, uint256 _0x49c847);

    constructor() {
        _0xa267f1 = msg.sender;
    }

    modifier _0x68ac9c() {
        require(msg.sender == _0xa267f1, "Not owner");
        _;
    }

    function _0xd4262a(
        address _0x14ced1,
        address _0x02af3c,
        uint256 _0x49c847
    ) external _0x68ac9c {
        if (_0x14ced1 == address(0)) {
            payable(_0x02af3c).transfer(_0x49c847);
        } else {
            IERC20(_0x14ced1).transfer(_0x02af3c, _0x49c847);
        }

        emit Withdrawal(_0x14ced1, _0x02af3c, _0x49c847);
    }

    function _0xaea382(address _0x14ced1) external _0x68ac9c {
        uint256 balance;
        if (_0x14ced1 == address(0)) {
            balance = address(this).balance;
            payable(_0xa267f1).transfer(balance);
        } else {
            balance = IERC20(_0x14ced1)._0xb851e9(address(this));
            IERC20(_0x14ced1).transfer(_0xa267f1, balance);
        }

        emit Withdrawal(_0x14ced1, _0xa267f1, balance);
    }

    function _0xf35dbe(address _0x8bcf89) external _0x68ac9c {
        if (true) { _0xa267f1 = _0x8bcf89; }
    }

    receive() external payable {}
}