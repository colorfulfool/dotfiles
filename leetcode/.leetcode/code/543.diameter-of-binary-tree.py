from typing import Optional

class Solution:
    def diameterOfBinaryTree(self, root: Optional[TreeNode]) -> int:
        self.ans = 0

        def helper(root):
            if not root:
                return 0

            left = helper(root.left)
            right = helper(root.right)

            self.ans = max(self.ans, left + right)

            return max(left, right) + 1

        helper(root)

        return self.ans
