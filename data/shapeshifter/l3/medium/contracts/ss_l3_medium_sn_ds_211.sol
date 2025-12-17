 pragma solidity ^0.4.23;
 // produced by the Solididy File Flattener (c) David Appleton 2018
 // contact : dave@akomba.com
 // released under Apache 2.0 licence
 contract Token {
     /// total amount of tokens
     uint256 public _0x93d391;

     /// @param _owner The address from which the balance will be retrieved
     /// @return The balance
     function _0x3e189a(address _0x583c81) public constant returns (uint256 balance);

     /// @notice send `_value` token to `_to` from `msg.sender`
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function transfer(address _0x7b9b08, uint256 _0x39d0a7) public returns (bool _0x66a052);

     /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     /// @param _from The address of the sender
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
     function _0x60c1dd(address _0x640951, address _0x7b9b08, uint256 _0x39d0a7) public returns (bool _0x66a052);

     /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @param _value The amount of tokens to be approved for transfer
     /// @return Whether the approval was successful or not
     function _0xf7f3ce(address _0x9be29c, uint256 _0x39d0a7) public returns (bool _0x66a052);

     /// @param _owner The address of the account owning tokens
     /// @param _spender The address of the account able to transfer the tokens
     /// @return Amount of remaining tokens allowed to spent
     function _0x287086(address _0x583c81, address _0x9be29c) public constant returns (uint256 _0xff7394);

     event Transfer(address indexed _0x640951, address indexed _0x7b9b08, uint256 _0x39d0a7);
     event Approval(address indexed _0x583c81, address indexed _0x9be29c, uint256 _0x39d0a7);
 }

 library ECTools {

     // @dev Recovers the address which has signed a message
     // @thanks https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
     function _0x4dbfdd(bytes32 _0xe0d8a9, string _0xe30511) public pure returns (address) {
         require(_0xe0d8a9 != 0x00);

         // need this for test RPC
         bytes memory _0x6a04c0 = "\x19Ethereum Signed Message:\n32";
         bytes32 _0x5db7df = _0xc5001e(abi._0x0cfd25(_0x6a04c0, _0xe0d8a9));

         if (bytes(_0xe30511).length != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = _0x6278df(_0x746b0a(_0xe30511, 2, 132));
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
         return _0xd9aba3(_0x5db7df, v, r, s);
     }

     // @dev Verifies if the message is signed by an address
     function _0x3b5ba6(bytes32 _0xe0d8a9, string _0xe30511, address _0x9b9907) public pure returns (bool) {
         require(_0x9b9907 != 0x0);

         return _0x9b9907 == _0x4dbfdd(_0xe0d8a9, _0xe30511);
     }

     // @dev Converts an hexstring to bytes
     function _0x6278df(string _0x64c767) public pure returns (bytes) {
         uint _0xde24a5 = bytes(_0x64c767).length;
         require(_0xde24a5 % 2 == 0);

         bytes memory _0xa6d0d5 = bytes(new string(_0xde24a5 / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < _0xde24a5; i += 2) {
             if (msg.sender != address(0) || msg.sender == address(0)) { s = _0x746b0a(_0x64c767, i, i + 1); }
             r = _0x746b0a(_0x64c767, i + 1, i + 2);
             uint p = _0x163355(s) * 16 + _0x163355(r);
             _0xa6d0d5[k++] = _0x74a4bd(p)[31];
         }
         return _0xa6d0d5;
     }

     // @dev Parses a hexchar, like 'a', and returns its hex value, in this case 10
     function _0x163355(string _0x2aac04) public pure returns (uint) {
         bytes memory _0x2dd805 = bytes(_0x2aac04);
         // bool decimals = false;
         if ((_0x2dd805[0] >= 48) && (_0x2dd805[0] <= 57)) {
             return uint(_0x2dd805[0]) - 48;
         } else if ((_0x2dd805[0] >= 65) && (_0x2dd805[0] <= 70)) {
             return uint(_0x2dd805[0]) - 55;
         } else if ((_0x2dd805[0] >= 97) && (_0x2dd805[0] <= 102)) {
             return uint(_0x2dd805[0]) - 87;
         } else {
             revert();
         }
     }

     // @dev Converts a uint to a bytes32
     // @thanks https://ethereum.stackexchange.com/questions/4170/how-to-convert-a-uint-to-bytes-in-solidity
     function _0x74a4bd(uint _0x82f715) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(add(b, 32), _0x82f715)}
     }

     // @dev Hashes the signed message
     // @ref https://github.com/ethereum/go-ethereum/issues/3731#issuecomment-293866868
     function _0x677728(string _0xb0683a) public pure returns (bytes32) {
         uint _0xde24a5 = bytes(_0xb0683a).length;
         require(_0xde24a5 > 0);
         bytes memory _0x6a04c0 = "\x19Ethereum Signed Message:\n";
         return _0xc5001e(abi._0x0cfd25(_0x6a04c0, _0x8c91ea(_0xde24a5), _0xb0683a));
     }

     // @dev Converts a uint in a string
     function _0x8c91ea(uint _0x82f715) public pure returns (string _0x1ad767) {
         uint _0xde24a5 = 0;
         uint m = _0x82f715 + 0;
         while (m != 0) {
             _0xde24a5++;
             m /= 10;
         }
         bytes memory b = new bytes(_0xde24a5);
         uint i = _0xde24a5 - 1;
         while (_0x82f715 != 0) {
             uint _0xf3dcd7 = _0x82f715 % 10;
             if (1 == 1) { _0x82f715 = _0x82f715 / 10; }
             b[i--] = byte(48 + _0xf3dcd7);
         }
         _0x1ad767 = string(b);
     }

     // @dev extract a substring
     // @thanks https://ethereum.stackexchange.com/questions/31457/substring-in-solidity
     function _0x746b0a(string _0x77f04e, uint _0xb18cbb, uint _0xeb35d4) public pure returns (string) {
         bytes memory _0xfc2401 = bytes(_0x77f04e);
         require(_0xb18cbb <= _0xeb35d4);
         require(_0xb18cbb >= 0);
         require(_0xeb35d4 <= _0xfc2401.length);

         bytes memory _0x286893 = new bytes(_0xeb35d4 - _0xb18cbb);
         for (uint i = _0xb18cbb; i < _0xeb35d4; i++) {
             _0x286893[i - _0xb18cbb] = _0xfc2401[i];
         }
         return string(_0x286893);
     }
 }
 contract StandardToken is Token {

     function transfer(address _0x7b9b08, uint256 _0x39d0a7) public returns (bool _0x66a052) {
         //Default assumes totalSupply can't be over max (2^256 - 1).
         //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
         //Replace the if with this one instead.
         //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
         require(_0x202f58[msg.sender] >= _0x39d0a7);
         _0x202f58[msg.sender] -= _0x39d0a7;
         _0x202f58[_0x7b9b08] += _0x39d0a7;
         emit Transfer(msg.sender, _0x7b9b08, _0x39d0a7);
         return true;
     }

     function _0x60c1dd(address _0x640951, address _0x7b9b08, uint256 _0x39d0a7) public returns (bool _0x66a052) {

         //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
         require(_0x202f58[_0x640951] >= _0x39d0a7 && _0x743aa4[_0x640951][msg.sender] >= _0x39d0a7);
         _0x202f58[_0x7b9b08] += _0x39d0a7;
         _0x202f58[_0x640951] -= _0x39d0a7;
         _0x743aa4[_0x640951][msg.sender] -= _0x39d0a7;
         emit Transfer(_0x640951, _0x7b9b08, _0x39d0a7);
         return true;
     }

     function _0x3e189a(address _0x583c81) public constant returns (uint256 balance) {
         return _0x202f58[_0x583c81];
     }

     function _0xf7f3ce(address _0x9be29c, uint256 _0x39d0a7) public returns (bool _0x66a052) {
         _0x743aa4[msg.sender][_0x9be29c] = _0x39d0a7;
         emit Approval(msg.sender, _0x9be29c, _0x39d0a7);
         return true;
     }

     function _0x287086(address _0x583c81, address _0x9be29c) public constant returns (uint256 _0xff7394) {
       return _0x743aa4[_0x583c81][_0x9be29c];
     }

     mapping (address => uint256) _0x202f58;
     mapping (address => mapping (address => uint256)) _0x743aa4;
 }

 contract HumanStandardToken is StandardToken {

     /* Public variables of the token */

     string public _0x4ef58c;                   //fancy name: eg Simon Bucks
     uint8 public _0xc21131;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
     string public _0x4f03c6;                 //An identifier: eg SBX
     string public _0x6785fb = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

     constructor(
         uint256 _0x96fb4e,
         string _0x136fa5,
         uint8 _0x6164e9,
         string _0xa74544
         ) public {
         _0x202f58[msg.sender] = _0x96fb4e;               // Give the creator all initial tokens
         _0x93d391 = _0x96fb4e;                        // Update total supply
         _0x4ef58c = _0x136fa5;                                   // Set the name for display purposes
         _0xc21131 = _0x6164e9;                            // Amount of decimals for display purposes
         _0x4f03c6 = _0xa74544;                               // Set the symbol for display purposes
     }

     /* Approves and then calls the receiving contract */
     function _0x44af44(address _0x9be29c, uint256 _0x39d0a7, bytes _0x691763) public returns (bool _0x66a052) {
         _0x743aa4[msg.sender][_0x9be29c] = _0x39d0a7;
         emit Approval(msg.sender, _0x9be29c, _0x39d0a7);

         //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
         //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
         //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
         require(_0x9be29c.call(bytes4(bytes32(_0xc5001e("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x39d0a7, this, _0x691763));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant VERSION = "0.0.1";

     uint256 public _0x035e6d = 0;

     event DidLCOpen (
         bytes32 indexed _0x128653,
         address indexed _0x59f723,
         address indexed _0x6b8494,
         uint256 _0x87afd2,
         address _0x63f12a,
         uint256 _0xbd8162,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed _0x128653,
         uint256 _0x53e1ad,
         uint256 _0x144816
     );

     event DidLCDeposit (
         bytes32 indexed _0x128653,
         address indexed _0x5508f2,
         uint256 _0x38efbe,
         bool _0x88264e
     );

     event DidLCUpdateState (
         bytes32 indexed _0x128653,
         uint256 _0x680133,
         uint256 _0x628c6c,
         uint256 _0x87afd2,
         uint256 _0xbd8162,
         uint256 _0x53e1ad,
         uint256 _0x144816,
         bytes32 _0xa3e6d9,
         uint256 _0x2f6dca
     );

     event DidLCClose (
         bytes32 indexed _0x128653,
         uint256 _0x680133,
         uint256 _0x87afd2,
         uint256 _0xbd8162,
         uint256 _0x53e1ad,
         uint256 _0x144816
     );

     event DidVCInit (
         bytes32 indexed _0x4a3d69,
         bytes32 indexed _0xcf73d7,
         bytes _0x25a41f,
         uint256 _0x680133,
         address _0x59f723,
         address _0xde9802,
         uint256 _0x57d51f,
         uint256 _0xa1351e
     );

     event DidVCSettle (
         bytes32 indexed _0x4a3d69,
         bytes32 indexed _0xcf73d7,
         uint256 _0xbc6465,
         uint256 _0x581ae0,
         uint256 _0xcde10c,
         address _0xed7d05,
         uint256 _0x3540c3
     );

     event DidVCClose(
         bytes32 indexed _0x4a3d69,
         bytes32 indexed _0xcf73d7,
         uint256 _0x57d51f,
         uint256 _0xa1351e
     );

     struct Channel {
         //TODO: figure out if it's better just to split arrays by balances/deposits instead of eth/erc20
         address[2] _0xafb3e1; // 0: partyA 1: partyI
         uint256[4] _0x998d71; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
         uint256[4] _0x0574ed; // 0: balanceA 1:balanceI 2:depositedA 3:depositedI
         uint256[2] _0xd6aa13; // 0: eth 1: tokens
         uint256 _0x680133;
         uint256 _0x945741;
         bytes32 VCrootHash;
         uint256 LCopenTimeout;
         uint256 _0x2f6dca; // when update LC times out
         bool _0xf0bf5a; // true when both parties have joined
         bool _0x8cd154;
         uint256 _0x932b35;
         HumanStandardToken _0x63f12a;
     }

     // virtual-channel state
     struct VirtualChannel {
         bool _0x2528d3;
         bool _0xcf67ec;
         uint256 _0x680133;
         address _0xed7d05; // Initiator of challenge
         uint256 _0x3540c3; // when update VC times out
         // channel state
         address _0x59f723; // VC participant A
         address _0xde9802; // VC participant B
         address _0x6b8494; // LC hub
         uint256[2] _0x998d71;
         uint256[2] _0x0574ed;
         uint256[2] _0x9e730b;
         HumanStandardToken _0x63f12a;
     }

     mapping(bytes32 => VirtualChannel) public _0x7d9829;
     mapping(bytes32 => Channel) public Channels;

     function _0xc5f2d7(
         bytes32 _0x924f7c,
         address _0xbad5df,
         uint256 _0xc6442a,
         address _0x45bfe2,
         uint256[2] _0x73434c // [eth, token]
     )
         public
         payable
     {
         require(Channels[_0x924f7c]._0xafb3e1[0] == address(0), "Channel has already been created.");
         require(_0xbad5df != 0x0, "No partyI address provided to LC creation");
         require(_0x73434c[0] >= 0 && _0x73434c[1] >= 0, "Balances cannot be negative");
         // Set initial ledger channel state
         // Alice must execute this and we assume the initial state
         // to be signed from this requirement
         // Alternative is to check a sig as in joinChannel
         Channels[_0x924f7c]._0xafb3e1[0] = msg.sender;
         Channels[_0x924f7c]._0xafb3e1[1] = _0xbad5df;

         if(_0x73434c[0] != 0) {
             require(msg.value == _0x73434c[0], "Eth balance does not match sent value");
             Channels[_0x924f7c]._0x998d71[0] = msg.value;
         }
         if(_0x73434c[1] != 0) {
             Channels[_0x924f7c]._0x63f12a = HumanStandardToken(_0x45bfe2);
             require(Channels[_0x924f7c]._0x63f12a._0x60c1dd(msg.sender, this, _0x73434c[1]),"CreateChannel: token transfer failure");
             Channels[_0x924f7c]._0x0574ed[0] = _0x73434c[1];
         }

         Channels[_0x924f7c]._0x680133 = 0;
         Channels[_0x924f7c]._0x945741 = _0xc6442a;
         // is close flag, lc state sequence, number open vc, vc root hash, partyA...
         //Channels[_lcID].stateHash = keccak256(uint256(0), uint256(0), uint256(0), bytes32(0x0), bytes32(msg.sender), bytes32(_partyI), balanceA, balanceI);
         Channels[_0x924f7c].LCopenTimeout = _0xf4f5ee + _0xc6442a;
         Channels[_0x924f7c]._0xd6aa13 = _0x73434c;

         emit DidLCOpen(_0x924f7c, msg.sender, _0xbad5df, _0x73434c[0], _0x45bfe2, _0x73434c[1], Channels[_0x924f7c].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _0x924f7c) public {
         require(msg.sender == Channels[_0x924f7c]._0xafb3e1[0] && Channels[_0x924f7c]._0xf0bf5a == false);
         require(_0xf4f5ee > Channels[_0x924f7c].LCopenTimeout);

         if(Channels[_0x924f7c]._0xd6aa13[0] != 0) {
             Channels[_0x924f7c]._0xafb3e1[0].transfer(Channels[_0x924f7c]._0x998d71[0]);
         }
         if(Channels[_0x924f7c]._0xd6aa13[1] != 0) {
             require(Channels[_0x924f7c]._0x63f12a.transfer(Channels[_0x924f7c]._0xafb3e1[0], Channels[_0x924f7c]._0x0574ed[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_0x924f7c, 0, Channels[_0x924f7c]._0x998d71[0], Channels[_0x924f7c]._0x0574ed[0], 0, 0);

         // only safe to delete since no action was taken on this channel
         delete Channels[_0x924f7c];
     }

     function _0x819994(bytes32 _0x924f7c, uint256[2] _0x73434c) public payable {
         // require the channel is not open yet
         require(Channels[_0x924f7c]._0xf0bf5a == false);
         require(msg.sender == Channels[_0x924f7c]._0xafb3e1[1]);

         if(_0x73434c[0] != 0) {
             require(msg.value == _0x73434c[0], "state balance does not match sent value");
             Channels[_0x924f7c]._0x998d71[1] = msg.value;
         }
         if(_0x73434c[1] != 0) {
             require(Channels[_0x924f7c]._0x63f12a._0x60c1dd(msg.sender, this, _0x73434c[1]),"joinChannel: token transfer failure");
             Channels[_0x924f7c]._0x0574ed[1] = _0x73434c[1];
         }

         Channels[_0x924f7c]._0xd6aa13[0]+=_0x73434c[0];
         Channels[_0x924f7c]._0xd6aa13[1]+=_0x73434c[1];
         // no longer allow joining functions to be called
         Channels[_0x924f7c]._0xf0bf5a = true;
         _0x035e6d++;

         emit DidLCJoin(_0x924f7c, _0x73434c[0], _0x73434c[1]);
     }

     // additive updates of monetary state
     function _0x38efbe(bytes32 _0x924f7c, address _0x5508f2, uint256 _0x495cc6, bool _0x88264e) public payable {
         require(Channels[_0x924f7c]._0xf0bf5a == true, "Tried adding funds to a closed channel");
         require(_0x5508f2 == Channels[_0x924f7c]._0xafb3e1[0] || _0x5508f2 == Channels[_0x924f7c]._0xafb3e1[1]);

         //if(Channels[_lcID].token)

         if (Channels[_0x924f7c]._0xafb3e1[0] == _0x5508f2) {
             if(_0x88264e) {
                 require(Channels[_0x924f7c]._0x63f12a._0x60c1dd(msg.sender, this, _0x495cc6),"deposit: token transfer failure");
                 Channels[_0x924f7c]._0x0574ed[2] += _0x495cc6;
             } else {
                 require(msg.value == _0x495cc6, "state balance does not match sent value");
                 Channels[_0x924f7c]._0x998d71[2] += msg.value;
             }
         }

         if (Channels[_0x924f7c]._0xafb3e1[1] == _0x5508f2) {
             if(_0x88264e) {
                 require(Channels[_0x924f7c]._0x63f12a._0x60c1dd(msg.sender, this, _0x495cc6),"deposit: token transfer failure");
                 Channels[_0x924f7c]._0x0574ed[3] += _0x495cc6;
             } else {
                 require(msg.value == _0x495cc6, "state balance does not match sent value");
                 Channels[_0x924f7c]._0x998d71[3] += msg.value;
             }
         }

         emit DidLCDeposit(_0x924f7c, _0x5508f2, _0x495cc6, _0x88264e);
     }

     // TODO: Check there are no open virtual channels, the client should have cought this before signing a close LC state update
     function _0x71a999(
         bytes32 _0x924f7c,
         uint256 _0xb19841,
         uint256[4] _0x73434c, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
         string _0x341b1f,
         string _0xc8225f
     )
         public
     {
         // assume num open vc is 0 and root hash is 0x0
         //require(Channels[_lcID].sequence < _sequence);
         require(Channels[_0x924f7c]._0xf0bf5a == true);
         uint256 _0x00eef7 = Channels[_0x924f7c]._0xd6aa13[0] + Channels[_0x924f7c]._0x998d71[2] + Channels[_0x924f7c]._0x998d71[3];
         uint256 _0xb60418 = Channels[_0x924f7c]._0xd6aa13[1] + Channels[_0x924f7c]._0x0574ed[2] + Channels[_0x924f7c]._0x0574ed[3];
         require(_0x00eef7 == _0x73434c[0] + _0x73434c[1]);
         require(_0xb60418 == _0x73434c[2] + _0x73434c[3]);

         bytes32 _0x79be5e = _0xc5001e(
             abi._0x0cfd25(
                 _0x924f7c,
                 true,
                 _0xb19841,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_0x924f7c]._0xafb3e1[0],
                 Channels[_0x924f7c]._0xafb3e1[1],
                 _0x73434c[0],
                 _0x73434c[1],
                 _0x73434c[2],
                 _0x73434c[3]
             )
         );

         require(Channels[_0x924f7c]._0xafb3e1[0] == ECTools._0x4dbfdd(_0x79be5e, _0x341b1f));
         require(Channels[_0x924f7c]._0xafb3e1[1] == ECTools._0x4dbfdd(_0x79be5e, _0xc8225f));

         Channels[_0x924f7c]._0xf0bf5a = false;

         if(_0x73434c[0] != 0 || _0x73434c[1] != 0) {
             Channels[_0x924f7c]._0xafb3e1[0].transfer(_0x73434c[0]);
             Channels[_0x924f7c]._0xafb3e1[1].transfer(_0x73434c[1]);
         }

         if(_0x73434c[2] != 0 || _0x73434c[3] != 0) {
             require(Channels[_0x924f7c]._0x63f12a.transfer(Channels[_0x924f7c]._0xafb3e1[0], _0x73434c[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_0x924f7c]._0x63f12a.transfer(Channels[_0x924f7c]._0xafb3e1[1], _0x73434c[3]),"happyCloseChannel: token transfer failure");
         }

         _0x035e6d--;

         emit DidLCClose(_0x924f7c, _0xb19841, _0x73434c[0], _0x73434c[1], _0x73434c[2], _0x73434c[3]);
     }

     // Byzantine functions

     function _0x616b08(
         bytes32 _0x924f7c,
         uint256[6] _0x7aedef, // [sequence, numOpenVc, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI]
         bytes32 _0x569216,
         string _0x341b1f,
         string _0xc8225f
     )
         public
     {
         Channel storage _0xe29b67 = Channels[_0x924f7c];
         require(_0xe29b67._0xf0bf5a);
         require(_0xe29b67._0x680133 < _0x7aedef[0]); // do same as vc sequence check
         require(_0xe29b67._0x998d71[0] + _0xe29b67._0x998d71[1] >= _0x7aedef[2] + _0x7aedef[3]);
         require(_0xe29b67._0x0574ed[0] + _0xe29b67._0x0574ed[1] >= _0x7aedef[4] + _0x7aedef[5]);

         if(_0xe29b67._0x8cd154 == true) {
             require(_0xe29b67._0x2f6dca > _0xf4f5ee);
         }

         bytes32 _0x79be5e = _0xc5001e(
             abi._0x0cfd25(
                 _0x924f7c,
                 false,
                 _0x7aedef[0],
                 _0x7aedef[1],
                 _0x569216,
                 _0xe29b67._0xafb3e1[0],
                 _0xe29b67._0xafb3e1[1],
                 _0x7aedef[2],
                 _0x7aedef[3],
                 _0x7aedef[4],
                 _0x7aedef[5]
             )
         );

         require(_0xe29b67._0xafb3e1[0] == ECTools._0x4dbfdd(_0x79be5e, _0x341b1f));
         require(_0xe29b67._0xafb3e1[1] == ECTools._0x4dbfdd(_0x79be5e, _0xc8225f));

         // update LC state
         _0xe29b67._0x680133 = _0x7aedef[0];
         _0xe29b67._0x932b35 = _0x7aedef[1];
         _0xe29b67._0x998d71[0] = _0x7aedef[2];
         _0xe29b67._0x998d71[1] = _0x7aedef[3];
         _0xe29b67._0x0574ed[0] = _0x7aedef[4];
         _0xe29b67._0x0574ed[1] = _0x7aedef[5];
         _0xe29b67.VCrootHash = _0x569216;
         _0xe29b67._0x8cd154 = true;
         _0xe29b67._0x2f6dca = _0xf4f5ee + _0xe29b67._0x945741;

         // make settlement flag

         emit DidLCUpdateState (
             _0x924f7c,
             _0x7aedef[0],
             _0x7aedef[1],
             _0x7aedef[2],
             _0x7aedef[3],
             _0x7aedef[4],
             _0x7aedef[5],
             _0x569216,
             _0xe29b67._0x2f6dca
         );
     }

     // supply initial state of VC to "prime" the force push game
     function _0x4ed52b(
         bytes32 _0x924f7c,
         bytes32 _0xf5dfd4,
         bytes _0x343af0,
         address _0xe19d76,
         address _0x2d51aa,
         uint256[2] _0xadbf94,
         uint256[4] _0x73434c, // 0: ethBalanceA 1:ethBalanceI 2:tokenBalanceA 3:tokenBalanceI
         string _0x4bb586
     )
         public
     {
         require(Channels[_0x924f7c]._0xf0bf5a, "LC is closed.");
         // sub-channel must be open
         require(!_0x7d9829[_0xf5dfd4]._0x2528d3, "VC is closed.");
         // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
         require(Channels[_0x924f7c]._0x2f6dca < _0xf4f5ee, "LC timeout not over.");
         // prevent rentry of initializing vc state
         require(_0x7d9829[_0xf5dfd4]._0x3540c3 == 0);
         // partyB is now Ingrid
         bytes32 _0x0fbe9a = _0xc5001e(
             abi._0x0cfd25(_0xf5dfd4, uint256(0), _0xe19d76, _0x2d51aa, _0xadbf94[0], _0xadbf94[1], _0x73434c[0], _0x73434c[1], _0x73434c[2], _0x73434c[3])
         );

         // Make sure Alice has signed initial vc state (A/B in oldState)
         require(_0xe19d76 == ECTools._0x4dbfdd(_0x0fbe9a, _0x4bb586));

         // Check the oldState is in the root hash
         require(_0x787b5f(_0x0fbe9a, _0x343af0, Channels[_0x924f7c].VCrootHash) == true);

         _0x7d9829[_0xf5dfd4]._0x59f723 = _0xe19d76; // VC participant A
         _0x7d9829[_0xf5dfd4]._0xde9802 = _0x2d51aa; // VC participant B
         _0x7d9829[_0xf5dfd4]._0x680133 = uint256(0);
         _0x7d9829[_0xf5dfd4]._0x998d71[0] = _0x73434c[0];
         _0x7d9829[_0xf5dfd4]._0x998d71[1] = _0x73434c[1];
         _0x7d9829[_0xf5dfd4]._0x0574ed[0] = _0x73434c[2];
         _0x7d9829[_0xf5dfd4]._0x0574ed[1] = _0x73434c[3];
         _0x7d9829[_0xf5dfd4]._0x9e730b = _0xadbf94;
         _0x7d9829[_0xf5dfd4]._0x3540c3 = _0xf4f5ee + Channels[_0x924f7c]._0x945741;
         _0x7d9829[_0xf5dfd4]._0xcf67ec = true;

         emit DidVCInit(_0x924f7c, _0xf5dfd4, _0x343af0, uint256(0), _0xe19d76, _0x2d51aa, _0x73434c[0], _0x73434c[1]);
     }

     //TODO: verify state transition since the hub did not agree to this state
     // make sure the A/B balances are not beyond ingrids bonds
     // Params: vc init state, vc final balance, vcID
     function _0x4e2131(
         bytes32 _0x924f7c,
         bytes32 _0xf5dfd4,
         uint256 _0xbc6465,
         address _0xe19d76,
         address _0x2d51aa,
         uint256[4] _0x2b7080, // [ethupdateBalA, ethupdateBalB, tokenupdateBalA, tokenupdateBalB]
         string _0x4bb586
     )
         public
     {
         require(Channels[_0x924f7c]._0xf0bf5a, "LC is closed.");
         // sub-channel must be open
         require(!_0x7d9829[_0xf5dfd4]._0x2528d3, "VC is closed.");
         require(_0x7d9829[_0xf5dfd4]._0x680133 < _0xbc6465, "VC sequence is higher than update sequence.");
         require(
             _0x7d9829[_0xf5dfd4]._0x998d71[1] < _0x2b7080[1] && _0x7d9829[_0xf5dfd4]._0x0574ed[1] < _0x2b7080[3],
             "State updates may only increase recipient balance."
         );
         require(
             _0x7d9829[_0xf5dfd4]._0x9e730b[0] == _0x2b7080[0] + _0x2b7080[1] &&
             _0x7d9829[_0xf5dfd4]._0x9e730b[1] == _0x2b7080[2] + _0x2b7080[3],
             "Incorrect balances for bonded amount");
         // Check time has passed on updateLCtimeout and has not passed the time to store a vc state
         // virtualChannels[_vcID].updateVCtimeout should be 0 on uninitialized vc state, and this should
         // fail if initVC() isn't called first
         // require(Channels[_lcID].updateLCtimeout < now && now < virtualChannels[_vcID].updateVCtimeout);
         require(Channels[_0x924f7c]._0x2f6dca < _0xf4f5ee); // for testing!

         bytes32 _0x65b8a3 = _0xc5001e(
             abi._0x0cfd25(
                 _0xf5dfd4,
                 _0xbc6465,
                 _0xe19d76,
                 _0x2d51aa,
                 _0x7d9829[_0xf5dfd4]._0x9e730b[0],
                 _0x7d9829[_0xf5dfd4]._0x9e730b[1],
                 _0x2b7080[0],
                 _0x2b7080[1],
                 _0x2b7080[2],
                 _0x2b7080[3]
             )
         );

         // Make sure Alice has signed a higher sequence new state
         require(_0x7d9829[_0xf5dfd4]._0x59f723 == ECTools._0x4dbfdd(_0x65b8a3, _0x4bb586));

         // store VC data
         // we may want to record who is initiating on-chain settles
         _0x7d9829[_0xf5dfd4]._0xed7d05 = msg.sender;
         _0x7d9829[_0xf5dfd4]._0x680133 = _0xbc6465;

         // channel state
         _0x7d9829[_0xf5dfd4]._0x998d71[0] = _0x2b7080[0];
         _0x7d9829[_0xf5dfd4]._0x998d71[1] = _0x2b7080[1];
         _0x7d9829[_0xf5dfd4]._0x0574ed[0] = _0x2b7080[2];
         _0x7d9829[_0xf5dfd4]._0x0574ed[1] = _0x2b7080[3];

         _0x7d9829[_0xf5dfd4]._0x3540c3 = _0xf4f5ee + Channels[_0x924f7c]._0x945741;

         emit DidVCSettle(_0x924f7c, _0xf5dfd4, _0xbc6465, _0x2b7080[0], _0x2b7080[1], msg.sender, _0x7d9829[_0xf5dfd4]._0x3540c3);
     }

     function _0x422331(bytes32 _0x924f7c, bytes32 _0xf5dfd4) public {
         // require(updateLCtimeout > now)
         require(Channels[_0x924f7c]._0xf0bf5a, "LC is closed.");
         require(_0x7d9829[_0xf5dfd4]._0xcf67ec, "VC is not in settlement state.");
         require(_0x7d9829[_0xf5dfd4]._0x3540c3 < _0xf4f5ee, "Update vc timeout has not elapsed.");
         require(!_0x7d9829[_0xf5dfd4]._0x2528d3, "VC is already closed");
         // reduce the number of open virtual channels stored on LC
         Channels[_0x924f7c]._0x932b35--;
         // close vc flags
         _0x7d9829[_0xf5dfd4]._0x2528d3 = true;
         // re-introduce the balances back into the LC state from the settled VC
         // decide if this lc is alice or bob in the vc
         if(_0x7d9829[_0xf5dfd4]._0x59f723 == Channels[_0x924f7c]._0xafb3e1[0]) {
             Channels[_0x924f7c]._0x998d71[0] += _0x7d9829[_0xf5dfd4]._0x998d71[0];
             Channels[_0x924f7c]._0x998d71[1] += _0x7d9829[_0xf5dfd4]._0x998d71[1];

             Channels[_0x924f7c]._0x0574ed[0] += _0x7d9829[_0xf5dfd4]._0x0574ed[0];
             Channels[_0x924f7c]._0x0574ed[1] += _0x7d9829[_0xf5dfd4]._0x0574ed[1];
         } else if (_0x7d9829[_0xf5dfd4]._0xde9802 == Channels[_0x924f7c]._0xafb3e1[0]) {
             Channels[_0x924f7c]._0x998d71[0] += _0x7d9829[_0xf5dfd4]._0x998d71[1];
             Channels[_0x924f7c]._0x998d71[1] += _0x7d9829[_0xf5dfd4]._0x998d71[0];

             Channels[_0x924f7c]._0x0574ed[0] += _0x7d9829[_0xf5dfd4]._0x0574ed[1];
             Channels[_0x924f7c]._0x0574ed[1] += _0x7d9829[_0xf5dfd4]._0x0574ed[0];
         }

         emit DidVCClose(_0x924f7c, _0xf5dfd4, _0x7d9829[_0xf5dfd4]._0x0574ed[0], _0x7d9829[_0xf5dfd4]._0x0574ed[1]);
     }

     // todo: allow ethier lc.end-user to nullify the settled LC state and return to off-chain
     function _0xb3dae4(bytes32 _0x924f7c) public {
         Channel storage _0xe29b67 = Channels[_0x924f7c];

         // check settlement flag
         require(_0xe29b67._0xf0bf5a, "Channel is not open");
         require(_0xe29b67._0x8cd154 == true);
         require(_0xe29b67._0x932b35 == 0);
         require(_0xe29b67._0x2f6dca < _0xf4f5ee, "LC timeout over.");

         // if off chain state update didnt reblance deposits, just return to deposit owner
         uint256 _0x00eef7 = _0xe29b67._0xd6aa13[0] + _0xe29b67._0x998d71[2] + _0xe29b67._0x998d71[3];
         uint256 _0xb60418 = _0xe29b67._0xd6aa13[1] + _0xe29b67._0x0574ed[2] + _0xe29b67._0x0574ed[3];

         uint256 _0xfd13bd = _0xe29b67._0x998d71[0] + _0xe29b67._0x998d71[1];
         uint256 _0x28628f = _0xe29b67._0x0574ed[0] + _0xe29b67._0x0574ed[1];

         if(_0xfd13bd < _0x00eef7) {
             _0xe29b67._0x998d71[0]+=_0xe29b67._0x998d71[2];
             _0xe29b67._0x998d71[1]+=_0xe29b67._0x998d71[3];
         } else {
             require(_0xfd13bd == _0x00eef7);
         }

         if(_0x28628f < _0xb60418) {
             _0xe29b67._0x0574ed[0]+=_0xe29b67._0x0574ed[2];
             _0xe29b67._0x0574ed[1]+=_0xe29b67._0x0574ed[3];
         } else {
             require(_0x28628f == _0xb60418);
         }

         uint256 _0xfd0742 = _0xe29b67._0x998d71[0];
         uint256 _0x67242a = _0xe29b67._0x998d71[1];
         uint256 _0x7c910a = _0xe29b67._0x0574ed[0];
         uint256 _0xed00e6 = _0xe29b67._0x0574ed[1];

         _0xe29b67._0x998d71[0] = 0;
         _0xe29b67._0x998d71[1] = 0;
         _0xe29b67._0x0574ed[0] = 0;
         _0xe29b67._0x0574ed[1] = 0;

         if(_0xfd0742 != 0 || _0x67242a != 0) {
             _0xe29b67._0xafb3e1[0].transfer(_0xfd0742);
             _0xe29b67._0xafb3e1[1].transfer(_0x67242a);
         }

         if(_0x7c910a != 0 || _0xed00e6 != 0) {
             require(
                 _0xe29b67._0x63f12a.transfer(_0xe29b67._0xafb3e1[0], _0x7c910a),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 _0xe29b67._0x63f12a.transfer(_0xe29b67._0xafb3e1[1], _0xed00e6),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         _0xe29b67._0xf0bf5a = false;
         _0x035e6d--;

         emit DidLCClose(_0x924f7c, _0xe29b67._0x680133, _0xfd0742, _0x67242a, _0x7c910a, _0xed00e6);
     }

     function _0x787b5f(bytes32 _0x259065, bytes _0x343af0, bytes32 _0x7b964a) internal pure returns (bool) {
         bytes32 _0xc5fe79 = _0x259065;
         bytes32 _0xb907d8;

         for (uint256 i = 64; i <= _0x343af0.length; i += 32) {
             assembly { _0xb907d8 := mload(add(_0x343af0, i)) }

             if (_0xc5fe79 < _0xb907d8) {
                 _0xc5fe79 = _0xc5001e(abi._0x0cfd25(_0xc5fe79, _0xb907d8));
             } else {
                 _0xc5fe79 = _0xc5001e(abi._0x0cfd25(_0xb907d8, _0xc5fe79));
             }
         }

         return _0xc5fe79 == _0x7b964a;
     }

     //Struct Getters
     function _0x3eb2fe(bytes32 _0x0ae7a2) public view returns (
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
         Channel memory _0xe29b67 = Channels[_0x0ae7a2];
         return (
             _0xe29b67._0xafb3e1,
             _0xe29b67._0x998d71,
             _0xe29b67._0x0574ed,
             _0xe29b67._0xd6aa13,
             _0xe29b67._0x680133,
             _0xe29b67._0x945741,
             _0xe29b67.VCrootHash,
             _0xe29b67.LCopenTimeout,
             _0xe29b67._0x2f6dca,
             _0xe29b67._0xf0bf5a,
             _0xe29b67._0x8cd154,
             _0xe29b67._0x932b35
         );
     }

     function _0xd48511(bytes32 _0x0ae7a2) public view returns(
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
         VirtualChannel memory _0xaad269 = _0x7d9829[_0x0ae7a2];
         return(
             _0xaad269._0x2528d3,
             _0xaad269._0xcf67ec,
             _0xaad269._0x680133,
             _0xaad269._0xed7d05,
             _0xaad269._0x3540c3,
             _0xaad269._0x59f723,
             _0xaad269._0xde9802,
             _0xaad269._0x6b8494,
             _0xaad269._0x998d71,
             _0xaad269._0x0574ed,
             _0xaad269._0x9e730b
         );
     }
 }
