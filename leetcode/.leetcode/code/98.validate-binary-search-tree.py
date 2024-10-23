class Solution:
    def isValidBST(self, root: Optional[TreeNode], lo = float('-inf'), hi = float('inf')) -> bool:
        if not root:
            return True

        if not lo < root.val < hi:
            return False

        return self.isValidBST(root.left, lo, root.val) and \
               self.isValidBST(root.right, root.val, hi)
