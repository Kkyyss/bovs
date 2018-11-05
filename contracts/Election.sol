pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import './Library.sol';

contract Election {
  mapping(bytes32 => uint) public ownerId;
  bytes32 private owner;
  bytes32 private title;
  bytes private imgURL;
  bytes32 private description;
  uint private startDate;
  uint private endDate;
  uint public candSize;
  uint public votrSize;
  Mode private mode;

  enum Mode { Private, Public }

  mapping(uint => Candidate) private candidates;
  mapping(bytes32 => Voter) private voters;
  mapping(bytes32 => uint) private voterId;
  mapping(bytes32 => uint) private votedTo;
  mapping(bytes32 => uint) private pubVoterId;

  struct Candidate {
    uint id;
    string name;
    string imgURL;
    string description;
    uint voteCount;
  }

  struct Voter {
    uint id;
    string email;
    bool voted;
  }

  constructor (
    bytes32[3] _content, bytes _imgURL, bool[2] _setup,
    bytes32[] _candidates,
    string[] _cImg,
    bytes32[] _candidatesDescription,
    bytes32[] _voters, uint[2] _start_end
  ) public {
    ownerId[_content[0]] = 1;
    owner = _content[0];
    title = _content[1];
    imgURL = _imgURL;
    description = _content[2];
    startDate = _start_end[0];
    // Not closing manually
    if (!_setup[0]) {
      endDate = _start_end[1];
    }
    addCandidates(_candidates, _cImg, _candidatesDescription);

    // Whether is 'Public' or 'Private' mode
    if (!_setup[1]) {
      mode = Mode.Private;
      addVoters(_voters);
    } else {
      mode = Mode.Public;
    }

  }

  function addCandidates(bytes32[] _names,
                         string[] _img,
                         bytes32[] _description) private {
    candSize = _names.length;

    for (uint i = 0; i < candSize; i++) {
      candidates[i] = Candidate(
        i,
        Library.bytes32ToStr(_names[i]),
        _img[i],
        Library.bytes32ToStr(_description[i]),
        0);
    }
  }

  function addVoters(bytes32[] _emails) private {
    votrSize = _emails.length;

    for (uint i = 0; i < votrSize; i++) {
      voterId[_emails[i]] = i + 1;
      voters[_emails[i]] = Voter(i, Library.bytes32ToStr(_emails[i]), false);
    }
  }
  function isVoter(bytes32 _email) public view returns (bool) {
    return (voterId[_email] != 0);
  }
  function isOwner(bytes32 _email) public view returns (bool) {
    return (ownerId[_email] != 0);
  }
  function isVoted(bytes32 _email) public view returns (bool) {
    return (voters[_email].voted);
  }
  function getVotedTo(bytes32 _email) public view returns (string) {
    return (candidates[votedTo[_email]].name);
  }

  function vote (bytes32 _email, uint _candidateId) public {
    if (mode == Mode.Private) {
      require(voterId[_email] != 0);
    } else {
      if (voterId[_email] == 0) {
        voters[_email] = Voter(votrSize, Library.bytes32ToStr(_email), false);
        votrSize++;
      }
    }

    if (endDate != 0) {
      // Due date
      require(now < endDate);
    }

    // require that they haven't voted before
    require(!voters[_email].voted);

    // require a valid candidate
    require(_candidateId >= 0 && _candidateId < candSize);

    // record the voter has voted
    voters[_email].voted = true;

    // update the voter vote to
    votedTo[_email] = _candidateId;

    // update candidate vote Count
    candidates[_candidateId].voteCount ++;
  }

  function getTitle() public view returns (string) {
    return Library.bytes32ToStr(title);
  }
  function getImgURL() public view returns (string) {
    return string(imgURL);
  }
  function getDescription() public view returns (string) {
    return Library.bytes32ToStr(description);
  }
  function getOwner() public view returns (string) {
    return Library.bytes32ToStr(owner);
  }
  // Candidate
  function getCandidateName(uint i) public view returns (string) {
    return candidates[i].name;
  }
  function getCandidateImgURL(uint i) public view returns (string) {
    return string(candidates[i].imgURL);
  }
  function getCandidateDescription(uint i) public view returns (string) {
    return candidates[i].description;
  }
  function getCandidateVoteCount(uint i) public view returns (uint) {
    return candidates[i].voteCount;
  }
  function close(bytes32 _email) public {
    require(ownerId[_email] != 0);

    // Is manual close
    require(endDate == 0);

    endDate = now;
  }

  function getStartDate() public view returns (uint) {
    return startDate;
  }
  function getEndDate() public view returns (uint) {
    return endDate;
  }
  function getMode() public view returns (uint) {
    return uint(mode);
  }
}
