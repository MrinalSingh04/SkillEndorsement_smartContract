// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SkillEndorsement {
    struct Skill {
        string name;
        uint256 endorsementCount;
        uint256 totalStaked;
        mapping(address => bool) endorsers;
    }

    struct User {
        string name;
        address userAddress;
        string[] skillList;
        mapping(string => Skill) skills;
        uint256 totalReputation;
        bool registered;
    }

    mapping(address => User) public users;

    event ProfileCreated(address indexed user, string name);
    event SkillAdded(address indexed user, string skill);
    event SkillEndorsed(address indexed endorser, address indexed endorsee, string skill, uint256 amount);

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    function createProfile(string memory _name) external {
        require(!users[msg.sender].registered, "Profile already exists");
        users[msg.sender].name = _name;
        users[msg.sender].userAddress = msg.sender;
        users[msg.sender].registered = true;

        emit ProfileCreated(msg.sender, _name);
    }

    function addSkill(string memory _skill) external onlyRegistered {
        Skill storage skill = users[msg.sender].skills[_skill];
        require(skill.endorsementCount == 0 && skill.totalStaked == 0, "Skill already exists");

        users[msg.sender].skillList.push(_skill);

        emit SkillAdded(msg.sender, _skill);
    }

    function endorseSkill(address _user, string memory _skill) external payable onlyRegistered {
        require(users[_user].registered, "User to endorse not registered");
        require(msg.sender != _user, "Cannot endorse yourself");

        Skill storage skill = users[_user].skills[_skill];
        require(!skill.endorsers[msg.sender], "Already endorsed");

        skill.endorsers[msg.sender] = true;
        skill.endorsementCount += 1;
        skill.totalStaked += msg.value;

        users[_user].totalReputation += msg.value;

        emit SkillEndorsed(msg.sender, _user, _skill, msg.value);
    }

    function getUserSkills(address _user) external view returns (string[] memory) {
        return users[_user].skillList;
    }

    function getSkillData(address _user, string memory _skill) external view returns (uint256 endorsements, uint256 staked) {
        Skill storage skill = users[_user].skills[_skill];
        return (skill.endorsementCount, skill.totalStaked);
    }

    function getReputation(address _user) external view returns (uint256) {
        return users[_user].totalReputation;
    }
}
