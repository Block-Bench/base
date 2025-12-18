// https://etherscan.io/address/0xf91546835f756da0c10cfa0cda95b15577b84aa7#code

pragma solidity ^0.4.23;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
contract Token {
    /// total amount of tokens
    uint256 public _0xaf2667;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x099a1e(address _0x290770) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0x191d22, uint256 _0x950c37) public returns (bool _0xf4ae07);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function _0x5c5569(address _0xa98d0e, address _0x191d22, uint256 _0x950c37) public returns (bool _0xf4ae07);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0xc9b769(address _0x23cb46, uint256 _0x950c37) public returns (bool _0xf4ae07);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function _0x06f515(address _0x290770, address _0x23cb46) public constant returns (uint256 _0xb73e01);

    event Transfer(address indexed _0xa98d0e, address indexed _0x191d22, uint256 _0x950c37);
    event Approval(address indexed _0x290770, address indexed _0x23cb46, uint256 _0x950c37);
}

library ECTools {

    // @dev Recovers the address which has signed a message
    // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
    function _0x9e4c46(bytes32 _0x21e70d, string _0x3232c8) public pure returns (address) {
        require(_0x21e70d != 0x00);

        // need this for test RPC
        bytes memory _0xe7d65b = "\x19Ethereum Signed Message:\n32";
        bytes32 _0x62ca45 = _0xd589db(abi._0xedbb35(_0xe7d65b, _0x21e70d));

        if (bytes(_0x3232c8).length != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = _0x59380b(_0x1a89c9(_0x3232c8, 2, 132));
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
        return _0xd3c92a(_0x62ca45, v, r, s);
    }

    // @dev Verifies if the message is signed by an address
    function _0xd71b4f(bytes32 _0x21e70d, string _0x3232c8, address _0xdfd431) public pure returns (bool) {
        require(_0xdfd431 != 0x0);

        return _0xdfd431 == _0x9e4c46(_0x21e70d, _0x3232c8);
    }

    // @dev Converts an hexstring to bytes
    function _0x59380b(string _0xdfc86f) public pure returns (bytes) {
        uint _0xedbc43 = bytes(_0xdfc86f).length;
        require(_0xedbc43 % 2 == 0);

        bytes memory _0x8829eb = bytes(new string(_0xedbc43 / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < _0xedbc43; i += 2) {
            s = _0x1a89c9(_0xdfc86f, i, i + 1);
            r = _0x1a89c9(_0xdfc86f, i + 1, i + 2);
            uint p = _0x5eaad8(s) * 16 + _0x5eaad8(r);
            _0x8829eb[k++] = _0x0d011a(p)[31];
        }
        return _0x8829eb;
    }

    // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
    function _0x5eaad8(string _0x3aaf8b) public pure returns (uint) {
        bytes memory _0xcb3c96 = bytes(_0x3aaf8b);
        // bool decimals = false;
        if ((_0xcb3c96[0] >= 48) && (_0xcb3c96[0] <= 57)) {
            return uint(_0xcb3c96[0]) - 48;
        } else if ((_0xcb3c96[0] >= 65) && (_0xcb3c96[0] <= 70)) {
            return uint(_0xcb3c96[0]) - 55;
        } else if ((_0xcb3c96[0] >= 97) && (_0xcb3c96[0] <= 102)) {
            return uint(_0xcb3c96[0]) - 87;
        } else {
            revert();
        }
    }

    // @dev Converts a uint to a bytes32
    // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
    function _0x0d011a(uint _0x5329ac) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), _0x5329ac)}
    }

    // @dev Hashes the signed message
    // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
    function _0x73f767(string _0xfaa9ac) public pure returns (bytes32) {
        uint _0xedbc43 = bytes(_0xfaa9ac).length;
        require(_0xedbc43 > 0);
        bytes memory _0xe7d65b = "\x19Ethereum Signed Message:\n";
        return _0xd589db(abi._0xedbb35(_0xe7d65b, _0x8ee42d(_0xedbc43), _0xfaa9ac));
    }

    // @dev Converts a uint in a string
    function _0x8ee42d(uint _0x5329ac) public pure returns (string _0x68f1cf) {
        uint _0xedbc43 = 0;
        uint m = _0x5329ac + 0;
        while (m != 0) {
            _0xedbc43++;
            m /= 10;
        }
        bytes memory b = new bytes(_0xedbc43);
        uint i = _0xedbc43 - 1;
        while (_0x5329ac != 0) {
            uint _0x62b16f = _0x5329ac % 10;
            _0x5329ac = _0x5329ac / 10;
            b[i--] = byte(48 + _0x62b16f);
        }
        _0x68f1cf = string(b);
    }

    // @dev extract a substring
    // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
    function _0x1a89c9(string _0xc177f8, uint _0xd83be1, uint _0x21b867) public pure returns (string) {
        bytes memory _0x41afc8 = bytes(_0xc177f8);
        require(_0xd83be1 <= _0x21b867);
        require(_0xd83be1 >= 0);
        require(_0x21b867 <= _0x41afc8.length);

        bytes memory _0x6a8406 = new bytes(_0x21b867 - _0xd83be1);
        for (uint i = _0xd83be1; i < _0x21b867; i++) {
            _0x6a8406[i - _0xd83be1] = _0x41afc8[i];
        }
        return string(_0x6a8406);
    }
}
contract StandardToken is Token {

    function transfer(address _0x191d22, uint256 _0x950c37) public returns (bool _0xf4ae07) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0x4a40af[msg.sender] >= _0x950c37);
        _0x4a40af[msg.sender] -= _0x950c37;
        _0x4a40af[_0x191d22] += _0x950c37;
        emit Transfer(msg.sender, _0x191d22, _0x950c37);
        return true;
    }

    function _0x5c5569(address _0xa98d0e, address _0x191d22, uint256 _0x950c37) public returns (bool _0xf4ae07) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_0x4a40af[_0xa98d0e] >= _0x950c37 && _0x4eb65f[_0xa98d0e][msg.sender] >= _0x950c37);
        _0x4a40af[_0x191d22] += _0x950c37;
        _0x4a40af[_0xa98d0e] -= _0x950c37;
        _0x4eb65f[_0xa98d0e][msg.sender] -= _0x950c37;
        emit Transfer(_0xa98d0e, _0x191d22, _0x950c37);
        return true;
    }

    function _0x099a1e(address _0x290770) public constant returns (uint256 balance) {
        return _0x4a40af[_0x290770];
    }

    function _0xc9b769(address _0x23cb46, uint256 _0x950c37) public returns (bool _0xf4ae07) {
        _0x4eb65f[msg.sender][_0x23cb46] = _0x950c37;
        emit Approval(msg.sender, _0x23cb46, _0x950c37);
        return true;
    }

    function _0x06f515(address _0x290770, address _0x23cb46) public constant returns (uint256 _0xb73e01) {
      return _0x4eb65f[_0x290770][_0x23cb46];
    }

    mapping (address => uint256) _0x4a40af;
    mapping (address => mapping (address => uint256)) _0x4eb65f;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */

    string public _0x8f440c;                   //fancy name: eg Simon Bucks
    uint8 public _0x1f1e3b;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public _0x3b30ed;                 //An identifier: eg SBX
    string public _0x1ed2ed = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    constructor(
        uint256 _0x772e76,
        string _0x712599,
        uint8 _0x799483,
        string _0x819e38
        ) public {
        _0x4a40af[msg.sender] = _0x772e76;               // Give the creator all initial tokens
        _0xaf2667 = _0x772e76;                        // Update total supply
        _0x8f440c = _0x712599;                                   // Set the name for display purposes
        _0x1f1e3b = _0x799483;                            // Amount of decimals for display purposes
        _0x3b30ed = _0x819e38;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function _0xc50ba0(address _0x23cb46, uint256 _0x950c37, bytes _0x9a54ad) public returns (bool _0xf4ae07) {
        _0x4eb65f[msg.sender][_0x23cb46] = _0x950c37;
        emit Approval(msg.sender, _0x23cb46, _0x950c37);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_0x23cb46.call(bytes4(bytes32(_0xd589db("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x950c37, this, _0x9a54ad));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant VERSION = "0.0.1";

    uint256 public _0xb23b8d = 0;

    event DidLCOpen (
        bytes32 indexed _0xf1a216,
        address indexed _0xf0dad9,
        address indexed _0x568a31,
        uint256 _0x00794c,
        address _0xeea74d,
        uint256 _0xef558f,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed _0xf1a216,
        uint256 _0xee81bf,
        uint256 _0x44fcb5
    );

    event DidLCDeposit (
        bytes32 indexed _0xf1a216,
        address indexed _0xb33a2b,
        uint256 _0xff7196,
        bool _0x4775b1
    );

    event DidLCUpdateState (
        bytes32 indexed _0xf1a216,
        uint256 _0x98d130,
        uint256 _0x3aee39,
        uint256 _0x00794c,
        uint256 _0xef558f,
        uint256 _0xee81bf,
        uint256 _0x44fcb5,
        bytes32 _0xcc7ba7,
        uint256 _0x7fafbe
    );

    event DidLCClose (
        bytes32 indexed _0xf1a216,
        uint256 _0x98d130,
        uint256 _0x00794c,
        uint256 _0xef558f,
        uint256 _0xee81bf,
        uint256 _0x44fcb5
    );

    event DidVCInit (
        bytes32 indexed _0xb8227c,
        bytes32 indexed _0xf7ad07,
        bytes _0x47059d,
        uint256 _0x98d130,
        address _0xf0dad9,
        address _0x34a450,
        uint256 _0xac2e8c,
        uint256 _0x09660f
    );

    event DidVCSettle (
        bytes32 indexed _0xb8227c,
        bytes32 indexed _0xf7ad07,
        uint256 _0x483902,
        uint256 _0x16ff53,
        uint256 _0xbd7bb2,
        address _0x7d4771,
        uint256 _0xa00fe2
    );

    event DidVCClose(
        bytes32 indexed _0xb8227c,
        bytes32 indexed _0xf7ad07,
        uint256 _0xac2e8c,
        uint256 _0x09660f
    );

    struct Channel {
        //TODO: figure out if it's better just to split arrays by balances/deposits instead of eth/erc20
        address[2] _0x87d64c; // 0: partyA 1: partyI
        uint256[4] _0x63b5d6; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
        uint256[4] _0x26beec; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
        uint256[2] _0xfc333a; // 0: eth 1: tokens
        uint256 _0x98d130;
        uint256 _0xcd7dcb;
        bytes32 VCrootHash;
        uint256 LCopenTimeout;
        uint256 _0x7fafbe; // when update LC times out
        bool _0x96dbf0; // true when both parties have joined
        bool _0x0c9a4e;
        uint256 _0x1bc1ab;
        HumanStandardToken _0xeea74d;
    }

    // virtual-channel state
    struct VirtualChannel {
        bool _0x3eda89;
        bool _0x0dfb5f;
        uint256 _0x98d130;
        address _0x7d4771; // Initiator of challenge
        uint256 _0xa00fe2; // when update VC times out
        // channel state
        address _0xf0dad9; // VC participant A
        address _0x34a450; // VC participant B
        address _0x568a31; // LC hub
        uint256[2] _0x63b5d6;
        uint256[2] _0x26beec;
        uint256[2] _0xa246aa;
        HumanStandardToken _0xeea74d;
    }

    mapping(bytes32 => VirtualChannel) public _0xeb0da9;
    mapping(bytes32 => Channel) public Channels;

    function _0x8d73cd(
        bytes32 _0x3c9236,
        address _0xe0a765,
        uint256 _0xbfc8fa,
        address _0xe5aafc,
        uint256[2] _0x9795d1 // [eth, token]
    )
        public
        payable
    {
        require(Channels[_0x3c9236]._0x87d64c[0] == address(0), "Channel has already been created.");
        require(_0xe0a765 != 0x0, "No partyI address provided to LC creation");
        require(_0x9795d1[0] >= 0 && _0x9795d1[1] >= 0, "Balances cannot be negative");
        // Set initial ledger channel state
        // Alice must execute this and we assume the initial state
        // to be signed from this requirement
        // Alternative is to check a sig as in joinChannel
        Channels[_0x3c9236]._0x87d64c[0] = msg.sender;
        Channels[_0x3c9236]._0x87d64c[1] = _0xe0a765;

        if(_0x9795d1[0] != 0) {
            require(msg.value == _0x9795d1[0], "Eth balance does not match sent value");
            Channels[_0x3c9236]._0x63b5d6[0] = msg.value;
        }
        if(_0x9795d1[1] != 0) {
            Channels[_0x3c9236]._0xeea74d = HumanStandardToken(_0xe5aafc);
            require(Channels[_0x3c9236]._0xeea74d._0x5c5569(msg.sender, this, _0x9795d1[1]),"CreateChannel: token transfer failure");
            Channels[_0x3c9236]._0x26beec[0] = _0x9795d1[1];
        }

        Channels[_0x3c9236]._0x98d130 = 0;
        Channels[_0x3c9236]._0xcd7dcb = _0xbfc8fa;
        // is close flag, lc state sequence, number open vc, vc root hash, partyA...
        //Channels[_lcID].stateHash = keccak256(uint256(0), uint256(0), uint256(0), bytes32(0x0), bytes32(msg.sender), bytes32(_partyI), balanceA, balanceI);
        Channels[_0x3c9236].LCopenTimeout = _0xe56a9d + _0xbfc8fa;
        Channels[_0x3c9236]._0xfc333a = _0x9795d1;

        emit DidLCOpen(_0x3c9236, msg.sender, _0xe0a765, _0x9795d1[0], _0xe5aafc, _0x9795d1[1], Channels[_0x3c9236].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _0x3c9236) public {
        require(msg.sender == Channels[_0x3c9236]._0x87d64c[0] && Channels[_0x3c9236]._0x96dbf0 == false);
        require(_0xe56a9d > Channels[_0x3c9236].LCopenTimeout);

        if(Channels[_0x3c9236]._0xfc333a[0] != 0) {
            Channels[_0x3c9236]._0x87d64c[0].transfer(Channels[_0x3c9236]._0x63b5d6[0]);
        }
        if(Channels[_0x3c9236]._0xfc333a[1] != 0) {
            require(Channels[_0x3c9236]._0xeea74d.transfer(Channels[_0x3c9236]._0x87d64c[0], Channels[_0x3c9236]._0x26beec[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_0x3c9236, 0, Channels[_0x3c9236]._0x63b5d6[0], Channels[_0x3c9236]._0x26beec[0], 0, 0);

        // only safe to delete since no action was taken on this channel
        delete Channels[_0x3c9236];
    }

    function _0x4d9b78(bytes32 _0x3c9236, uint256[2] _0x9795d1) public payable {
        // require the channel is not open yet
        require(Channels[_0x3c9236]._0x96dbf0 == false);
        require(msg.sender == Channels[_0x3c9236]._0x87d64c[1]);

        if(_0x9795d1[0] != 0) {
            require(msg.value == _0x9795d1[0], "state balance does not match sent value");
            Channels[_0x3c9236]._0x63b5d6[1] = msg.value;
        }
        if(_0x9795d1[1] != 0) {
            require(Channels[_0x3c9236]._0xeea74d._0x5c5569(msg.sender, this, _0x9795d1[1]),"joinChannel: token transfer failure");
            Channels[_0x3c9236]._0x26beec[1] = _0x9795d1[1];
        }

        Channels[_0x3c9236]._0xfc333a[0]+=_0x9795d1[0];
        Channels[_0x3c9236]._0xfc333a[1]+=_0x9795d1[1];
        // no longer allow joining functions to be called
        Channels[_0x3c9236]._0x96dbf0 = true;
        _0xb23b8d++;

        emit DidLCJoin(_0x3c9236, _0x9795d1[0], _0x9795d1[1]);
    }

    // additive updates of monetary state
    function _0xff7196(bytes32 _0x3c9236, address _0xb33a2b, uint256 _0xf39928, bool _0x4775b1) public payable {
        require(Channels[_0x3c9236]._0x96dbf0 == true, "Tried adding funds to a closed channel");
        require(_0xb33a2b == Channels[_0x3c9236]._0x87d64c[0] || _0xb33a2b == Channels[_0x3c9236]._0x87d64c[1]);

        //if(Channels[_lcID].token)

        if (Channels[_0x3c9236]._0x87d64c[0] == _0xb33a2b) {
            if(_0x4775b1) {
                require(Channels[_0x3c9236]._0xeea74d._0x5c5569(msg.sender, this, _0xf39928),"deposit: token transfer failure");
                Channels[_0x3c9236]._0x26beec[2] += _0xf39928;
            } else {
                require(msg.value == _0xf39928, "state balance does not match sent value");
                Channels[_0x3c9236]._0x63b5d6[2] += msg.value;
            }
        }

        if (Channels[_0x3c9236]._0x87d64c[1] == _0xb33a2b) {
            if(_0x4775b1) {
                require(Channels[_0x3c9236]._0xeea74d._0x5c5569(msg.sender, this, _0xf39928),"deposit: token transfer failure");
                Channels[_0x3c9236]._0x26beec[3] += _0xf39928;
            } else {
                require(msg.value == _0xf39928, "state balance does not match sent value");
                Channels[_0x3c9236]._0x63b5d6[3] += msg.value;
            }
        }

        emit DidLCDeposit(_0x3c9236, _0xb33a2b, _0xf39928, _0x4775b1);
    }

    // TODO: Check there are no open virtual channels, the client should have cought this before signing a close LC state update
    function _0xc80399(
        bytes32 _0x3c9236,
        uint256 _0x0aac5e,
        uint256[4] _0x9795d1, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
        string _0xfbef37,
        string _0x556db0
    )
        public
    {
        // assume num open vc is 0 and root hash is 0x0
        //require(Channels[_lcID].sequence < _sequence);
        require(Channels[_0x3c9236]._0x96dbf0 == true);
        uint256 _0xd24d32 = Channels[_0x3c9236]._0xfc333a[0] + Channels[_0x3c9236]._0x63b5d6[2] + Channels[_0x3c9236]._0x63b5d6[3];
        uint256 _0x34b8b5 = Channels[_0x3c9236]._0xfc333a[1] + Channels[_0x3c9236]._0x26beec[2] + Channels[_0x3c9236]._0x26beec[3];
        require(_0xd24d32 == _0x9795d1[0] + _0x9795d1[1]);
        require(_0x34b8b5 == _0x9795d1[2] + _0x9795d1[3]);

        bytes32 _0xef602e = _0xd589db(
            abi._0xedbb35(
                _0x3c9236,
                true,
                _0x0aac5e,
                uint256(0),
                bytes32(0x0),
                Channels[_0x3c9236]._0x87d64c[0],
                Channels[_0x3c9236]._0x87d64c[1],
                _0x9795d1[0],
                _0x9795d1[1],
                _0x9795d1[2],
                _0x9795d1[3]
            )
        );

        require(Channels[_0x3c9236]._0x87d64c[0] == ECTools._0x9e4c46(_0xef602e, _0xfbef37));
        require(Channels[_0x3c9236]._0x87d64c[1] == ECTools._0x9e4c46(_0xef602e, _0x556db0));

        Channels[_0x3c9236]._0x96dbf0 = false;

        if(_0x9795d1[0] != 0 || _0x9795d1[1] != 0) {
            Channels[_0x3c9236]._0x87d64c[0].transfer(_0x9795d1[0]);
            Channels[_0x3c9236]._0x87d64c[1].transfer(_0x9795d1[1]);
        }

        if(_0x9795d1[2] != 0 || _0x9795d1[3] != 0) {
            require(Channels[_0x3c9236]._0xeea74d.transfer(Channels[_0x3c9236]._0x87d64c[0], _0x9795d1[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_0x3c9236]._0xeea74d.transfer(Channels[_0x3c9236]._0x87d64c[1], _0x9795d1[3]),"happyCloseChannel: token transfer failure");
        }

        _0xb23b8d--;

        emit DidLCClose(_0x3c9236, _0x0aac5e, _0x9795d1[0], _0x9795d1[1], _0x9795d1[2], _0x9795d1[3]);
    }

    // Byzantine functions

    function _0x71524a(
        bytes32 _0x3c9236,
        uint256[6] _0x476ad7, // [sequence, numOpenVc, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI]
        bytes32 _0xe9533c,
        string _0xfbef37,
        string _0x556db0
    )
        public
    {
        Channel storage _0x863509 = Channels[_0x3c9236];
        require(_0x863509._0x96dbf0);
        require(_0x863509._0x98d130 < _0x476ad7[0]); // do same as vc sequence check
        require(_0x863509._0x63b5d6[0] + _0x863509._0x63b5d6[1] >= _0x476ad7[2] + _0x476ad7[3]);
        require(_0x863509._0x26beec[0] + _0x863509._0x26beec[1] >= _0x476ad7[4] + _0x476ad7[5]);

        if(_0x863509._0x0c9a4e == true) {
            require(_0x863509._0x7fafbe > _0xe56a9d);
        }

        bytes32 _0xef602e = _0xd589db(
            abi._0xedbb35(
                _0x3c9236,
                false,
                _0x476ad7[0],
                _0x476ad7[1],
                _0xe9533c,
                _0x863509._0x87d64c[0],
                _0x863509._0x87d64c[1],
                _0x476ad7[2],
                _0x476ad7[3],
                _0x476ad7[4],
                _0x476ad7[5]
            )
        );

        require(_0x863509._0x87d64c[0] == ECTools._0x9e4c46(_0xef602e, _0xfbef37));
        require(_0x863509._0x87d64c[1] == ECTools._0x9e4c46(_0xef602e, _0x556db0));

        // update LC state
        _0x863509._0x98d130 = _0x476ad7[0];
        _0x863509._0x1bc1ab = _0x476ad7[1];
        _0x863509._0x63b5d6[0] = _0x476ad7[2];
        _0x863509._0x63b5d6[1] = _0x476ad7[3];
        _0x863509._0x26beec[0] = _0x476ad7[4];
        _0x863509._0x26beec[1] = _0x476ad7[5];
        _0x863509.VCrootHash = _0xe9533c;
        _0x863509._0x0c9a4e = true;
        _0x863509._0x7fafbe = _0xe56a9d + _0x863509._0xcd7dcb;

        // make settlement flag

        emit DidLCUpdateState (
            _0x3c9236,
            _0x476ad7[0],
            _0x476ad7[1],
            _0x476ad7[2],
            _0x476ad7[3],
            _0x476ad7[4],
            _0x476ad7[5],
            _0xe9533c,
            _0x863509._0x7fafbe
        );
    }

    // supply initial state of VC to "prime" the force push game
    function _0x16876c(
        bytes32 _0x3c9236,
        bytes32 _0x85c4e7,
        bytes _0xb63ddf,
        address _0x65e731,
        address _0xeec04c,
        uint256[2] _0x867bc1,
        uint256[4] _0x9795d1, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
        string _0x28b148
    )
        public
    {
        require(Channels[_0x3c9236]._0x96dbf0, "LC is closed.");
        // sub-channel must be open
        require(!_0xeb0da9[_0x85c4e7]._0x3eda89, "VC is closed.");
        // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
        require(Channels[_0x3c9236]._0x7fafbe < _0xe56a9d, "LC timeout not over.");
        // prevent rentry of initializing vc state
        require(_0xeb0da9[_0x85c4e7]._0xa00fe2 == 0);
        // partyB is now Ingrid
        bytes32 _0xa58ef3 = _0xd589db(
            abi._0xedbb35(_0x85c4e7, uint256(0), _0x65e731, _0xeec04c, _0x867bc1[0], _0x867bc1[1], _0x9795d1[0], _0x9795d1[1], _0x9795d1[2], _0x9795d1[3])
        );

        // Make sure Alice has signed initial vc state (A/B in oldState)
        require(_0x65e731 == ECTools._0x9e4c46(_0xa58ef3, _0x28b148));

        // Check the oldState is in the root hash
        require(_0x052173(_0xa58ef3, _0xb63ddf, Channels[_0x3c9236].VCrootHash) == true);

        _0xeb0da9[_0x85c4e7]._0xf0dad9 = _0x65e731; // VC participant A
        _0xeb0da9[_0x85c4e7]._0x34a450 = _0xeec04c; // VC participant B
        _0xeb0da9[_0x85c4e7]._0x98d130 = uint256(0);
        _0xeb0da9[_0x85c4e7]._0x63b5d6[0] = _0x9795d1[0];
        _0xeb0da9[_0x85c4e7]._0x63b5d6[1] = _0x9795d1[1];
        _0xeb0da9[_0x85c4e7]._0x26beec[0] = _0x9795d1[2];
        _0xeb0da9[_0x85c4e7]._0x26beec[1] = _0x9795d1[3];
        _0xeb0da9[_0x85c4e7]._0xa246aa = _0x867bc1;
        _0xeb0da9[_0x85c4e7]._0xa00fe2 = _0xe56a9d + Channels[_0x3c9236]._0xcd7dcb;
        _0xeb0da9[_0x85c4e7]._0x0dfb5f = true;

        emit DidVCInit(_0x3c9236, _0x85c4e7, _0xb63ddf, uint256(0), _0x65e731, _0xeec04c, _0x9795d1[0], _0x9795d1[1]);
    }

    //TODO: verify state transition since the hub did not agree to this state
    // make sure the A/B balances are not beyond ingrids bonds
    // Params: vc init state, vc final balance, vcID
    function _0xa48f77(
        bytes32 _0x3c9236,
        bytes32 _0x85c4e7,
        uint256 _0x483902,
        address _0x65e731,
        address _0xeec04c,
        uint256[4] _0x898cdc, // [ethupdateBalA, ethupdateBalB, tokenupdateBalA, tokenupdateBalB]
        string _0x28b148
    )
        public
    {
        require(Channels[_0x3c9236]._0x96dbf0, "LC is closed.");
        // sub-channel must be open
        require(!_0xeb0da9[_0x85c4e7]._0x3eda89, "VC is closed.");
        require(_0xeb0da9[_0x85c4e7]._0x98d130 < _0x483902, "VC sequence is higher than update sequence.");
        require(
            _0xeb0da9[_0x85c4e7]._0x63b5d6[1] < _0x898cdc[1] && _0xeb0da9[_0x85c4e7]._0x26beec[1] < _0x898cdc[3],
            "State updates may only increase recipient balance."
        );
        require(
            _0xeb0da9[_0x85c4e7]._0xa246aa[0] == _0x898cdc[0] + _0x898cdc[1] &&
            _0xeb0da9[_0x85c4e7]._0xa246aa[1] == _0x898cdc[2] + _0x898cdc[3],
            "Incorrect balances for bonded amount");
        // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
        // virtualChannels[_vcID].updateVCtimeout should be 0 on uninitialized vc state, and this should
        // fail if initVC() isn't called first
        // require(Channels[_lcID].updateLCtimeout < now && now < virtualChannels[_vcID].updateVCtimeout);
        require(Channels[_0x3c9236]._0x7fafbe < _0xe56a9d); // for testing!

        bytes32 _0x80641c = _0xd589db(
            abi._0xedbb35(
                _0x85c4e7,
                _0x483902,
                _0x65e731,
                _0xeec04c,
                _0xeb0da9[_0x85c4e7]._0xa246aa[0],
                _0xeb0da9[_0x85c4e7]._0xa246aa[1],
                _0x898cdc[0],
                _0x898cdc[1],
                _0x898cdc[2],
                _0x898cdc[3]
            )
        );

        // Make sure Alice has signed a higher sequence new state
        require(_0xeb0da9[_0x85c4e7]._0xf0dad9 == ECTools._0x9e4c46(_0x80641c, _0x28b148));

        // store VC data
        // we may want to record who is initiating on-chain settles
        _0xeb0da9[_0x85c4e7]._0x7d4771 = msg.sender;
        _0xeb0da9[_0x85c4e7]._0x98d130 = _0x483902;

        // channel state
        _0xeb0da9[_0x85c4e7]._0x63b5d6[0] = _0x898cdc[0];
        _0xeb0da9[_0x85c4e7]._0x63b5d6[1] = _0x898cdc[1];
        _0xeb0da9[_0x85c4e7]._0x26beec[0] = _0x898cdc[2];
        _0xeb0da9[_0x85c4e7]._0x26beec[1] = _0x898cdc[3];

        _0xeb0da9[_0x85c4e7]._0xa00fe2 = _0xe56a9d + Channels[_0x3c9236]._0xcd7dcb;

        emit DidVCSettle(_0x3c9236, _0x85c4e7, _0x483902, _0x898cdc[0], _0x898cdc[1], msg.sender, _0xeb0da9[_0x85c4e7]._0xa00fe2);
    }

    function _0x56de54(bytes32 _0x3c9236, bytes32 _0x85c4e7) public {
        // require(updateLCtimeout > now)
        require(Channels[_0x3c9236]._0x96dbf0, "LC is closed.");
        require(_0xeb0da9[_0x85c4e7]._0x0dfb5f, "VC is not in settlement state.");
        require(_0xeb0da9[_0x85c4e7]._0xa00fe2 < _0xe56a9d, "Update vc timeout has not elapsed.");
        require(!_0xeb0da9[_0x85c4e7]._0x3eda89, "VC is already closed");
        // reduce the number of open virtual channels stored on LC
        Channels[_0x3c9236]._0x1bc1ab--;
        // close vc flags
        _0xeb0da9[_0x85c4e7]._0x3eda89 = true;
        // re-introduce the balances back into the LC state from the settled VC
        // decide if this lc is alice or bob in the vc
        if(_0xeb0da9[_0x85c4e7]._0xf0dad9 == Channels[_0x3c9236]._0x87d64c[0]) {
            Channels[_0x3c9236]._0x63b5d6[0] += _0xeb0da9[_0x85c4e7]._0x63b5d6[0];
            Channels[_0x3c9236]._0x63b5d6[1] += _0xeb0da9[_0x85c4e7]._0x63b5d6[1];

            Channels[_0x3c9236]._0x26beec[0] += _0xeb0da9[_0x85c4e7]._0x26beec[0];
            Channels[_0x3c9236]._0x26beec[1] += _0xeb0da9[_0x85c4e7]._0x26beec[1];
        } else if (_0xeb0da9[_0x85c4e7]._0x34a450 == Channels[_0x3c9236]._0x87d64c[0]) {
            Channels[_0x3c9236]._0x63b5d6[0] += _0xeb0da9[_0x85c4e7]._0x63b5d6[1];
            Channels[_0x3c9236]._0x63b5d6[1] += _0xeb0da9[_0x85c4e7]._0x63b5d6[0];

            Channels[_0x3c9236]._0x26beec[0] += _0xeb0da9[_0x85c4e7]._0x26beec[1];
            Channels[_0x3c9236]._0x26beec[1] += _0xeb0da9[_0x85c4e7]._0x26beec[0];
        }

        emit DidVCClose(_0x3c9236, _0x85c4e7, _0xeb0da9[_0x85c4e7]._0x26beec[0], _0xeb0da9[_0x85c4e7]._0x26beec[1]);
    }

    // todo: allow ethier lc.end-user to nullify the settled LC state and return to off-chain
    function _0x35f7d4(bytes32 _0x3c9236) public {
        Channel storage _0x863509 = Channels[_0x3c9236];

        // check settlement flag
        require(_0x863509._0x96dbf0, "Channel is not open");
        require(_0x863509._0x0c9a4e == true);
        require(_0x863509._0x1bc1ab == 0);
        require(_0x863509._0x7fafbe < _0xe56a9d, "LC timeout over.");

        // if off chain state update didnt reblance deposits, just return to deposit owner
        uint256 _0xd24d32 = _0x863509._0xfc333a[0] + _0x863509._0x63b5d6[2] + _0x863509._0x63b5d6[3];
        uint256 _0x34b8b5 = _0x863509._0xfc333a[1] + _0x863509._0x26beec[2] + _0x863509._0x26beec[3];

        uint256 _0x13f276 = _0x863509._0x63b5d6[0] + _0x863509._0x63b5d6[1];
        uint256 _0x6c9082 = _0x863509._0x26beec[0] + _0x863509._0x26beec[1];

        if(_0x13f276 < _0xd24d32) {
            _0x863509._0x63b5d6[0]+=_0x863509._0x63b5d6[2];
            _0x863509._0x63b5d6[1]+=_0x863509._0x63b5d6[3];
        } else {
            require(_0x13f276 == _0xd24d32);
        }

        if(_0x6c9082 < _0x34b8b5) {
            _0x863509._0x26beec[0]+=_0x863509._0x26beec[2];
            _0x863509._0x26beec[1]+=_0x863509._0x26beec[3];
        } else {
            require(_0x6c9082 == _0x34b8b5);
        }

        uint256 _0x4da1f5 = _0x863509._0x63b5d6[0];
        uint256 _0x4fb321 = _0x863509._0x63b5d6[1];
        uint256 _0x642cee = _0x863509._0x26beec[0];
        uint256 _0x27ef3e = _0x863509._0x26beec[1];

        _0x863509._0x63b5d6[0] = 0;
        _0x863509._0x63b5d6[1] = 0;
        _0x863509._0x26beec[0] = 0;
        _0x863509._0x26beec[1] = 0;

        if(_0x4da1f5 != 0 || _0x4fb321 != 0) {
            _0x863509._0x87d64c[0].transfer(_0x4da1f5);
            _0x863509._0x87d64c[1].transfer(_0x4fb321);
        }

        if(_0x642cee != 0 || _0x27ef3e != 0) {
            require(
                _0x863509._0xeea74d.transfer(_0x863509._0x87d64c[0], _0x642cee),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                _0x863509._0xeea74d.transfer(_0x863509._0x87d64c[1], _0x27ef3e),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        _0x863509._0x96dbf0 = false;
        _0xb23b8d--;

        emit DidLCClose(_0x3c9236, _0x863509._0x98d130, _0x4da1f5, _0x4fb321, _0x642cee, _0x27ef3e);
    }

    function _0x052173(bytes32 _0xea8ab4, bytes _0xb63ddf, bytes32 _0x140cae) internal pure returns (bool) {
        bytes32 _0x770462 = _0xea8ab4;
        bytes32 _0x27cdaf;

        for (uint256 i = 64; i <= _0xb63ddf.length; i += 32) {
            assembly { _0x27cdaf := mload(add(_0xb63ddf, i)) }

            if (_0x770462 < _0x27cdaf) {
                _0x770462 = _0xd589db(abi._0xedbb35(_0x770462, _0x27cdaf));
            } else {
                _0x770462 = _0xd589db(abi._0xedbb35(_0x27cdaf, _0x770462));
            }
        }

        return _0x770462 == _0x140cae;
    }

    //Struct Getters
    function _0x0ac1a4(bytes32 _0x2ede7e) public view returns (
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
        Channel memory _0x863509 = Channels[_0x2ede7e];
        return (
            _0x863509._0x87d64c,
            _0x863509._0x63b5d6,
            _0x863509._0x26beec,
            _0x863509._0xfc333a,
            _0x863509._0x98d130,
            _0x863509._0xcd7dcb,
            _0x863509.VCrootHash,
            _0x863509.LCopenTimeout,
            _0x863509._0x7fafbe,
            _0x863509._0x96dbf0,
            _0x863509._0x0c9a4e,
            _0x863509._0x1bc1ab
        );
    }

    function _0xc40945(bytes32 _0x2ede7e) public view returns(
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
        VirtualChannel memory _0x945303 = _0xeb0da9[_0x2ede7e];
        return(
            _0x945303._0x3eda89,
            _0x945303._0x0dfb5f,
            _0x945303._0x98d130,
            _0x945303._0x7d4771,
            _0x945303._0xa00fe2,
            _0x945303._0xf0dad9,
            _0x945303._0x34a450,
            _0x945303._0x568a31,
            _0x945303._0x63b5d6,
            _0x945303._0x26beec,
            _0x945303._0xa246aa
        );
    }
}