// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BNBStaking {
    struct StakeInfo {
        uint256 amount;      // 质押的 BNB 数量
        uint256 startTime;   // 质押开始时间
    }

    mapping(address => StakeInfo) public stakes;

    // 年化 10%（1000 = 100%）
    uint256 public constant APR = 100;

    /// @notice 质押 BNB
    function stake() external payable {
        require(msg.value > 0, "No BNB sent");

        StakeInfo storage s = stakes[msg.sender];

        // 如果之前已经质押，先结算奖励
        if (s.amount > 0) {
            uint256 reward = pendingReward(msg.sender);
            s.amount += reward;
        }

        s.amount += msg.value;
        s.startTime = block.timestamp;
    }

    /// @notice 查看当前奖励（BNB）
    function pendingReward(address user) public view returns (uint256) {
        StakeInfo memory s = stakes[user];
        if (s.amount == 0) return 0;

        uint256 timePassed = block.timestamp - s.startTime;

        // reward = amount * APR * time / (1000 * 365 days)
        return (s.amount * APR * timePassed) / (1000 * 365 days);
    }

    /// @notice 领取奖励
    function claimReward() external {
        StakeInfo storage s = stakes[msg.sender];
        require(s.amount > 0, "No stake");

        uint256 reward = pendingReward(msg.sender);
        require(reward > 0, "No reward");

        s.startTime = block.timestamp;

        payable(msg.sender).transfer(reward);
    }

    /// @notice 提取本金 + 奖励
    function withdraw() external {
        StakeInfo storage s = stakes[msg.sender];
        require(s.amount > 0, "No stake");

        uint256 reward = pendingReward(msg.sender);
        uint256 total = s.amount + reward;

        delete stakes[msg.sender];

        payable(msg.sender).transfer(total);
    }
}
