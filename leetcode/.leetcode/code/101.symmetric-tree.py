class Solution:
    def isSymmetric(self, root: Optional[TreeNode]) -> bool:
        if not root:
            return True

        def helper(n1, n2):
            if not n1 and not n2:
                return True

            if (n1 and not n2) or (not n1 and n2):
                return False

            if n1.val != n2.val:
                return False

            return helper(n1.left, n2.right) and helper(n2.left, n1.right)

        return helper(root.left, root.right)
