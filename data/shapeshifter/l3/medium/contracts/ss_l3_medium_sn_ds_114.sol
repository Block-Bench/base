// https://etherscan.io/address/0xf91546835f756da0c10cfa0cda95b15577b84aa7#code

pragma solidity ^0.4.23;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
contract Token {
    /// total amount of tokens
    uint256 public _0x19498a;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x160aff(address _0x667af1) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0xfb1fbd, uint256 _0x76267c) public returns (bool _0x201dff);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function _0x46dddc(address _0x6489fe, address _0xfb1fbd, uint256 _0x76267c) public returns (bool _0x201dff);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0x010c65(address _0x2da78a, uint256 _0x76267c) public returns (bool _0x201dff);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function _0x0ff64a(address _0x667af1, address _0x2da78a) public constant returns (uint256 _0xc757e9);

    event Transfer(address indexed _0x6489fe, address indexed _0xfb1fbd, uint256 _0x76267c);
    event Approval(address indexed _0x667af1, address indexed _0x2da78a, uint256 _0x76267c);
}

library ECTools {

    // @dev Recovers the address which has signed a message
    // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
    function _0x8e3fe7(bytes32 _0xf2c0e0, string _0xa856dd) public pure returns (address) {
        require(_0xf2c0e0 != 0x00);

        // need this for test RPC
        bytes memory _0xd4ca4d = "\x19Ethereum Signed Message:\n32";
        bytes32 _0x866396 = _0xb2df79(abi._0x9a8676(_0xd4ca4d, _0xf2c0e0));

        if (bytes(_0xa856dd).length != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = _0x800c21(_0xd1ce23(_0xa856dd, 2, 132));
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v < 27 || v > 28) {
            return 0x0;
        }
        return _0x78b618(_0x866396, v, r, s);
    }

    // @dev Verifies if the message is signed by an address
    function _0x54da17(bytes32 _0xf2c0e0, string _0xa856dd, address _0x5273d9) public pure returns (bool) {
        require(_0x5273d9 != 0x0);

        return _0x5273d9 == _0x8e3fe7(_0xf2c0e0, _0xa856dd);
    }

    // @dev Converts an hexstring to bytes
    function _0x800c21(string _0x49c651) public pure returns (bytes) {
        uint _0xd8b81d = bytes(_0x49c651).length;
        require(_0xd8b81d % 2 == 0);

        bytes memory _0xd26905 = bytes(new string(_0xd8b81d / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < _0xd8b81d; i += 2) {
            s = _0xd1ce23(_0x49c651, i, i + 1);
            r = _0xd1ce23(_0x49c651, i + 1, i + 2);
            uint p = _0xb922a8(s) * 16 + _0xb922a8(r);
            _0xd26905[k++] = _0xf17e3b(p)[31];
        }
        return _0xd26905;
    }

    // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
    function _0xb922a8(string _0x04dccd) public pure returns (uint) {
        bytes memory _0xcd3d7f = bytes(_0x04dccd);
        // bool decimals = false;
        if ((_0xcd3d7f[0] >= 48) && (_0xcd3d7f[0] <= 57)) {
            return uint(_0xcd3d7f[0]) - 48;
        } else if ((_0xcd3d7f[0] >= 65) && (_0xcd3d7f[0] <= 70)) {
            return uint(_0xcd3d7f[0]) - 55;
        } else if ((_0xcd3d7f[0] >= 97) && (_0xcd3d7f[0] <= 102)) {
            return uint(_0xcd3d7f[0]) - 87;
        } else {
            revert();
        }
    }

    // @dev Converts a uint to a bytes32
    // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
    function _0xf17e3b(uint _0x153e34) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), _0x153e34)}
    }

    // @dev Hashes the signed message
    // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
    function _0xf0c1b9(string _0xb54040) public pure returns (bytes32) {
        uint _0xd8b81d = bytes(_0xb54040).length;
        require(_0xd8b81d > 0);
        bytes memory _0xd4ca4d = "\x19Ethereum Signed Message:\n";
        return _0xb2df79(abi._0x9a8676(_0xd4ca4d, _0x39e7d6(_0xd8b81d), _0xb54040));
    }

    // @dev Converts a uint in a string
    function _0x39e7d6(uint _0x153e34) public pure returns (string _0xf7adec) {
        uint _0xd8b81d = 0;
        uint m = _0x153e34 + 0;
        while (m != 0) {
            _0xd8b81d++;
            m /= 10;
        }
        bytes memory b = new bytes(_0xd8b81d);
        uint i = _0xd8b81d - 1;
        while (_0x153e34 != 0) {
            uint _0xf1c42f = _0x153e34 % 10;
            _0x153e34 = _0x153e34 / 10;
            b[i--] = byte(48 + _0xf1c42f);
        }
        _0xf7adec = string(b);
    }

    // @dev extract a substring
    // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
    function _0xd1ce23(string _0xf21925, uint _0x4c9e98, uint _0x0884ec) public pure returns (string) {
        bytes memory _0x8791be = bytes(_0xf21925);
        require(_0x4c9e98 <= _0x0884ec);
        require(_0x4c9e98 >= 0);
        require(_0x0884ec <= _0x8791be.length);

        bytes memory _0xc2cae0 = new bytes(_0x0884ec - _0x4c9e98);
        for (uint i = _0x4c9e98; i < _0x0884ec; i++) {
            _0xc2cae0[i - _0x4c9e98] = _0x8791be[i];
        }
        return string(_0xc2cae0);
    }
}
contract StandardToken is Token {

    function transfer(address _0xfb1fbd, uint256 _0x76267c) public returns (bool _0x201dff) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0xf148c1[msg.sender] >= _0x76267c);
        _0xf148c1[msg.sender] -= _0x76267c;
        _0xf148c1[_0xfb1fbd] += _0x76267c;
        emit Transfer(msg.sender, _0xfb1fbd, _0x76267c);
        return true;
    }

    function _0x46dddc(address _0x6489fe, address _0xfb1fbd, uint256 _0x76267c) public returns (bool _0x201dff) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0xf148c1[_0x6489fe] >= _0x76267c && _0xd810dc[_0x6489fe][msg.sender] >= _0x76267c);
        _0xf148c1[_0xfb1fbd] += _0x76267c;
        _0xf148c1[_0x6489fe] -= _0x76267c;
        _0xd810dc[_0x6489fe][msg.sender] -= _0x76267c;
        emit Transfer(_0x6489fe, _0xfb1fbd, _0x76267c);
        return true;
    }

    function _0x160aff(address _0x667af1) public constant returns (uint256 balance) {
        return _0xf148c1[_0x667af1];
    }

    function _0x010c65(address _0x2da78a, uint256 _0x76267c) public returns (bool _0x201dff) {
        _0xd810dc[msg.sender][_0x2da78a] = _0x76267c;
        emit Approval(msg.sender, _0x2da78a, _0x76267c);
        return true;
    }

    function _0x0ff64a(address _0x667af1, address _0x2da78a) public constant returns (uint256 _0xc757e9) {
      return _0xd810dc[_0x667af1][_0x2da78a];
    }

    mapping (address => uint256) _0xf148c1;
    mapping (address => mapping (address => uint256)) _0xd810dc;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */

    string public _0xe6b820;                   //fancy name: eg Simon Bucks
    uint8 public _0x1faf73;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public _0x7c1776;                 //An identifier: eg SBX
    string public _0xe90d6a = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    constructor(
        uint256 _0xe8c0a3,
        string _0x7426b2,
        uint8 _0x47b371,
        string _0x577442
        ) public {
        _0xf148c1[msg.sender] = _0xe8c0a3;               // Give the creator all initial tokens
        _0x19498a = _0xe8c0a3;                        // Update total supply
        _0xe6b820 = _0x7426b2;                                   // Set the name for display purposes
        _0x1faf73 = _0x47b371;                            // Amount of decimals for display purposes
        _0x7c1776 = _0x577442;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function _0xc3c60a(address _0x2da78a, uint256 _0x76267c, bytes _0xd901db) public returns (bool _0x201dff) {
        _0xd810dc[msg.sender][_0x2da78a] = _0x76267c;
        emit Approval(msg.sender, _0x2da78a, _0x76267c);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_0x2da78a.call(bytes4(bytes32(_0xb2df79("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x76267c, this, _0xd901db));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant VERSION = "0.0.1";

    uint256 public _0x3a8ee9 = 0;

    event DidLCOpen (
        bytes32 indexed _0xd35e8d,
        address indexed _0x1b04b5,
        address indexed _0xbf5fdf,
        uint256 _0xe06e29,
        address _0xc646b7,
        uint256 _0xa33970,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed _0xd35e8d,
        uint256 _0xa42391,
        uint256 _0x41c10c
    );

    event DidLCDeposit (
        bytes32 indexed _0xd35e8d,
        address indexed _0xcfcbcc,
        uint256 _0x68628a,
        bool _0xd29b0e
    );

    event DidLCUpdateState (
        bytes32 indexed _0xd35e8d,
        uint256 _0x9c7bcc,
        uint256 _0x5e690c,
        uint256 _0xe06e29,
        uint256 _0xa33970,
        uint256 _0xa42391,
        uint256 _0x41c10c,
        bytes32 _0x34c4b4,
        uint256 _0xbfdb0a
    );

    event DidLCClose (
        bytes32 indexed _0xd35e8d,
        uint256 _0x9c7bcc,
        uint256 _0xe06e29,
        uint256 _0xa33970,
        uint256 _0xa42391,
        uint256 _0x41c10c
    );

    event DidVCInit (
        bytes32 indexed _0x67bc72,
        bytes32 indexed _0x03dc2d,
        bytes _0x105ee2,
        uint256 _0x9c7bcc,
        address _0x1b04b5,
        address _0x16510a,
        uint256 _0x003c12,
        uint256 _0x223db2
    );

    event DidVCSettle (
        bytes32 indexed _0x67bc72,
        bytes32 indexed _0x03dc2d,
        uint256 _0xd23a28,
        uint256 _0x0b3f7e,
        uint256 _0xe6cb3a,
        address _0x352239,
        uint256 _0x786364
    );

    event DidVCClose(
        bytes32 indexed _0x67bc72,
        bytes32 indexed _0x03dc2d,
        uint256 _0x003c12,
        uint256 _0x223db2
    );

    struct Channel {
        //TODO: figure out if it's better just to split arrays by balances/deposits instead of eth/erc20
        address[2] _0xd78819; // 0: partyA 1: partyI
        uint256[4] _0x5b28f8; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
        uint256[4] _0x444b7a; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
        uint256[2] _0xd76205; // 0: eth 1: tokens
        uint256 _0x9c7bcc;
        uint256 _0x9ae645;
        bytes32 VCrootHash;
        uint256 LCopenTimeout;
        uint256 _0xbfdb0a; // when update LC times out
        bool _0x858abd; // true when both parties have joined
        bool _0x4fa389;
        uint256 _0x4acd9d;
        HumanStandardToken _0xc646b7;
    }

    // virtual-channel state
    struct VirtualChannel {
        bool _0x5cf332;
        bool _0xfadcdb;
        uint256 _0x9c7bcc;
        address _0x352239; // Initiator of challenge
        uint256 _0x786364; // when update VC times out
        // channel state
        address _0x1b04b5; // VC participant A
        address _0x16510a; // VC participant B
        address _0xbf5fdf; // LC hub
        uint256[2] _0x5b28f8;
        uint256[2] _0x444b7a;
        uint256[2] _0x7a81e2;
        HumanStandardToken _0xc646b7;
    }

    mapping(bytes32 => VirtualChannel) public _0xc6fbd7;
    mapping(bytes32 => Channel) public Channels;

    function _0xa518bf(
        bytes32 _0xd5eca6,
        address _0xf62d96,
        uint256 _0x461630,
        address _0xc08dd5,
        uint256[2] _0xd2ceb2 // [eth, token]
    )
        public
        payable
    {
        require(Channels[_0xd5eca6]._0xd78819[0] == address(0), "Channel has already been created.");
        require(_0xf62d96 != 0x0, "No partyI address provided to LC creation");
        require(_0xd2ceb2[0] >= 0 && _0xd2ceb2[1] >= 0, "Balances cannot be negative");
        // Set initial ledger channel state
        // Alice must execute this and we assume the initial state
        // to be signed from this requirement
        // Alternative is to check a sig as in joinChannel
        Channels[_0xd5eca6]._0xd78819[0] = msg.sender;
        Channels[_0xd5eca6]._0xd78819[1] = _0xf62d96;

        if(_0xd2ceb2[0] != 0) {
            require(msg.value == _0xd2ceb2[0], "Eth balance does not match sent value");
            Channels[_0xd5eca6]._0x5b28f8[0] = msg.value;
        }
        if(_0xd2ceb2[1] != 0) {
            Channels[_0xd5eca6]._0xc646b7 = HumanStandardToken(_0xc08dd5);
            require(Channels[_0xd5eca6]._0xc646b7._0x46dddc(msg.sender, this, _0xd2ceb2[1]),"CreateChannel: token transfer failure");
            Channels[_0xd5eca6]._0x444b7a[0] = _0xd2ceb2[1];
        }

        Channels[_0xd5eca6]._0x9c7bcc = 0;
        Channels[_0xd5eca6]._0x9ae645 = _0x461630;
        // is close flag, lc state sequence, number open vc, vc root hash, partyA...
        //Channels[_lcID].stateHash = keccak256(uint256(0), uint256(0), uint256(0), bytes32(0x0), bytes32(msg.sender), bytes32(_partyI), balanceA, balanceI);
        Channels[_0xd5eca6].LCopenTimeout = _0x4ec2c9 + _0x461630;
        Channels[_0xd5eca6]._0xd76205 = _0xd2ceb2;

        emit DidLCOpen(_0xd5eca6, msg.sender, _0xf62d96, _0xd2ceb2[0], _0xc08dd5, _0xd2ceb2[1], Channels[_0xd5eca6].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _0xd5eca6) public {
        require(msg.sender == Channels[_0xd5eca6]._0xd78819[0] && Channels[_0xd5eca6]._0x858abd == false);
        require(_0x4ec2c9 > Channels[_0xd5eca6].LCopenTimeout);

        if(Channels[_0xd5eca6]._0xd76205[0] != 0) {
            Channels[_0xd5eca6]._0xd78819[0].transfer(Channels[_0xd5eca6]._0x5b28f8[0]);
        }
        if(Channels[_0xd5eca6]._0xd76205[1] != 0) {
            require(Channels[_0xd5eca6]._0xc646b7.transfer(Channels[_0xd5eca6]._0xd78819[0], Channels[_0xd5eca6]._0x444b7a[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_0xd5eca6, 0, Channels[_0xd5eca6]._0x5b28f8[0], Channels[_0xd5eca6]._0x444b7a[0], 0, 0);

        // only safe to delete since no action was taken on this channel
        delete Channels[_0xd5eca6];
    }

    function _0x2f0d03(bytes32 _0xd5eca6, uint256[2] _0xd2ceb2) public payable {
        // require the channel is not open yet
        require(Channels[_0xd5eca6]._0x858abd == false);
        require(msg.sender == Channels[_0xd5eca6]._0xd78819[1]);

        if(_0xd2ceb2[0] != 0) {
            require(msg.value == _0xd2ceb2[0], "state balance does not match sent value");
            Channels[_0xd5eca6]._0x5b28f8[1] = msg.value;
        }
        if(_0xd2ceb2[1] != 0) {
            require(Channels[_0xd5eca6]._0xc646b7._0x46dddc(msg.sender, this, _0xd2ceb2[1]),"joinChannel: token transfer failure");
            Channels[_0xd5eca6]._0x444b7a[1] = _0xd2ceb2[1];
        }

        Channels[_0xd5eca6]._0xd76205[0]+=_0xd2ceb2[0];
        Channels[_0xd5eca6]._0xd76205[1]+=_0xd2ceb2[1];
        // no longer allow joining functions to be called
        Channels[_0xd5eca6]._0x858abd = true;
        _0x3a8ee9++;

        emit DidLCJoin(_0xd5eca6, _0xd2ceb2[0], _0xd2ceb2[1]);
    }

    // additive updates of monetary state
    function _0x68628a(bytes32 _0xd5eca6, address _0xcfcbcc, uint256 _0xaaefda, bool _0xd29b0e) public payable {
        require(Channels[_0xd5eca6]._0x858abd == true, "Tried adding funds to a closed channel");
        require(_0xcfcbcc == Channels[_0xd5eca6]._0xd78819[0] || _0xcfcbcc == Channels[_0xd5eca6]._0xd78819[1]);

        //if(Channels[_lcID].token)

        if (Channels[_0xd5eca6]._0xd78819[0] == _0xcfcbcc) {
            if(_0xd29b0e) {
                require(Channels[_0xd5eca6]._0xc646b7._0x46dddc(msg.sender, this, _0xaaefda),"deposit: token transfer failure");
                Channels[_0xd5eca6]._0x444b7a[2] += _0xaaefda;
            } else {
                require(msg.value == _0xaaefda, "state balance does not match sent value");
                Channels[_0xd5eca6]._0x5b28f8[2] += msg.value;
            }
        }

        if (Channels[_0xd5eca6]._0xd78819[1] == _0xcfcbcc) {
            if(_0xd29b0e) {
                require(Channels[_0xd5eca6]._0xc646b7._0x46dddc(msg.sender, this, _0xaaefda),"deposit: token transfer failure");
                Channels[_0xd5eca6]._0x444b7a[3] += _0xaaefda;
            } else {
                require(msg.value == _0xaaefda, "state balance does not match sent value");
                Channels[_0xd5eca6]._0x5b28f8[3] += msg.value;
            }
        }

        emit DidLCDeposit(_0xd5eca6, _0xcfcbcc, _0xaaefda, _0xd29b0e);
    }

    // TODO: Check there are no open virtual channels, the client should have cought this before signing a close LC state update
    function _0x9fc16b(
        bytes32 _0xd5eca6,
        uint256 _0x9a238a,
        uint256[4] _0xd2ceb2, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
        string _0xc7e852,
        string _0xce92a2
    )
        public
    {
        // assume num open vc is 0 and root hash is 0x0
        //require(Channels[_lcID].sequence < _sequence);
        require(Channels[_0xd5eca6]._0x858abd == true);
        uint256 _0xe9ff68 = Channels[_0xd5eca6]._0xd76205[0] + Channels[_0xd5eca6]._0x5b28f8[2] + Channels[_0xd5eca6]._0x5b28f8[3];
        uint256 _0xeac582 = Channels[_0xd5eca6]._0xd76205[1] + Channels[_0xd5eca6]._0x444b7a[2] + Channels[_0xd5eca6]._0x444b7a[3];
        require(_0xe9ff68 == _0xd2ceb2[0] + _0xd2ceb2[1]);
        require(_0xeac582 == _0xd2ceb2[2] + _0xd2ceb2[3]);

        bytes32 _0x2fc003 = _0xb2df79(
            abi._0x9a8676(
                _0xd5eca6,
                true,
                _0x9a238a,
                uint256(0),
                bytes32(0x0),
                Channels[_0xd5eca6]._0xd78819[0],
                Channels[_0xd5eca6]._0xd78819[1],
                _0xd2ceb2[0],
                _0xd2ceb2[1],
                _0xd2ceb2[2],
                _0xd2ceb2[3]
            )
        );

        require(Channels[_0xd5eca6]._0xd78819[0] == ECTools._0x8e3fe7(_0x2fc003, _0xc7e852));
        require(Channels[_0xd5eca6]._0xd78819[1] == ECTools._0x8e3fe7(_0x2fc003, _0xce92a2));

        Channels[_0xd5eca6]._0x858abd = false;

        if(_0xd2ceb2[0] != 0 || _0xd2ceb2[1] != 0) {
            Channels[_0xd5eca6]._0xd78819[0].transfer(_0xd2ceb2[0]);
            Channels[_0xd5eca6]._0xd78819[1].transfer(_0xd2ceb2[1]);
        }

        if(_0xd2ceb2[2] != 0 || _0xd2ceb2[3] != 0) {
            require(Channels[_0xd5eca6]._0xc646b7.transfer(Channels[_0xd5eca6]._0xd78819[0], _0xd2ceb2[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_0xd5eca6]._0xc646b7.transfer(Channels[_0xd5eca6]._0xd78819[1], _0xd2ceb2[3]),"happyCloseChannel: token transfer failure");
        }

        _0x3a8ee9--;

        emit DidLCClose(_0xd5eca6, _0x9a238a, _0xd2ceb2[0], _0xd2ceb2[1], _0xd2ceb2[2], _0xd2ceb2[3]);
    }

    // Byzantine functions

    function _0x78f9d1(
        bytes32 _0xd5eca6,
        uint256[6] _0x2f93e4, // [sequence, numOpenVc, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI]
        bytes32 _0x16463a,
        string _0xc7e852,
        string _0xce92a2
    )
        public
    {
        Channel storage _0x0c9275 = Channels[_0xd5eca6];
        require(_0x0c9275._0x858abd);
        require(_0x0c9275._0x9c7bcc < _0x2f93e4[0]); // do same as vc sequence check
        require(_0x0c9275._0x5b28f8[0] + _0x0c9275._0x5b28f8[1] >= _0x2f93e4[2] + _0x2f93e4[3]);
        require(_0x0c9275._0x444b7a[0] + _0x0c9275._0x444b7a[1] >= _0x2f93e4[4] + _0x2f93e4[5]);

        if(_0x0c9275._0x4fa389 == true) {
            require(_0x0c9275._0xbfdb0a > _0x4ec2c9);
        }

        bytes32 _0x2fc003 = _0xb2df79(
            abi._0x9a8676(
                _0xd5eca6,
                false,
                _0x2f93e4[0],
                _0x2f93e4[1],
                _0x16463a,
                _0x0c9275._0xd78819[0],
                _0x0c9275._0xd78819[1],
                _0x2f93e4[2],
                _0x2f93e4[3],
                _0x2f93e4[4],
                _0x2f93e4[5]
            )
        );

        require(_0x0c9275._0xd78819[0] == ECTools._0x8e3fe7(_0x2fc003, _0xc7e852));
        require(_0x0c9275._0xd78819[1] == ECTools._0x8e3fe7(_0x2fc003, _0xce92a2));

        // update LC state
        _0x0c9275._0x9c7bcc = _0x2f93e4[0];
        _0x0c9275._0x4acd9d = _0x2f93e4[1];
        _0x0c9275._0x5b28f8[0] = _0x2f93e4[2];
        _0x0c9275._0x5b28f8[1] = _0x2f93e4[3];
        _0x0c9275._0x444b7a[0] = _0x2f93e4[4];
        _0x0c9275._0x444b7a[1] = _0x2f93e4[5];
        _0x0c9275.VCrootHash = _0x16463a;
        _0x0c9275._0x4fa389 = true;
        _0x0c9275._0xbfdb0a = _0x4ec2c9 + _0x0c9275._0x9ae645;

        // make settlement flag

        emit DidLCUpdateState (
            _0xd5eca6,
            _0x2f93e4[0],
            _0x2f93e4[1],
            _0x2f93e4[2],
            _0x2f93e4[3],
            _0x2f93e4[4],
            _0x2f93e4[5],
            _0x16463a,
            _0x0c9275._0xbfdb0a
        );
    }

    // supply initial state of VC to "prime" the force push game
    function _0xa251c6(
        bytes32 _0xd5eca6,
        bytes32 _0xdfd513,
        bytes _0xfeb0de,
        address _0xea46f9,
        address _0x7cfdbd,
        uint256[2] _0x17103d,
        uint256[4] _0xd2ceb2, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
        string _0x473f21
    )
        public
    {
        require(Channels[_0xd5eca6]._0x858abd, "LC is closed.");
        // sub-channel must be open
        require(!_0xc6fbd7[_0xdfd513]._0x5cf332, "VC is closed.");
        // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
        require(Channels[_0xd5eca6]._0xbfdb0a < _0x4ec2c9, "LC timeout not over.");
        // prevent rentry of initializing vc state
        require(_0xc6fbd7[_0xdfd513]._0x786364 == 0);
        // partyB is now Ingrid
        bytes32 _0x9f4045 = _0xb2df79(
            abi._0x9a8676(_0xdfd513, uint256(0), _0xea46f9, _0x7cfdbd, _0x17103d[0], _0x17103d[1], _0xd2ceb2[0], _0xd2ceb2[1], _0xd2ceb2[2], _0xd2ceb2[3])
        );

        // Make sure Alice has signed initial vc state (A/B in oldState)
        require(_0xea46f9 == ECTools._0x8e3fe7(_0x9f4045, _0x473f21));

        // Check the oldState is in the root hash
        require(_0x204b23(_0x9f4045, _0xfeb0de, Channels[_0xd5eca6].VCrootHash) == true);

        _0xc6fbd7[_0xdfd513]._0x1b04b5 = _0xea46f9; // VC participant A
        _0xc6fbd7[_0xdfd513]._0x16510a = _0x7cfdbd; // VC participant B
        _0xc6fbd7[_0xdfd513]._0x9c7bcc = uint256(0);
        _0xc6fbd7[_0xdfd513]._0x5b28f8[0] = _0xd2ceb2[0];
        _0xc6fbd7[_0xdfd513]._0x5b28f8[1] = _0xd2ceb2[1];
        _0xc6fbd7[_0xdfd513]._0x444b7a[0] = _0xd2ceb2[2];
        _0xc6fbd7[_0xdfd513]._0x444b7a[1] = _0xd2ceb2[3];
        _0xc6fbd7[_0xdfd513]._0x7a81e2 = _0x17103d;
        _0xc6fbd7[_0xdfd513]._0x786364 = _0x4ec2c9 + Channels[_0xd5eca6]._0x9ae645;
        _0xc6fbd7[_0xdfd513]._0xfadcdb = true;

        emit DidVCInit(_0xd5eca6, _0xdfd513, _0xfeb0de, uint256(0), _0xea46f9, _0x7cfdbd, _0xd2ceb2[0], _0xd2ceb2[1]);
    }

    //TODO: verify state transition since the hub did not agree to this state
    // make sure the A/B balances are not beyond ingrids bonds
    // Params: vc init state, vc final balance, vcID
    function _0xd95ce8(
        bytes32 _0xd5eca6,
        bytes32 _0xdfd513,
        uint256 _0xd23a28,
        address _0xea46f9,
        address _0x7cfdbd,
        uint256[4] _0xf9440c, // [ethupdateBalA, ethupdateBalB, tokenupdateBalA, tokenupdateBalB]
        string _0x473f21
    )
        public
    {
        require(Channels[_0xd5eca6]._0x858abd, "LC is closed.");
        // sub-channel must be open
        require(!_0xc6fbd7[_0xdfd513]._0x5cf332, "VC is closed.");
        require(_0xc6fbd7[_0xdfd513]._0x9c7bcc < _0xd23a28, "VC sequence is higher than update sequence.");
        require(
            _0xc6fbd7[_0xdfd513]._0x5b28f8[1] < _0xf9440c[1] && _0xc6fbd7[_0xdfd513]._0x444b7a[1] < _0xf9440c[3],
            "State updates may only increase recipient balance."
        );
        require(
            _0xc6fbd7[_0xdfd513]._0x7a81e2[0] == _0xf9440c[0] + _0xf9440c[1] &&
            _0xc6fbd7[_0xdfd513]._0x7a81e2[1] == _0xf9440c[2] + _0xf9440c[3],
            "Incorrect balances for bonded amount");
        // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
        // virtualChannels[_vcID].updateVCtimeout should be 0 on uninitialized vc state, and this should
        // fail if initVC() isn't called first
        // require(Channels[_lcID].updateLCtimeout < now && now < virtualChannels[_vcID].updateVCtimeout);
        require(Channels[_0xd5eca6]._0xbfdb0a < _0x4ec2c9); // for testing!

        bytes32 _0x607835 = _0xb2df79(
            abi._0x9a8676(
                _0xdfd513,
                _0xd23a28,
                _0xea46f9,
                _0x7cfdbd,
                _0xc6fbd7[_0xdfd513]._0x7a81e2[0],
                _0xc6fbd7[_0xdfd513]._0x7a81e2[1],
                _0xf9440c[0],
                _0xf9440c[1],
                _0xf9440c[2],
                _0xf9440c[3]
            )
        );

        // Make sure Alice has signed a higher sequence new state
        require(_0xc6fbd7[_0xdfd513]._0x1b04b5 == ECTools._0x8e3fe7(_0x607835, _0x473f21));

        // store VC data
        // we may want to record who is initiating on-chain settles
        _0xc6fbd7[_0xdfd513]._0x352239 = msg.sender;
        _0xc6fbd7[_0xdfd513]._0x9c7bcc = _0xd23a28;

        // channel state
        _0xc6fbd7[_0xdfd513]._0x5b28f8[0] = _0xf9440c[0];
        _0xc6fbd7[_0xdfd513]._0x5b28f8[1] = _0xf9440c[1];
        _0xc6fbd7[_0xdfd513]._0x444b7a[0] = _0xf9440c[2];
        _0xc6fbd7[_0xdfd513]._0x444b7a[1] = _0xf9440c[3];

        _0xc6fbd7[_0xdfd513]._0x786364 = _0x4ec2c9 + Channels[_0xd5eca6]._0x9ae645;

        emit DidVCSettle(_0xd5eca6, _0xdfd513, _0xd23a28, _0xf9440c[0], _0xf9440c[1], msg.sender, _0xc6fbd7[_0xdfd513]._0x786364);
    }

    function _0xe968a1(bytes32 _0xd5eca6, bytes32 _0xdfd513) public {
        // require(updateLCtimeout > now)
        require(Channels[_0xd5eca6]._0x858abd, "LC is closed.");
        require(_0xc6fbd7[_0xdfd513]._0xfadcdb, "VC is not in settlement state.");
        require(_0xc6fbd7[_0xdfd513]._0x786364 < _0x4ec2c9, "Update vc timeout has not elapsed.");
        require(!_0xc6fbd7[_0xdfd513]._0x5cf332, "VC is already closed");
        // reduce the number of open virtual channels stored on LC
        Channels[_0xd5eca6]._0x4acd9d--;
        // close vc flags
        _0xc6fbd7[_0xdfd513]._0x5cf332 = true;
        // re-introduce the balances back into the LC state from the settled VC
        // decide if this lc is alice or bob in the vc
        if(_0xc6fbd7[_0xdfd513]._0x1b04b5 == Channels[_0xd5eca6]._0xd78819[0]) {
            Channels[_0xd5eca6]._0x5b28f8[0] += _0xc6fbd7[_0xdfd513]._0x5b28f8[0];
            Channels[_0xd5eca6]._0x5b28f8[1] += _0xc6fbd7[_0xdfd513]._0x5b28f8[1];

            Channels[_0xd5eca6]._0x444b7a[0] += _0xc6fbd7[_0xdfd513]._0x444b7a[0];
            Channels[_0xd5eca6]._0x444b7a[1] += _0xc6fbd7[_0xdfd513]._0x444b7a[1];
        } else if (_0xc6fbd7[_0xdfd513]._0x16510a == Channels[_0xd5eca6]._0xd78819[0]) {
            Channels[_0xd5eca6]._0x5b28f8[0] += _0xc6fbd7[_0xdfd513]._0x5b28f8[1];
            Channels[_0xd5eca6]._0x5b28f8[1] += _0xc6fbd7[_0xdfd513]._0x5b28f8[0];

            Channels[_0xd5eca6]._0x444b7a[0] += _0xc6fbd7[_0xdfd513]._0x444b7a[1];
            Channels[_0xd5eca6]._0x444b7a[1] += _0xc6fbd7[_0xdfd513]._0x444b7a[0];
        }

        emit DidVCClose(_0xd5eca6, _0xdfd513, _0xc6fbd7[_0xdfd513]._0x444b7a[0], _0xc6fbd7[_0xdfd513]._0x444b7a[1]);
    }

    // todo: allow ethier lc.end-user to nullify the settled LC state and return to off-chain
    function _0xca2b45(bytes32 _0xd5eca6) public {
        Channel storage _0x0c9275 = Channels[_0xd5eca6];

        // check settlement flag
        require(_0x0c9275._0x858abd, "Channel is not open");
        require(_0x0c9275._0x4fa389 == true);
        require(_0x0c9275._0x4acd9d == 0);
        require(_0x0c9275._0xbfdb0a < _0x4ec2c9, "LC timeout over.");

        // if off chain state update didnt reblance deposits, just return to deposit owner
        uint256 _0xe9ff68 = _0x0c9275._0xd76205[0] + _0x0c9275._0x5b28f8[2] + _0x0c9275._0x5b28f8[3];
        uint256 _0xeac582 = _0x0c9275._0xd76205[1] + _0x0c9275._0x444b7a[2] + _0x0c9275._0x444b7a[3];

        uint256 _0x677a00 = _0x0c9275._0x5b28f8[0] + _0x0c9275._0x5b28f8[1];
        uint256 _0xbc40a0 = _0x0c9275._0x444b7a[0] + _0x0c9275._0x444b7a[1];

        if(_0x677a00 < _0xe9ff68) {
            _0x0c9275._0x5b28f8[0]+=_0x0c9275._0x5b28f8[2];
            _0x0c9275._0x5b28f8[1]+=_0x0c9275._0x5b28f8[3];
        } else {
            require(_0x677a00 == _0xe9ff68);
        }

        if(_0xbc40a0 < _0xeac582) {
            _0x0c9275._0x444b7a[0]+=_0x0c9275._0x444b7a[2];
            _0x0c9275._0x444b7a[1]+=_0x0c9275._0x444b7a[3];
        } else {
            require(_0xbc40a0 == _0xeac582);
        }

        uint256 _0x18e218 = _0x0c9275._0x5b28f8[0];
        uint256 _0x0450c1 = _0x0c9275._0x5b28f8[1];
        uint256 _0xb53e56 = _0x0c9275._0x444b7a[0];
        uint256 _0xe8ca9e = _0x0c9275._0x444b7a[1];

        _0x0c9275._0x5b28f8[0] = 0;
        _0x0c9275._0x5b28f8[1] = 0;
        _0x0c9275._0x444b7a[0] = 0;
        _0x0c9275._0x444b7a[1] = 0;

        if(_0x18e218 != 0 || _0x0450c1 != 0) {
            _0x0c9275._0xd78819[0].transfer(_0x18e218);
            _0x0c9275._0xd78819[1].transfer(_0x0450c1);
        }

        if(_0xb53e56 != 0 || _0xe8ca9e != 0) {
            require(
                _0x0c9275._0xc646b7.transfer(_0x0c9275._0xd78819[0], _0xb53e56),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                _0x0c9275._0xc646b7.transfer(_0x0c9275._0xd78819[1], _0xe8ca9e),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        _0x0c9275._0x858abd = false;
        _0x3a8ee9--;

        emit DidLCClose(_0xd5eca6, _0x0c9275._0x9c7bcc, _0x18e218, _0x0450c1, _0xb53e56, _0xe8ca9e);
    }

    function _0x204b23(bytes32 _0xba0a4a, bytes _0xfeb0de, bytes32 _0x89858b) internal pure returns (bool) {
        bytes32 _0x40d16d = _0xba0a4a;
        bytes32 _0x6f3c83;

        for (uint256 i = 64; i <= _0xfeb0de.length; i += 32) {
            assembly { _0x6f3c83 := mload(add(_0xfeb0de, i)) }

            if (_0x40d16d < _0x6f3c83) {
                _0x40d16d = _0xb2df79(abi._0x9a8676(_0x40d16d, _0x6f3c83));
            } else {
                _0x40d16d = _0xb2df79(abi._0x9a8676(_0x6f3c83, _0x40d16d));
            }
        }

        return _0x40d16d == _0x89858b;
    }

    //Struct Getters
    function _0x5c17ba(bytes32 _0x99d926) public view returns (
        address[2],
        uint256[4],
        uint256[4],
        uint256[2],
        uint256,
        uint256,
        bytes32,
        uint256,
        uint256,
        bool,
        bool,
        uint256
    ) {
        Channel memory _0x0c9275 = Channels[_0x99d926];
        return (
            _0x0c9275._0xd78819,
            _0x0c9275._0x5b28f8,
            _0x0c9275._0x444b7a,
            _0x0c9275._0xd76205,
            _0x0c9275._0x9c7bcc,
            _0x0c9275._0x9ae645,
            _0x0c9275.VCrootHash,
            _0x0c9275.LCopenTimeout,
            _0x0c9275._0xbfdb0a,
            _0x0c9275._0x858abd,
            _0x0c9275._0x4fa389,
            _0x0c9275._0x4acd9d
        );
    }

    function _0x4df07e(bytes32 _0x99d926) public view returns(
        bool,
        bool,
        uint256,
        address,
        uint256,
        address,
        address,
        address,
        uint256[2],
        uint256[2],
        uint256[2]
    ) {
        VirtualChannel memory _0x8a7b74 = _0xc6fbd7[_0x99d926];
        return(
            _0x8a7b74._0x5cf332,
            _0x8a7b74._0xfadcdb,
            _0x8a7b74._0x9c7bcc,
            _0x8a7b74._0x352239,
            _0x8a7b74._0x786364,
            _0x8a7b74._0x1b04b5,
            _0x8a7b74._0x16510a,
            _0x8a7b74._0xbf5fdf,
            _0x8a7b74._0x5b28f8,
            _0x8a7b74._0x444b7a,
            _0x8a7b74._0x7a81e2
        );
    }
}