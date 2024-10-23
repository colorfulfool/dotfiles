class Solution:
    def pathSum(self, root: Optional[TreeNode], targetSum: int, path = [], ans = []) -> List[List[int]]:
        if not root:
            return ans

        targetSum -= root.val

        if not root.left and not root.right and targetSum == 0:
            return ans + [path + [root.val]]

        return self.pathSum(root.left, targetSum, path + [root.val], ans) + \
            self.pathSum(root.right, targetSum, path + [root.val], ans)

