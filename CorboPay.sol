// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.7;

contract CorboPay is Ownable {

    uint256 submittedIndex;

    uint256 index;

    struct Draft {
        bool signed;
        address signer;
        uint256 milestonesAmount;
        uint256 milestonesCount;
        uint256 totalAmount;
        uint256 ethTotal;
    }
    
    mapping (address => bool) client;

    mapping (address => bool) approvedClient;

    mapping (uint256 => Draft) submittedDrafts;

    mapping (uint256 => Draft) approvedDrafts;

    modifier onlyClient() {
        require(client[msg.sender] == true);
        _;
    }

    modifier onlyApproved() {
        require(client[msg.sender] == true);
        _;
    }

    function verifyDraft(uint256 _index, uint256 _amount) internal {
        approvedDrafts[index].signer = submittedDrafts[_index].signer;
        approvedDrafts[index].milestonesAmount = submittedDrafts[_index].milestonesAmount;
        approvedDrafts[index].milestonesCount = submittedDrafts[_index].milestonesCount;
        approvedDrafts[index].totalAmount = submittedDrafts[_index].totalAmount;
        approvedDrafts[index].ethTotal = _amount;
        index++;
    }

    function submitDraft(uint256 amount, uint256 numMilestones) public onlyClient {
        submittedDrafts[submittedIndex].signer = msg.sender;
        submittedDrafts[submittedIndex].milestonesAmount = amount / numMilestones;
        submittedDrafts[submittedIndex].milestonesCount = numMilestones;
        submittedDrafts[submittedIndex].totalAmount = amount;
        submittedIndex++;
    }

    function finalizeDraft(uint256 clientIndex) public onlyClient payable {
        require(msg.value * 100 == approvedDrafts[clientIndex].ethTotal);
        approvedClient[msg.sender] = true;
    }

    function approveDraft(uint256 oldIndex, address submitter, uint256 amount) public onlyOwner {
        require(submittedDrafts[oldIndex].signer == submitter);
        submittedDrafts[oldIndex].signed = true;
        verifyDraft(oldIndex, amount);
    }

    function viewSubmitted(uint256 clientIndex) public view onlyClient returns(Draft memory) {
        require(submittedDrafts[clientIndex].signer == msg.sender);
        return submittedDrafts[clientIndex];
    }

    function viewApproved(uint256 clientIndex) public view onlyApproved returns(Draft memory) {
        require(approvedDrafts[clientIndex].signer == msg.sender);
        return approvedDrafts[clientIndex];
    }

}
