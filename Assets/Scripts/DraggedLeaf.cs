using UnityEngine;
using UnityEngine.InputSystem;
public class DraggedLeaf : MonoBehaviour
{
    private Leaf draggedLeaf;

    void Update()
    {
        Pointer pointer = Pointer.current;
        // Pointer could be missing if no mouse or touch input is available
        // Better to not take a chance and try to use a missing pointer
        if (pointer == null)
        {
            return;
        }

        // Get the world position of the pointer (mouse or touch)
        Vector2 worldPos = Camera.main.ScreenToWorldPoint(pointer.position.ReadValue());

        // If a drag started
        if (pointer.press.wasPressedThisFrame)
        {
            Collider2D hit = Physics2D.OverlapPoint(worldPos);
            // Check if the pointer is over a collider
            if (hit != null)
            {
                Leaf leaf = hit.GetComponent<Leaf>();
                // Check if the collider is a leaf. We don't have other colliders
                // But better to not take a chance and try to use a missing leaf
                if (leaf != null)
                {
                    draggedLeaf = leaf;
                    draggedLeaf.BeginDrag();
                }
            }
        }

        // Case where no leaf is currently being dragged
        // Called because the pointer is moving but no drag has started
        if (!draggedLeaf)
        {
            return;
        }

        // If a drag is done (pointer released)
        if (pointer.press.wasReleasedThisFrame)
        {
            draggedLeaf.Release();
            draggedLeaf = null;
            return;
        }

        // We move the leaf to the current pointer position
        draggedLeaf.DragTo(worldPos);
    }
}
