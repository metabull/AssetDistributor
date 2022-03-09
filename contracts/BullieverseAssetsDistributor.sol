// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

struct Reward {
    uint256 collectionId;
    uint256 amount;
    bool claimed;
}

contract BullieverseAssetsDistributor is Ownable {
    mapping(uint256 => mapping(address => Reward)) public rewardDetails;

    address public rewardAddress;

    address public masterAddress;

    constructor(address erc1155Address) {
        rewardAddress = erc1155Address;
    }

    event AddRewardClaimer(address user, uint256 collectionId, uint256 amount);
    event Claimed(address user, uint256 tokenId, uint256 amount);
    event EmergencyExit(address user, uint256 tokenId, uint256 amount);
    event AmountChanged(uint256 oldAmount, uint256 newAmount);
    event ChangeRewardAddress(
        address oldRewardAddress,
        address newRewardAddress
    );
    event MultiClaimed(address user, uint256[] collectionList);

    function changeMasterAddress(address _masterAddress) public onlyOwner {
        masterAddress = _masterAddress;
    }

    function changeRewardAddress(address _rewardAddress) public onlyOwner {
        address oldRewardAddress = rewardAddress;
        rewardAddress = _rewardAddress;
        emit ChangeRewardAddress(oldRewardAddress, rewardAddress);
    }

    function addRewardClaimer(
        address user,
        uint256 collectionId,
        uint256 amount
    ) public onlyOwner {
        rewardDetails[collectionId][user] = Reward(collectionId, amount, false);
        emit AddRewardClaimer(user, collectionId, amount);
    }

    function addRewardClaimers(
        address[] memory users,
        uint256 collectionId,
        uint256[] memory amounts
    ) public onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            rewardDetails[collectionId][users[i]] = Reward(
                collectionId,
                amounts[i],
                false
            );
        }
    }

    function claim(uint256 collectionId) external {
        require(
            !rewardDetails[collectionId][msg.sender].claimed,
            "Your Address is not Whitelisted"
        );

        uint256 amount = rewardDetails[collectionId][msg.sender].amount;
        require(amount != 0, "Amount Cannot be Zero");

        IERC1155(rewardAddress).safeTransferFrom(
            masterAddress,
            msg.sender,
            collectionId,
            amount,
            ""
        );
        rewardDetails[collectionId][msg.sender].claimed = true;
        emit Claimed(msg.sender, collectionId, amount);
    }

    function claimAll(uint256[] memory collectionIds) external {
        for (uint256 i = 0; i < collectionIds.length; i++) {
            require(
                !rewardDetails[collectionIds[i]][msg.sender].claimed,
                "Your Address is not Whitelisted"
            );

            uint256 amount = rewardDetails[collectionIds[i]][msg.sender].amount;
            require(amount != 0, "Amount Cannot be Zero");
            IERC1155(rewardAddress).safeTransferFrom(
                masterAddress,
                msg.sender,
                collectionIds[i],
                amount,
                ""
            );
            rewardDetails[collectionIds[i]][msg.sender].claimed = true;
        }
    }

    function getBatchRewardDetails(
        address userAddress,
        uint256[] memory collectionIds
    ) public view returns (Reward[] memory) {
        Reward[] memory batchRewardDetails = new Reward[](collectionIds.length);
        for (uint256 i = 0; i < collectionIds.length; i++) {
            batchRewardDetails[i] = rewardDetails[collectionIds[i]][
                userAddress
            ];
        }
        return batchRewardDetails;
    }
}
