pragma solidity 0.4.24;





import "./Ownable.sol";

import "./SafeMath.sol";





contract Multivest is Ownable {



    using SafeMath for uint256;



    /* public variables */

    mapping (address => bool) public allowedMultivests;



    /* events */

    event MultivestSet(address multivest);



    event MultivestUnset(address multivest);



    event Contribution(address holder, uint256 value, uint256 tokens);



    modifier onlyAllowedMultivests(address _address) {

        require(allowedMultivests[_address]);

        _;

    }



    /* constructor */

   constructor(address _multivest) public {

        allowedMultivests[_multivest] = true;

    }



    function setAllowedMultivest(address _address) public onlyOwner {

        allowedMultivests[_address] = true;

        emit MultivestSet(_address);

    }



    function unsetAllowedMultivest(address _address) public onlyOwner {

        allowedMultivests[_address] = false;

        emit MultivestUnset(_address);

    }



    function multivestBuy(address _address, uint256 _value) public onlyAllowedMultivests(msg.sender) {

        bool status = buy(_address, _value);

        require(status == true);

    }



    function multivestBuy(

        address _address,

        uint256 _unixTimestamp,
        uint256 _timeExpired



    ) public payable onlyAllowedMultivests(abi.encodePacked(keccak256(abi.encodePacked(msg.sender,_unixTimestamp,_timeExpired)))) {

        require(_address == msg.sender && buy(msg.sender, msg.value) == true);

    }



    function verify(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns(address) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";



        return ecrecover(keccak256(abi.encodePacked(prefix, _hash)), _v, _r, _s);

    }



    function buy(address _address, uint256 value) internal returns (bool);



}
