pragma solidity ^0.4.24;

import "./Type.sol";

contract User {
  mapping(bytes32 => Profile) public users;
  mapping(bytes32 => uint) public emailId;
  uint public usersCount;

  struct Profile {
    address id;
    string email;
    uint since;
  }

  constructor () public {}

  function verifyCredentials(bytes32 _email) public view returns (bool) {
    uint _emailId = emailId[_email];

    if (_emailId == 0) {
      return (false);
    }

    return (true);
  }

  function loginUser(bytes32 _email) public {
    require(emailId[_email] == 0);
    usersCount++;
    emailId[_email] = 1;
    users[_email] = Profile({
      id: msg.sender,
      email: Type.bytes32ToStr(_email),
      since: now
    });
  }
}
